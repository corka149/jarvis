use axum_sessions::{async_session::MemoryStore, SessionLayer};
use env_logger::Env;
use tower_http::services::{ServeDir, ServeFile};

use crate::api_v1;
use crate::configuration;
use crate::configuration::Configuration;
use crate::error::JarvisError;
use crate::storage::MongoRepo;

pub async fn server(config: Configuration) -> Result<(), JarvisError> {
    let mongo_repo = MongoRepo::new(config.database).await;
    let session_layer = new_session_layer(&config.security);

    let static_file_dir = config.static_file_dir;
    let index_html = format!("{}/index.html", static_file_dir);
    let serve_dir = ServeDir::new(static_file_dir).not_found_service(ServeFile::new(index_html));

    env_logger::init_from_env(Env::default().default_filter_or(config.logging.level));

    let app = api_v1::api_v1_a(mongo_repo)
        .layer(session_layer)
        .nest_service("", serve_dir);

    axum::Server::bind(&"0.0.0.0:8080".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .map_err(|e| {
            let err = format!("{:?}", e);
            JarvisError::new(err)
        })
}

fn new_session_layer(security: &configuration::Security) -> SessionLayer<MemoryStore> {
    let store = MemoryStore::new();
    let secret_key = security.secret_key.clone();
    let secret = secret_key.as_ref();
    SessionLayer::new(store, secret).with_secure(false)
}
