use futures::stream::TryStreamExt;
use mongodb::bson::oid::ObjectId;
use mongodb::options::{DeleteOptions, FindOneOptions, FindOptions};
use mongodb::{bson::doc, error, options::ClientOptions, results, Client, Collection};

use crate::model::List;

pub struct MongoRepo {
    mongo_client: Client,
}

impl Clone for MongoRepo {
    fn clone(&self) -> Self {
        Self {
            mongo_client: self.mongo_client.clone(),
        }
    }
}

impl MongoRepo {
    pub async fn new() -> MongoRepo {
        // TODO config
        // Parse a connection string into an options struct.
        let client_options = ClientOptions::parse("mongodb://localhost:27017")
            .await
            .unwrap();

        // Get a handle to the deployment.
        let mongo_client = Client::with_options(client_options).unwrap();

        MongoRepo { mongo_client }
    }

    fn list_coll(&self) -> Collection<List> {
        let db = self.mongo_client.database("jarvis");
        db.collection::<List>("lists")
    }

    pub async fn find_all_lists(&self) -> Vec<List> {
        let coll = self.list_coll();

        let filter = doc! {};
        let find_options = FindOptions::default();
        let mut cursor = coll.find(filter, find_options).await.unwrap();

        let mut lists: Vec<List> = Vec::new();

        while let Some(list) = cursor.try_next().await.unwrap() {
            lists.push(list);
        }

        lists
    }

    pub async fn find_by_id(&self, id: ObjectId) -> Option<List> {
        let coll = self.list_coll();

        let filter = doc! { "_id": id  };
        let find_options = FindOneOptions::default();

        coll.find_one(filter, find_options).await.unwrap()
    }

    pub async fn insert_list(&self, mut list: List) -> List {
        list.gen_id();
        let coll: Collection<List> = self.list_coll();
        coll.insert_one(&list, None).await.unwrap();
        list
    }

    pub async fn delete_by_id(&self, id: ObjectId) -> error::Result<results::DeleteResult> {
        let coll: Collection<List> = self.list_coll();

        let filter = doc! { "_id": id  };
        let delete_options = DeleteOptions::default();

        coll.delete_one(filter, delete_options).await
    }
}
