use actix_web::cookie::Key;
use config::{Config, ConfigError, Environment, File};
use serde::Deserialize;
use std::env;

#[derive(Debug, Deserialize)]
pub struct Logging {
    pub level: String,
}

#[derive(Debug, Deserialize)]
pub struct Database {
    pub connection: String,
}

#[derive(Debug, Deserialize, Clone)]
pub struct Security {
    secret_key: String,
}

impl Security {
    pub fn get_key(&self) -> Key {
        let base = self.secret_key.clone();
        let key = base.as_ref();
        Key::from(key)
    }
}

#[derive(Debug, Deserialize)]
pub struct Configuration {
    pub logging: Logging,
    pub database: Database,
    pub security: Security,
}

impl Configuration {
    pub fn new() -> Result<Self, ConfigError> {
        let conf_path = env::var("CONFIG_PATH").unwrap_or_else(|_| "configuration.yaml".into());

        let c = Config::builder()
            .add_source(File::with_name(&conf_path).required(false))
            .add_source(Environment::with_prefix("jarvis"))
            .build()?;

        c.try_deserialize()
    }
}