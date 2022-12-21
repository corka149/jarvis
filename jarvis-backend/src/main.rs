use crate::configuration::Configuration;
use crate::storage::MongoRepo;
use actix_files as fs;
use actix_web::middleware::Logger;
use actix_web::web::Data;
use actix_web::{App, HttpServer};
use env_logger::Env;

mod api_v1;
mod configuration;
mod dto;
mod model;
mod security;
mod storage;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let config = Configuration::new().expect("No configuration found");
    let mongo_repo = MongoRepo::new(config.database).await;
    let static_file_dir = config.static_file_dir;

    env_logger::init_from_env(Env::default().default_filter_or(config.logging.level));

    HttpServer::new(move || {
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
    .await
}
