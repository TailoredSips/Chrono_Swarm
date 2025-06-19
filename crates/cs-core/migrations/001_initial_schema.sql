-- Chrono-Swarm Initial Database Schema
-- Migration: 001_initial_schema.sql


-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- Tasks table
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_type VARCHAR(255) NOT NULL,
    priority INTEGER NOT NULL DEFAULT 2,
    payload BYTEA NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    retry_count INTEGER NOT NULL DEFAULT 0,
    max_retries INTEGER NOT NULL DEFAULT 3,
    timeout_seconds INTEGER NOT NULL DEFAULT 300,
    error_message TEXT,
    result BYTEA,
    metadata JSONB,
    
    CONSTRAINT valid_priority CHECK (priority BETWEEN 0 AND 4),
    CONSTRAINT valid_status CHECK (status IN ('pending', 'running', 'completed', 'failed', 'cancelled'))
);


-- Nodes table
CREATE TABLE nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    node_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    capabilities TEXT[] NOT NULL DEFAULT '{}',
    last_heartbeat TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    resource_limits JSONB,
    metadata JSONB,
    
    CONSTRAINT valid_node_type CHECK (node_type IN ('controller', 'executor', 'hybrid')),
    CONSTRAINT valid_status CHECK (status IN ('active', 'unhealthy', 'disconnected', 'maintenance'))
);


-- Agents table
CREATE TABLE agents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    node_id UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
    agent_type VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'initializing',
    current_task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_heartbeat TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    performance_metrics JSONB,
    
    CONSTRAINT valid_agent_status CHECK (status IN ('initializing', 'ready', 'executing', 'completed', 'failed', 'terminated'))
);


-- Task dependencies table
CREATE TABLE task_dependencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    depends_on_task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    UNIQUE(task_id, depends_on_task_id)
);


-- System metrics table
CREATE TABLE system_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    node_id UUID REFERENCES nodes(id) ON DELETE CASCADE,
    metric_name VARCHAR(255) NOT NULL,
    metric_value DOUBLE PRECISION NOT NULL,
    tags JSONB,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    INDEX idx_system_metrics_timestamp (timestamp),
    INDEX idx_system_metrics_node_metric (node_id, metric_name, timestamp)
);


-- Event log table for event sourcing
CREATE TABLE event_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(255) NOT NULL,
    event_type VARCHAR(255) NOT NULL,
    event_data JSONB NOT NULL,
    event_version INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    INDEX idx_event_log_aggregate (aggregate_id, aggregate_type, event_version),
    INDEX idx_event_log_timestamp (created_at)
);


-- Create indexes for performance
CREATE INDEX idx_tasks_status_priority ON tasks(status, priority, created_at);
CREATE INDEX idx_tasks_agent_type ON tasks(agent_type);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);
CREATE INDEX idx_nodes_status ON nodes(status);
CREATE INDEX idx_nodes_last_heartbeat ON nodes(last_heartbeat);
CREATE INDEX idx_agents_node_id ON agents(node_id);
CREATE INDEX idx_agents_status ON agents(status);
CREATE INDEX idx_agents_current_task_id ON agents(current_task_id);


-- Create functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;


$$ language 'plpgsql';


-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


CREATE TRIGGER update_agents_updated_at BEFORE UPDATE ON agents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- Insert initial system node
INSERT INTO nodes (id, node_type, status, capabilities, metadata) VALUES (
    uuid_generate_v4(),
    'controller',
    'active',
    ARRAY['orchestration', 'scheduling', 'monitoring'],
    '{"role": "system", "auto_created": true}'::jsonb
);
