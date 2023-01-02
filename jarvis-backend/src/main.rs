use actix_web::rt::Runtime;
use clap::Parser;

use crate::cli::{Cli, Commands, UserCommands};
use crate::configuration::Configuration;
use crate::model::User;
use crate::server::server;
use crate::storage::MongoRepo;

mod api_v1;
mod cli;
mod configuration;
mod dto;
mod model;
mod security;
mod storage;
mod server;

fn main() -> std::io::Result<()> {
    let cli: Cli = Cli::parse();
    let rt = Runtime::new()?;

    rt.block_on(async {
        let msg = "No configuration found (check your environment variable CONFIG_PATH)";
        let config = Configuration::new().expect(msg);
        let repo = MongoRepo::new(config.database.clone()).await;

        match &cli.command {
            Commands::Server {} => server(config).await,
            Commands::User { command: user_cmd } => handle_user_cmd(user_cmd, repo).await
        }
    })
}

async fn handle_user_cmd(user_cmd: &UserCommands, repo: MongoRepo) -> std::io::Result<()> {
    match user_cmd {
        UserCommands::Add { organization, name, email, password } =>
            add_user(repo, organization, name, email, password).await,
        UserCommands::Show { .. } => {}
        UserCommands::Passwd { .. } => {}
        UserCommands::Delete { .. } => {}
    }

    Ok(())
}

async fn add_user(repo: MongoRepo, organization: &str, name: &str, email: &str, password: &str) {
    if repo.find_user_by_email(email).await.expect("Fail to check e-mail address").is_some() {
        println!("User with email {} already exists", email);
        return;
    }

    let passwd = bcrypt::hash(password, bcrypt::DEFAULT_COST).expect("Could not hash password");

    let msg = format!("Could not find organization with name {}", organization);

    if let Some(orga) = repo.find_orga_by_name(organization).await.expect(&msg) {
        let user = User::new(orga, name, email, &passwd);
        let user = repo.insert_user(user).await.expect("Could not create user");

        println!("Created user with id {}", user.uuid);
    } else {
        println!("Could find organization with name {}", organization);
    }
}
