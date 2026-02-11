use crate::configuration;
use crate::model::User;
use mongodb::bson;
use serde::{Deserialize, Serialize};
use tower_sessions_cookie_store::{
    CookieSessionConfig, CookieSessionManagerLayer, Key, PrivateCookie,
};

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

pub fn new_session_layer(
    security: &configuration::Security,
) -> CookieSessionManagerLayer<PrivateCookie> {
    let secret_key = security.secret_key.clone();
    let key: Key = Key::from(secret_key.as_bytes());

    let config = CookieSessionConfig::default().with_secure(false); // set true in production (HTTPS)
    CookieSessionManagerLayer::private(key).with_config(config)
}
