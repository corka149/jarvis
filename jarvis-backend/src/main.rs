use actix_session::SessionMiddleware;
use actix_session::storage::CookieSessionStore;
use actix_web::{App, HttpServer};
use actix_web::cookie::Key;

mod api_v1;
mod model;

// TODO The secret key would usually be read from a configuration file/environment variables.
fn get_secret_key() -> Key {
    Key::generate()
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let secret_key = get_secret_key();

    HttpServer::new(move || {
        App::new()
            .service(api_v1::api_v1())
            .wrap(SessionMiddleware::new(CookieSessionStore::default(), secret_key.clone()))
    })
        .bind(("127.0.0.1", 8080))?
        .run()
        .await
}
