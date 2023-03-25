use crate::configuration;
use axum_sessions::{async_session::MemoryStore, SessionLayer};

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
