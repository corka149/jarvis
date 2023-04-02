use crate::configuration;
use crate::model::User;
use axum_sessions::async_session::MemoryStore;
use axum_sessions::SessionLayer;
use mongodb::bson;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct UserData {
    pub user_uuid: bson::Uuid,
    pub organization_uuid: bson::Uuid,
}

impl UserData {
    pub fn new(user: &User) -> Self {
        Self {
            user_uuid: user.uuid,
            organization_uuid: user.organization_uuid,
        }
    }
}

pub fn new_session_layer(security: &configuration::Security) -> SessionLayer<MemoryStore> {
    let store = MemoryStore::new();
    let secret_key = security.secret_key.clone();
    let secret = secret_key.as_ref();
    SessionLayer::new(store, secret).with_secure(false)
}
