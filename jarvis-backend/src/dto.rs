use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
pub struct Credentials {
    name: String,
    password: String
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
            products: Some(Vec::new())
        }
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string(self).unwrap()
    }

    pub fn lists_to_json(lists: &Vec<List>) -> String {
        serde_json::to_string(lists).unwrap()
    }
}
