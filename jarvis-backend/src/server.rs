use actix_files as fs;
use actix_web::middleware::Logger;
use actix_web::web::Data;
use actix_web::{App, HttpServer};
use axum_sessions::{async_session::MemoryStore, SessionLayer};
use env_logger::Env;

use crate::configuration;
use crate::configuration::Configuration;
use crate::error::JarvisError;
use crate::storage::MongoRepo;
use crate::{api_v1, security};

pub async fn server(config: Configuration) -> Result<(), JarvisError> {
    let mongo_repo = MongoRepo::new(config.database).await;
    let static_file_dir = config.static_file_dir;

    env_logger::init_from_env(Env::default().default_filter_or(config.logging.level));

    let result = HttpServer::new(move || {
        App::new()
            .app_data(Data::new(mongo_repo.clone()))
            .service(api_v1::api_v1())
            .service(fs::Files::new("/", static_file_dir.clone()).index_file("index.html"))
            .wrap(security::new_session_store(&config.security))
            .wrap(Logger::default())
            .wrap(Logger::new("%a %{User-Agent}i"))
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await;

    result.map_err(JarvisError::from)
}

// TODO
/*
   let session_layer = new_session_layer(config);

   let app = Router::new()
       .route(...)
       .layer(session_layer);
*/
pub fn new_session_layer(security: &configuration::Security) -> SessionLayer<MemoryStore> {
    let store = MemoryStore::new();
    let secret_key = security.secret_key.clone();
    let secret = secret_key.as_ref();
    SessionLayer::new(store, secret).with_secure(false)
}
