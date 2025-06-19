//! Chrono-Swarm Nervous System - Event Streaming & Messaging
//! 
//! This crate provides the distributed messaging backbone for the Chrono-Swarm
//! system using Apache Kafka with optimized configurations for high throughput
//! and low latency.


use anyhow::Result;
use rdkafka::config::ClientConfig;
use rdkafka::consumer::{Consumer, StreamConsumer};
use rdkafka::producer::{FutureProducer, FutureRecord};
use rdkafka::Message;
use serde::{Deserialize, Serialize};
use std::time::Duration;
use tokio::time::timeout;
use tracing::{error, info, warn};

/// High-performance Kafka producer optimized for Chrono-Swarm
pub struct SwarmProducer {
    producer: FutureProducer,
    default_timeout: Duration,
}

impl SwarmProducer {
    /// Create a new SwarmProducer with optimized settings
    pub fn new(brokers: &str) -> Result<Self> {
        let producer = ClientConfig::new()
            .set("bootstrap.servers", brokers)
            .set("message.timeout.ms", "5000")
            .set("request.timeout.ms", "3000")
            .set("delivery.timeout.ms", "10000")
            // Compression for bandwidth optimization
            .set("compression.type", "lz4")
            .set("compression.level", "6")
            // Batching for throughput optimization
            .set("batch.size", "65536")
            .set("linger.ms", "5")
            .set("buffer.memory", "134217728") // 128MB
            // Reliability settings
            .set("acks", "1")
            .set("retries", "3")
            .set("retry.backoff.ms", "100")
            // Performance optimizations
            .set("max.in.flight.requests.per.connection", "5")
            .set("enable.idempotence", "true")
            .create()?;

        Ok(Self {
            producer,
            default_timeout: Duration::from_secs(5),
        })
    }

    /// Send a message to the specified topic
    pub async fn send<T>(&self, topic: &str, key: &str, payload: &T) -> Result<()> 
    where
        T: Serialize,
    {
        let payload_bytes = bincode::serialize(payload)?;
        let record: FutureRecord<String, Vec<u8>> = FutureRecord::to(topic)
            .key(key)
            .payload(&payload_bytes);

        match timeout(self.default_timeout, self.producer.send(record, Duration::from_secs(0))).await {
            Ok(Ok(_)) => {
                info!("Message sent successfully to topic: {}", topic);
                Ok(())
            }
            Ok(Err((e, _))) => {
                error!("Failed to send message to topic {}: {:?}", topic, e);
                Err(e.into())
            }
            Err(_) => {
                error!("Timeout sending message to topic: {}", topic);
                Err(anyhow::anyhow!("Send timeout"))
            }
        }
    }

    /// Send a batch of messages for improved throughput
    pub async fn send_batch<T>(&self, messages: Vec<(String, String, T)>) -> Result<Vec<Result<()>>>
    where
        T: Serialize,
    {
        let mut futures = Vec::new();
        for (topic, key, payload) in messages {
            let payload_bytes = bincode::serialize(&payload)?;
            let record: FutureRecord<String, Vec<u8>> = FutureRecord::to(&topic)
                .key(&key)
                .payload(&payload_bytes);
            futures.push(self.producer.send(record, Duration::from_secs(0)));
        }
        let results = futures::future::join_all(futures).await;
        Ok(results.into_iter().map(|r| r.map(|_| ()).map_err(|(e, _)| e.into())).collect())
    }
}

/// High-performance Kafka consumer optimized for Chrono-Swarm
pub struct SwarmConsumer {
    consumer: StreamConsumer,
}

impl SwarmConsumer {
    /// Create a new SwarmConsumer with optimized settings
    pub fn new(brokers: &str, group_id: &str) -> Result<Self> {
        let consumer: StreamConsumer = ClientConfig::new()
            .set("bootstrap.servers", brokers)
            .set("group.id", group_id)
            .set("enable.auto.commit", "true")
            .set("auto.commit.interval.ms", "1000")
            .set("session.timeout.ms", "30000")
            .set("heartbeat.interval.ms", "10000")
            // Fetch optimization
            .set("fetch.min.bytes", "1024")
            .set("fetch.max.wait.ms", "500")
            .set("max.partition.fetch.bytes", "1048576") // 1MB
            // Consumer position
            .set("auto.offset.reset", "earliest")
            // Compression
            .set("compression.type", "lz4")
            .create()?;
        Ok(Self { consumer })
    }

    /// Subscribe to topics
    pub fn subscribe(&self, topics: &[&str]) -> Result<()> {
        self.consumer.subscribe(topics)?;
        info!("Subscribed to topics: {:?}", topics);
        Ok(())
    }

    /// Process messages with a callback function
    pub async fn process_messages<F, T>(&self, mut callback: F) -> Result<()> 
    where
        F: FnMut(String, T) -> Result<()>,
        T: for<'de> Deserialize<'de>,
    {
        loop {
            match self.consumer.recv().await {
                Ok(message) => {
                    let key = message.key()
                        .map(|k| String::from_utf8_lossy(k).to_string())
                        .unwrap_or_else(|| "no-key".to_string());
                    if let Some(payload) = message.payload() {
                        match bincode::deserialize::<T>(payload) {
                            Ok(data) => {
                                if let Err(e) = callback(key, data) {
                                    error!("Error processing message: {:?}", e);
                                }
                            }
                            Err(e) => {
                                error!("Failed to deserialize message: {:?}", e);
                            }
                        }
                    }
                }
                Err(e) => {
                    error!("Error receiving message: {:?}", e);
                    tokio::time::sleep(Duration::from_millis(100)).await;
                }
            }
        }
    }
}

/// Core event types for the Chrono-Swarm nervous system
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SwarmEvent {
    TaskSubmitted {
        task_id: String,
        agent_type: String,
        priority: u8,
        payload: Vec<u8>,
    },
    TaskStarted {
        task_id: String,
        agent_id: String,
        node_id: String,
    },
    TaskCompleted {
        task_id: String,
        agent_id: String,
        result: TaskResult,
        execution_time_ms: u64,
    },
    TaskFailed {
        task_id: String,
        agent_id: String,
        error: String,
        retry_count: u32,
    },
    NodeJoined {
        node_id: String,
        node_type: NodeType,
        capabilities: Vec<String>,
    },
    NodeLeft {
        node_id: String,
        reason: String,
    },
    SystemMetrics {
        node_id: String,
        cpu_usage: f64,
        memory_usage: f64,
        active_agents: u32,
        timestamp: i64,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum TaskResult {
    Success(Vec<u8>),
    Partial(Vec<u8>),
    RequiresEvolution(Vec<u8>),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum NodeType {
    Controller,
    Executor,
    Hybrid,
}

/// Topic definitions for the Chrono-Swarm nervous system
pub mod topics {
    pub const ORCHESTRATION: &str = "orchestration";
    pub const TASKS_CRITICAL: &str = "tasks_critical";
    pub const TASKS_NORMAL: &str = "tasks_normal";
    pub const TASKS_BACKGROUND: &str = "tasks_background";
    pub const AGENT_RESULTS: &str = "agent_results";
    pub const SYSTEM_TELEMETRY: &str = "system_telemetry";
    pub const NODE_LIFECYCLE: &str = "node_lifecycle";
    pub const EVOLUTION_FEEDBACK: &str = "evolution_feedback";
}

#[cfg(test)]
mod tests {
    use super::*;
    use tokio;

    #[tokio::test]
    async fn test_producer_consumer_integration() {
        // Integration tests would go here
        // These would require a running Kafka instance
    }
}
