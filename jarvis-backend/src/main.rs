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

fn new_session() -> SessionMiddleware<CookieSessionStore> {
    let secret_key = get_secret_key();
    let session_store = CookieSessionStore::default();
    SessionMiddleware::new(session_store, secret_key)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(move || {
        App::new()
            .service(api_v1::api_v1())
            .wrap(new_session())
    })
        .bind(("127.0.0.1", 8080))?
        .run()
        .await
}
