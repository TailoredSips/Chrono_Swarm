//! Chrono-Swarm Cache Layer - Database and Redis Connection Management
//! 
//! This crate provides optimized connection pooling and caching for the
//! Chrono-Swarm system using PostgreSQL and Redis.


use anyhow::Result;
use deadpool_postgres::{Config as PgConfig, Pool as PgPool, Runtime};
use deadpool_redis::{Config as RedisConfig, Pool as RedisPool};
use serde::{Deserialize, Serialize};
use sqlx::postgres::PgPoolOptions;
use std::time::Duration;
use tokio_postgres::NoTls;
use tracing::{error, info};

/// Database connection pool manager
pub struct DatabasePool {
    pool: PgPool,
}

impl DatabasePool {
    /// Create a new database pool with optimized settings
    pub fn new(database_url: &str, max_connections: usize) -> Result<Self> {
        let mut config = PgConfig::new();
        config.url = Some(database_url.to_string());
        config.pool = Some(deadpool_postgres::PoolConfig {
            max_size: max_connections,
            timeouts: deadpool_postgres::Timeouts {
                wait: Some(Duration::from_secs(30)),
                create: Some(Duration::from_secs(30)),
                recycle: Some(Duration::from_secs(30)),
            },
        });

        let pool = config.create_pool(Some(Runtime::Tokio1), NoTls)?;
        
        info!("Database pool created with {} max connections", max_connections);
        
        Ok(Self { pool })
    }

    /// Get a connection from the pool
    pub async fn get_connection(&self) -> Result<deadpool_postgres::Object> {
        Ok(self.pool.get().await?)
    }

    /// Execute a query and return the number of affected rows
    pub async fn execute(&self, query: &str, params: &[&(dyn tokio_postgres::types::ToSql + Sync)]) -> Result<u64> {
        let client = self.get_connection().await?;
        let rows = client.execute(query, params).await?;
        Ok(rows)
    }

    /// Execute a query and return the results
    pub async fn query(&self, query: &str, params: &[&(dyn tokio_postgres::types::ToSql + Sync)]) -> Result<Vec<tokio_postgres::Row>> {
        let client = self.get_connection().await?;
        let rows = client.query(query, params).await?;
        Ok(rows)
    }

    /// Execute a query and return a single row
    pub async fn query_one(&self, query: &str, params: &[&(dyn tokio_postgres::types::ToSql + Sync)]) -> Result<tokio_postgres::Row> {
        let client = self.get_connection().await?;
        let row = client.query_one(query, params).await?;
        Ok(row)
    }

    /// Execute a query and return an optional single row
    pub async fn query_opt(&self, query: &str, params: &[&(dyn tokio_postgres::types::ToSql + Sync)]) -> Result<Option<tokio_postgres::Row>> {
        let client = self.get_connection().await?;
        let row = client.query_opt(query, params).await?;
        Ok(row)
    }

    /// Execute a prepared statement in a transaction
    pub async fn transaction<F, R>(&self, f: F) -> Result<R>
    where
        F: for<'a> FnOnce(&'a mut deadpool_postgres::Transaction<'a>) -> futures::future::BoxFuture<'a, Result<R>>,
    {
        let mut client = self.get_connection().await?;
        let mut transaction = client.transaction().await?;
        
        match f(&mut transaction).await {
            Ok(result) => {
                transaction.commit().await?;
                Ok(result)
            }
            Err(e) => {
                if let Err(rollback_err) = transaction.rollback().await {
                    error!("Failed to rollback transaction: {:?}", rollback_err);
                }
                Err(e)
            }
        }
    }
}

/// Redis connection pool manager
pub struct CachePool {
    pool: RedisPool,
}

impl CachePool {
    /// Create a new Redis pool with optimized settings
    pub fn new(redis_url: &str, max_connections: usize) -> Result<Self> {
        let mut config = RedisConfig::from_url(redis_url);
        config.pool = Some(deadpool_redis::PoolConfig {
            max_size: max_connections,
            timeouts: deadpool_redis::Timeouts {
                wait: Some(Duration::from_secs(10)),
                create: Some(Duration::from_secs(10)),
                recycle: Some(Duration::from_secs(10)),
            },
        });

        let pool = config.create_pool(Some(deadpool_redis::Runtime::Tokio1))?;
        
        info!("Redis pool created with {} max connections", max_connections);
        
        Ok(Self { pool })
    }

    /// Get a connection from the pool
    pub async fn get_connection(&self) -> Result<deadpool_redis::Connection> {
        Ok(self.pool.get().await?)
    }

    /// Set a value in the cache with TTL
    pub async fn set_with_ttl<T>(&self, key: &str, value: &T, ttl_seconds: u64) -> Result<()> 
    where
        T: Serialize,
    {
        let mut conn = self.get_connection().await?;
        let serialized = bincode::serialize(value)?;
        
        redis::pipe()
            .set(key, serialized)
            .expire(key, ttl_seconds as i64)
            .execute_async(&mut conn)
            .await?;
        
        Ok(())
    }

    /// Get a value from the cache
    pub async fn get<T>(&self, key: &str) -> Result<Option<T>>
    where
        T: for<'de> Deserialize<'de>,
    {
        let mut conn = self.get_connection().await?;
        let data: Option<Vec<u8>> = redis::cmd("GET")
            .arg(key)
            .query_async(&mut conn)
            .await?;
        
        match data {
            Some(bytes) => Ok(Some(bincode::deserialize(&bytes)?)),
            None => Ok(None),
        }
    }

    /// Delete a key from the cache
    pub async fn delete(&self, key: &str) -> Result<bool> {
        let mut conn = self.get_connection().await?;
        let deleted: i32 = redis::cmd("DEL")
            .arg(key)
            .query_async(&mut conn)
            .await?;
        
        Ok(deleted > 0)
    }

    /// Check if a key exists in the cache
    pub async fn exists(&self, key: &str) -> Result<bool> {
        let mut conn = self.get_connection().await?;
        let exists: bool = redis::cmd("EXISTS")
            .arg(key)
            .query_async(&mut conn)
            .await?;
        
        Ok(exists)
    }

    /// Increment a counter in the cache
    pub async fn increment(&self, key: &str, delta: i64) -> Result<i64> {
        let mut conn = self.get_connection().await?;
        let result: i64 = redis::cmd("INCRBY")
            .arg(key)
            .arg(delta)
            .query_async(&mut conn)
            .await?;
        
        Ok(result)
    }

    /// Set multiple values atomically
    pub async fn set_multiple<T>(&self, items: &[(&str, &T)]) -> Result<()> 
    where
        T: Serialize,
    {
        let mut conn = self.get_connection().await?;
        let mut pipe = redis::pipe();
        
        for (key, value) in items {
            let serialized = bincode::serialize(value)?;
            pipe.set(*key, serialized);
        }
        
        pipe.execute_async(&mut conn).await?;
        Ok(())
    }
}
