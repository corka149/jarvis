use chrono::DateTime;
use mongodb::bson;
use mongodb::bson::oid::ObjectId;
use mongodb::bson::{doc, Document};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Organization {
    _id: ObjectId,
    uuid: bson::Uuid,
    name: String,
}

#[derive(Serialize, Deserialize)]
pub struct User {
    _id: ObjectId,
    pub uuid: bson::Uuid,
    pub organization_uuid: bson::Uuid,
    name: String,
    email: String,
    pub password: String,
}

#[derive(Serialize, Deserialize)]
pub struct Credentials {
    name: String,
    password: String,
}

#[derive(Serialize, Deserialize)]
pub struct Product {
    name: String,
    amount: i32,
}

impl Product {
    pub fn as_doc(&self) -> Document {
        doc! {
             "name": self.name.clone(),
             "amount": self.amount
        }
    }
}

#[derive(Serialize, Deserialize)]
pub struct List {
    _id: Option<ObjectId>,
    organization_uuid: bson::Uuid,
    no: Option<i32>,
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

    pub fn as_doc(&self, with_id: bool) -> Document {
        let mut product_docs: Vec<Document> = Vec::new();

        if let Some(products) = &self.products {
            for product in products {
                product_docs.push(product.as_doc())
            }
        }

        let mut doc = doc! {
            "no": self.no,
            "reason": self.reason.clone(),
            "occurs_at": self.occurs_at,
            "done": self.done,
            "products": product_docs
        };

        if with_id {
            doc.insert("_id", self._id);
        }

        doc
    }
}
