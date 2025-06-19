// Chrono-Swarm - Proprietary Software
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SwarmEvent {
    TaskSubmitted { task_id: String, agent_type: String },
    TaskCompleted { task_id: String, agent_id: String },
    AgentSpawned { agent_id: String, node_id: String },
}
