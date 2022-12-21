use crate::configuration;
use futures::stream::TryStreamExt;
use mongodb::bson::oid::ObjectId;
use mongodb::options::{DeleteOptions, FindOneOptions, FindOptions, UpdateOptions};
use mongodb::{bson::doc, error, options::ClientOptions, results, Client, Collection};

use crate::model::{List, User};
use crate::security::UserData;

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
    pub async fn new(config: configuration::Database) -> MongoRepo {
        // Parse a connection string into an options struct.
        let client_options = ClientOptions::parse(config.connection)
            .await
            .expect("Could not parse options for MongoDB");

        // Get a handle to the deployment.
        let mongo_client =
            Client::with_options(client_options).expect("Could not build MongoDB client");

        MongoRepo { mongo_client }
    }

    fn list_coll(&self) -> Collection<List> {
        let db = self.mongo_client.database("jarvis");
        db.collection::<List>("lists")
    }

    fn user_coll(&self) -> Collection<User> {
        let db = self.mongo_client.database("jarvis");
        db.collection::<User>("users")
    }

    pub async fn find_all_lists(
        &self,
        user_data: UserData,
        show_closed: bool,
    ) -> Result<Vec<List>, error::Error> {
        let coll = self.list_coll();

        let mut filter = doc! {"organization_uuid": user_data.organization_uuid};

        if !show_closed {
            filter.insert("done", false);
        }

        let find_options = FindOptions::default();
        let mut cursor = coll.find(filter, find_options).await?;

        let mut lists: Vec<List> = Vec::new();

        while let Some(list) = cursor.try_next().await? {
            lists.push(list);
        }

        Ok(lists)
    }

    pub async fn find_list_by_id(
        &self,
        id: ObjectId,
        user_data: UserData,
    ) -> Result<Option<List>, error::Error> {
        let coll = self.list_coll();

        let filter = doc! { "_id": id, "organization_uuid": user_data.organization_uuid };
        let find_options = FindOneOptions::default();

        coll.find_one(filter, find_options).await
    }

    pub async fn find_user_by_email(&self, email: &str) -> Result<Option<User>, error::Error> {
        let coll = self.user_coll();

        let filter = doc! {"email": email};
        let find_options = FindOneOptions::default();

        coll.find_one(filter, find_options).await
    }

    pub async fn insert_list(
        &self,
        mut list: List,
        user_data: UserData,
    ) -> Result<List, error::Error> {
        list.gen_id();
        list.organization_uuid = Some(user_data.organization_uuid);
        let coll: Collection<List> = self.list_coll();
        coll.insert_one(&list, None).await?;
        Ok(list)
    }

    pub async fn delete_list_by_id(
        &self,
        id: ObjectId,
        user_data: UserData,
    ) -> error::Result<results::DeleteResult> {
        let coll: Collection<List> = self.list_coll();

        let filter = doc! { "_id": id, "organization_uuid": user_data.organization_uuid };
        let delete_options = DeleteOptions::default();

        coll.delete_one(filter, delete_options).await
    }

    pub async fn update_list(
        &self,
        id: ObjectId,
        list: List,
        user_data: UserData,
    ) -> error::Result<results::UpdateResult> {
        let coll: Collection<List> = self.list_coll();

        let filter = doc! { "_id": id, "organization_uuid": user_data.organization_uuid };
        let update_options = UpdateOptions::default();

        let update = doc! {
            "$set": list.as_doc(false)
        };

        coll.update_one(filter, update, update_options).await
    }
}
