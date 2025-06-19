// Chrono-Swarm - Proprietary Software
use thiserror::Error;

#[derive(Error, Debug)]
pub enum SwarmError {
    #[error("Internal error: {0}")]
    Internal(String),
}
