/*!
cli contains the following commands:

* server
* orga
    * add
    * delete
    * show
* user
    * add
    * delete
    * passwd
    * show

 */

use std::io;
use std::process::exit;

use actix_web::rt::Runtime;
use clap::{Parser, Subcommand};

use crate::configuration::Configuration;
use crate::model::{Organization, User};
use crate::server::server;
use crate::storage::MongoRepo;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
pub struct Cli {
    /// Path to jARVIS config - will use CONFIG_PATH as fallback
    #[arg(short, long)]
    pub config_path: Option<String>,

    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Launches the jARVIS server
    Server {},
    /// User management
    User {
        #[command(subcommand)]
        command: UserCommands,
    },
    /// Management of organisations
    Orga {
        #[command(subcommand)]
        command: OrgaCommands,
    },
}

#[derive(Subcommand)]
pub enum UserCommands {
    /// Adds a new user
    Add {
        /// Name of the organization to which the user shall belong
        #[arg(short, long)]
        organization: String,

        /// Name of the new user
        #[arg(short, long)]
        name: String,

        /// E-Mail of the new user
        #[arg(short, long)]
        email: String,

        /// Password for accessing jARVIS
        #[arg(short, long)]
        password: String,
    },
    /// Outputs user information
    Show {
        /// E-Mail of user
        #[arg(short, long)]
        email: String,
    },
    /// Updates password of an user
    Passwd {
        /// E-Mail of user
        #[arg(short, long)]
        email: String,

        /// Password for accessing jARVIS
        #[arg(short, long)]
        password: String,
    },
    /// Deletes an user from the system
    Delete {
        /// E-Mail of user
        #[arg(short, long)]
        email: String,
    },
}

#[derive(Subcommand)]
pub enum OrgaCommands {
    /// Adds a new organisation
    Add {
        /// Name of the new organization
        #[arg(short, long)]
        name: String,
    },
    /// Show details of an organisation
    Show {
        /// Name of organization
        #[arg(short, long)]
        name: String,
    },
    /// Deletes an existing organisation
    Delete {
        /// Name of organization
        #[arg(short, long)]
        name: String,
        /// Forces to delete organization with user without prompt
        #[arg(short, long)]
        force: bool,
    },
}

pub fn exec() -> io::Result<()> {
    let cli: Cli = Cli::parse();
    let runtime = Runtime::new()?;

    let config_path: String = cli.config_path.unwrap_or_else(Configuration::path_from_env);

    runtime.block_on(async {
        let msg = "No configuration found (check '--help')";
        let config = Configuration::new(&config_path).expect(msg);
        let repo = MongoRepo::new(config.database.clone()).await;

        match &cli.command {
            Commands::Server {} => server(config).await,
            Commands::User { command } => handle_user_cmd(command, repo).await,
            Commands::Orga { command } => handle_orga_cmd(command, repo).await,
        }
    })
}

// ===== ===== USER CMD ===== =====

async fn handle_user_cmd(user_cmd: &UserCommands, repo: MongoRepo) -> std::io::Result<()> {
    match user_cmd {
        UserCommands::Add {
            organization,
            name,
            email,
            password,
        } => add_user(repo, organization, name, email, password).await,
        UserCommands::Show { email } => show_user(repo, email).await,
        UserCommands::Passwd { email, password } => passwd_user(repo, email, password).await,
        UserCommands::Delete { email } => delete_user(repo, email).await,
    }

    Ok(())
}

async fn add_user(repo: MongoRepo, organization: &str, name: &str, email: &str, password: &str) {
    if repo
        .find_user_by_email(email)
        .await
        .expect("Fail to check e-mail address")
        .is_some()
    {
        eprintln!("User with email {} already exists", email);
        return;
    }

    let passwd = bcrypt::hash(password, bcrypt::DEFAULT_COST).expect("Could not hash password");

    let msg = format!("Could not find organization with name {}", organization);

    if let Some(orga) = repo.find_orga_by_name(organization).await.expect(&msg) {
        let user = User::new(orga, name, email, &passwd);
        let user = repo.insert_user(user).await.expect("Could not create user");

        println!("Created user with id {}", user.uuid);
    } else {
        eprintln!("Could find organization with name {}", organization);
        exit(1);
    }
}

async fn show_user(repo: MongoRepo, email: &str) {
    if let Some(user) = repo
        .find_user_by_email(email)
        .await
        .expect("Failed to fetch user from database")
    {
        println!("{}", user);
        println!("Which belongs to the following organization");

        // Every user **must** belong to an organization
        let orga = repo
            .find_orga_by_uuid(&user.organization_uuid)
            .await
            .expect("Failed while fetching organization")
            .expect("User without organization");
        println!("{}", orga);
    } else {
        eprintln!("Could not find user with email {}", email);
        exit(1);
    }
}

async fn passwd_user(repo: MongoRepo, email: &str, password: &str) {
    let msg = "Failed to hash password";

    let passwd = bcrypt::hash(password, bcrypt::DEFAULT_COST).expect(msg);

    if repo
        .update_user(email, &passwd)
        .await
        .expect("Failed to update password of user")
    {
        println!("Updated password of user")
    } else {
        eprintln!("No user with email {} exists", email);
        exit(1);
    }
}

async fn delete_user(repo: MongoRepo, email: &str) {
    if repo
        .delete_user(email)
        .await
        .expect("Failed to delete user")
    {
        println!("Deleted user {}", email);
    } else {
        eprintln!("No user with email {} exists", email);
        exit(1);
    }
}

// ===== ===== ORGA CMD ===== =====

async fn handle_orga_cmd(orga_cmd: &OrgaCommands, repo: MongoRepo) -> io::Result<()> {
    match orga_cmd {
        OrgaCommands::Add { name } => add_orga(repo, name).await,
        OrgaCommands::Show { name } => show_orga(repo, name).await,
        OrgaCommands::Delete { name, force } => delete_orga(repo, name, force).await,
    }

    Ok(())
}

async fn add_orga(repo: MongoRepo, name: &str) {
    if repo
        .find_orga_by_name(name)
        .await
        .expect("Failed to check organization name")
        .is_some()
    {
        eprintln!("Organization with name '{}' already exists", name);
        exit(1);
    }

    let organization = Organization::new(name);

    let organization = repo
        .insert_orga(organization)
        .await
        .expect("Failed to create organization");

    println!("Create organization with id {}", organization.uuid);
}

async fn show_orga(repo: MongoRepo, name: &str) {
    let msg = "Failed to fetch orga";

    if let Some(orga) = repo.find_orga_by_name(name).await.expect(msg) {
        println!("{}", orga);
    } else {
        println!("No organization with name {} exists", name);
        exit(1);
    }
}

async fn delete_orga(repo: MongoRepo, name: &str, force: &bool) {
    if !*force && !confirm("Are you sure? This will also delete all users!") {
        exit(0);
    }

    if let Some(orga) = repo
        .find_orga_by_name(name)
        .await
        .expect("Failed to fetch organization")
    {
        let deleted = repo
            .delete_users_by_orga(orga)
            .await
            .expect("Failed to delete user/s");
        println!("Deleted {} users", deleted);
    }

    if repo
        .delete_orga(name)
        .await
        .expect("Failed to delete organization")
    {
        println!("Deleted organization {}", name);
    } else {
        eprintln!("No organization with name {} exists", name);
        exit(1);
    }
}

fn confirm(msg: &str) -> bool {
    println!("{} - yes or no?", msg);

    loop {
        let mut user_input = String::new();
        let stdin = io::stdin();
        if let Err(err) = stdin.read_line(&mut user_input) {
            eprintln!("{}", err);
            exit(1);
        }

        let user_input = user_input.trim();

        if user_input == "yes" || user_input == "no" {
            return user_input == "yes";
        }
    }
}

#[cfg(test)]
mod tests {
    use std::ops::Add;

    use uuid::Uuid;

    use crate::configuration::Database;

    use super::*;

    const CONN_URL: &str = "mongodb://localhost:27017";

    #[test]
    fn test_add_orga() {
        Runtime::new().unwrap().block_on(async {
            // Arrange
            let config = Database {
                connection: CONN_URL.to_string(),
            };
            let repo = MongoRepo::new(config).await;
            let orga_name = random_orga();

            // Act
            add_orga(repo.clone(), &orga_name).await;

            // Assert
            let orga = repo.find_orga_by_name(&orga_name).await.unwrap();
            assert!(orga.is_some());
            let orga = orga.unwrap();
            assert_eq!(orga.name, orga_name);
        });
    }

    fn random_orga() -> String {
        let uuid = Uuid::new_v4().to_string();
        String::from("an-orga-").add(&uuid)
    }
}
