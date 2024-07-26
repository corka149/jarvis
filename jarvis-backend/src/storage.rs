use futures::stream::TryStreamExt;
use mongodb::bson::oid::ObjectId;
use mongodb::bson::Uuid;
use mongodb::options::{
    DeleteOptions, FindOneOptions, FindOptions, InsertOneOptions, UpdateOptions,
};
use mongodb::{bson::doc, error, options::ClientOptions, results, Client, Collection};

use crate::configuration;
use crate::model::{Email, List, Organization, User};
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

    fn orga_coll(&self) -> Collection<Organization> {
        let db = self.mongo_client.database("jarvis");
        db.collection::<Organization>("organizations")
    }

    // ===== ===== LIST ===== =====

    pub async fn find_all_lists(
        &self,
        user_data: UserData,
        show_closed: bool,
    ) -> Result<Vec<List>, error::Error> {
        let coll = self.list_coll();

        let mut filter = doc! {"organization_uuid": user_data.organization_uuid};

        if !show_closed {
            filter.insert("done", false);
            filter.insert("deleted", false);
        }

        let mut find_options = FindOptions::default();
        find_options.sort = Some(doc! {
            "occurs_at": -1,
            "_id": 1
        });

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
    ) -> error::Result<results::UpdateResult> {
        let coll: Collection<List> = self.list_coll();

        let filter = doc! { "_id": id, "organization_uuid": user_data.organization_uuid };
        let update_options = UpdateOptions::default();

        let update = doc! {
            "$set": doc! {"deleted": true}
        };

        coll.update_one(filter, update, update_options).await
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

    // ===== ===== USER ===== =====

    pub async fn find_user_by_email(&self, email: &Email) -> Result<Option<User>, error::Error> {
        let coll = self.user_coll();

        let filter = doc! {"email": email.as_doc()};
        let find_options = FindOneOptions::default();

        coll.find_one(filter, find_options).await
    }

    pub async fn insert_user(&self, user: User) -> Result<User, error::Error> {
        let coll: Collection<User> = self.user_coll();
        coll.insert_one(&user, None).await?;
        Ok(user)
    }

    pub async fn delete_user(&self, email: &Email) -> Result<bool, error::Error> {
        let coll = self.user_coll();

        let filter = doc! {"email": email.as_doc()};
        let delete_options = DeleteOptions::default();

        coll.delete_one(filter, delete_options)
            .await
            .map(|r| r.deleted_count == 1)
    }

    pub async fn update_user(
        &self,
        email: &str,
        hashed_passwd: &str,
    ) -> Result<bool, error::Error> {
        let coll = self.user_coll();

        let filter = doc! {"email": email};
        let update = doc! {"$set": doc! {"password": hashed_passwd}};
        let update_options = UpdateOptions::default();

        coll.update_one(filter, update, update_options)
            .await
            .map(|r| r.modified_count == 1)
    }

    pub async fn delete_users_by_orga(
        &self,
        organization: Organization,
    ) -> Result<u64, error::Error> {
        let coll = self.user_coll();

        let filter = doc! {"organization_uuid": organization.uuid};
        let delete_options = DeleteOptions::default();

        coll.delete_many(filter, delete_options)
            .await
            .map(|r| r.deleted_count)
    }

    // ===== ===== ORGANIZATION ===== =====

    pub async fn insert_orga(
        &self,
        organization: Organization,
    ) -> Result<Organization, error::Error> {
        let coll = self.orga_coll();
        let options = InsertOneOptions::default();
        coll.insert_one(&organization, options).await?;
        Ok(organization)
    }

    pub async fn find_orga_by_name(
        &self,
        name: &str,
    ) -> Result<Option<Organization>, error::Error> {
        let coll = self.orga_coll();

        let filter = doc! {
            "name": name
        };

        let find_options = FindOneOptions::default();

        coll.find_one(filter, find_options).await
    }

    pub async fn find_orga_by_uuid(
        &self,
        uuid: &Uuid,
    ) -> Result<Option<Organization>, error::Error> {
        let coll = self.orga_coll();

        let filter = doc! {
            "uuid": uuid
        };

        let find_options = FindOneOptions::default();

        coll.find_one(filter, find_options).await
    }

    pub async fn delete_orga(&self, name: &str) -> Result<bool, error::Error> {
        let coll = self.orga_coll();

        let filter = doc! {"name": name};
        let delete_options = DeleteOptions::default();

        coll.delete_one(filter, delete_options)
            .await
            .map(|r| r.deleted_count == 1)
    }
}
