use actix_session::SessionMiddleware;
use actix_session::storage::CookieSessionStore;
use actix_web::cookie::Key;

// TODO The secret key would usually be read from a configuration file/environment variables.
fn get_secret_key() -> Key {
    let base = "a".repeat(64);
    let key = base.as_ref();
    Key::from(key)
}

pub fn new_session_store() -> SessionMiddleware<CookieSessionStore> {
    let secret_key = get_secret_key();
    let session_store = CookieSessionStore::default();
    SessionMiddleware::new(session_store, secret_key)
}
