use chrono::DateTime;

use crate::model;
use chrono::serde::ts_seconds;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Product {
    pub(crate) name: String,
    pub(crate) amount: i32,
}

impl From<model::Product> for Product {
    fn from(dto: model::Product) -> Self {
        Product {
            name: dto.name,
            amount: dto.amount,
        }
    }
}

#[derive(Serialize, Deserialize)]
pub struct List {
    pub(crate) id: Option<String>,
    pub(crate) organization_uuid: Option<String>,
    pub(crate) no: Option<i32>,
    pub(crate) reason: String,
    #[serde(with = "ts_seconds")]
    pub(crate) occurs_at: DateTime<chrono::Utc>,
    pub(crate) done: bool,
    pub(crate) products: Option<Vec<Product>>,
}

impl From<model::List> for List {
    fn from(model: model::List) -> Self {
        let id: Option<String> = model._id.map(|id| id.to_string());

        let orga_id = model.organization_uuid.map(|orga_id| orga_id.to_string());

        let mut products: Vec<Product> = Vec::new();

        if let Some(prods) = model.products {
            for prod in prods {
                let mdl = prod.into();
                products.push(mdl);
            }
        }

        List {
            id,
            organization_uuid: orga_id,
            no: model.no,
            reason: model.reason,
            occurs_at: model.occurs_at,
            done: model.done,
            products: Some(products),
        }
    }
}
