mod api_v1;

use actix_web::{App, HttpServer};


#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new().service(api_v1::api_v1())
    })
        .bind(("127.0.0.1", 8080))?
        .run()
        .await
}
