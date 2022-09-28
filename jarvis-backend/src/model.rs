use chrono::DateTime;
use mongodb::bson;
use mongodb::bson::oid::ObjectId;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Organization {
    uuid: String,
    name: String,
    users: Vec<User>,
}

#[derive(Serialize, Deserialize)]
pub struct User {
    uuid: String,
    name: String,
}

#[derive(Serialize, Deserialize)]
pub struct Credentials {
    name: String,
    password: String,
}

#[derive(Serialize, Deserialize)]
pub struct Product {
    name: String,
    amount: usize,
}

#[derive(Serialize, Deserialize)]
pub struct List {
    _id: Option<ObjectId>,
    no: Option<usize>,
    reason: String,
    #[serde(with = "bson::serde_helpers::chrono_datetime_as_bson_datetime")]
    occurs_at: DateTime<chrono::Utc>,
    done: bool,
    products: Option<Vec<Product>>,
}

impl List {
    /// Generates ID if not yet existing.
    pub fn gen_id(&mut self) {
        if self._id.is_none() {
            self._id = Some(ObjectId::new());
        }
    }
}
