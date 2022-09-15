use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Organization {
    uuid: String,
    name: String,
    users: Vec<User>
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
    id: Option<String>,
    no: Option<usize>,
    reason: String,
    occurs_at: String,
    done: bool,
    products: Option<Vec<Product>>,
}

impl List {
    pub fn new() -> Self {
        List {
            id: None,
            no: None,
            reason: "Birthday".to_string(),
            occurs_at: "2022-08-11T12:00".to_string(),
            done: false,
            products: Some(Vec::new()),
        }
    }
}
