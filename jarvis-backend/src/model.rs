use crate::dto;
use chrono::DateTime;
use mongodb::bson;
use mongodb::bson::oid::ObjectId;
use mongodb::bson::{doc, Document, Uuid};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Organization {
    _id: ObjectId,
    uuid: Uuid,
    name: String,
}

#[derive(Serialize, Deserialize)]
pub struct User {
    pub _id: ObjectId,
    pub uuid: Uuid,
    pub organization_uuid: Uuid,
    pub name: String,
    pub email: String,
    pub password: String,
}

impl User {
    pub fn new(organization: Organization, name: &str, email: &str, password: &str) -> Self {
        Self {
            _id: ObjectId::new(),
            uuid: Uuid::new(),
            organization_uuid: organization.uuid,
            name: name.to_string(),
            email: email.to_string(),
            password: password.to_string()
        }
    }
}

#[derive(Serialize, Deserialize)]
pub struct Credentials {
    name: String,
    password: String,
}

#[derive(Serialize, Deserialize)]
pub struct Product {
    pub name: String,
    pub amount: i32,
}

impl Product {
    pub fn as_doc(&self) -> Document {
        doc! {
             "name": self.name.clone(),
             "amount": self.amount
        }
    }
}

impl From<dto::Product> for Product {
    fn from(dto: dto::Product) -> Self {
        Product {
            name: dto.name,
            amount: dto.amount,
        }
    }
}

#[derive(Serialize, Deserialize)]
pub struct List {
    pub _id: Option<ObjectId>,
    pub organization_uuid: Option<Uuid>,
    pub no: Option<i32>,
    pub reason: String,
    #[serde(with = "bson::serde_helpers::chrono_datetime_as_bson_datetime")]
    pub occurs_at: DateTime<chrono::Utc>,
    pub done: bool,
    pub products: Option<Vec<Product>>,
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
            doc.insert("organization_uuid", self.organization_uuid);
        }

        doc
    }
}

impl From<dto::List> for List {
    fn from(dto: dto::List) -> Self {
        let id: Option<ObjectId> = match dto.id {
            None => None,
            Some(id) => match ObjectId::parse_str(id) {
                Ok(id) => Some(id),
                Err(_) => None,
            },
        };

        let orga_id = match dto.organization_uuid {
            None => None,
            Some(orga_id) => match Uuid::parse_str(orga_id) {
                Ok(orga_id) => Some(orga_id),
                Err(_) => None,
            },
        };

        let mut products: Vec<Product> = Vec::new();

        if let Some(prods) = dto.products {
            for prod in prods {
                let mdl = prod.into();
                products.push(mdl);
            }
        }

        List {
            _id: id,
            organization_uuid: orga_id,
            no: dto.no,
            reason: dto.reason,
            occurs_at: dto.occurs_at,
            done: dto.done,
            products: Some(products),
        }
    }
}
