use anyhow::Result;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();
    tracing::info!("Starting cs-orchestrator v0.1.0");
    
    // Keep service running
    tokio::signal::ctrl_c().await?;
    tracing::info!("Shutting down cs-orchestrator");
    Ok(())
}
