use actix_web::{App, HttpServer};

mod api_v1;
mod model;
mod security;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(move || {
        App::new()
            .service(api_v1::api_v1())
            .wrap(security::new_session_store())
    })
        .bind(("127.0.0.1", 8080))?
        .run()
        .await
}
