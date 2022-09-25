use mongodb::{options::ClientOptions, Client};

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
