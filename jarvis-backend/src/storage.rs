use futures::stream::TryStreamExt;
use mongodb::options::FindOptions;
use mongodb::{bson::doc, options::ClientOptions, Client};

use crate::model::List;

pub async fn configure_client() -> Client {
    // TODO config
    // Parse a connection string into an options struct.
    let mut client_options = ClientOptions::parse("mongodb://localhost:27017")
        .await
        .unwrap();

    // Manually set an option.
    client_options.app_name = Some("My App".to_string());

    // Get a handle to the deployment.
    Client::with_options(client_options).unwrap()
}

pub async fn find_all_lists(db_client: &Client) -> Vec<List> {
    let db = db_client.database("jarvis");
    let coll = db.collection::<List>("lists");

    let filter = doc! {};
    let find_options = FindOptions::default();
    let mut cursor = coll.find(filter, find_options).await.unwrap();

    let mut lists: Vec<List> = Vec::new();

    while let Some(list) = cursor.try_next().await.unwrap() {
        lists.push(list);
    }

    lists
}
