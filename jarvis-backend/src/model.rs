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
    pub fn new() -> Self {
        List {
            _id: None,
            no: None,
            reason: "Birthday".to_string(),
            occurs_at: chrono::Utc::now(),
            done: false,
            products: Some(Vec::new()),
        }
    }
}
