use config::{Config, ConfigError, Environment, File};
use serde::Deserialize;
use std::env;

#[derive(Debug, Deserialize)]
pub struct Logging {
    pub level: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Database {
    pub connection: String,
}

#[derive(Debug, Deserialize, Clone)]
pub struct Security {
    pub secret_key: String,
}

#[derive(Debug, Deserialize)]
pub struct Configuration {
    pub logging: Logging,
    pub database: Database,
    pub security: Security,
    pub static_file_dir: String,
}

impl Configuration {
    pub fn new(conf_path: &str) -> Result<Self, ConfigError> {
        let c = Config::builder()
            .add_source(File::with_name(conf_path).required(false))
            .add_source(Environment::with_prefix("jarvis"))
            .build()?;

        c.try_deserialize()
    }

    pub fn path_from_env() -> String {
        env::var("CONFIG_PATH").unwrap_or_else(|_| "configuration.yaml".into())
    }
}
