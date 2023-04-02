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

use clap::{Parser, Subcommand};
use tokio::runtime::Runtime;

use crate::configuration::Configuration;
use crate::error::JarvisError;

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

pub fn exec() -> Result<(), JarvisError> {
    let cli: Cli = Cli::parse();
    let runtime = Runtime::new()?;

    let config_path: String = cli.config_path.unwrap_or_else(Configuration::path_from_env);

    runtime.block_on(async {
        let msg = "No configuration found (check '--help')";
        let config = Configuration::new(&config_path).expect(msg);
        let repo = MongoRepo::new(config.database.clone()).await;

        match &cli.command {
            Commands::Server {} => server(config).await,
            Commands::User { command } => user_cmd::handle_user_cmd(command, repo).await,
            Commands::Orga { command } => orga_cmd::handle_orga_cmd(command, repo).await,
        }
    })
}

// ===== ===== USER CMD ===== =====

mod user_cmd {
    use crate::cli::UserCommands;
    use crate::error::JarvisError;
    use crate::model::{Email, User};
    use crate::storage::MongoRepo;

    pub async fn handle_user_cmd(
        user_cmd: &UserCommands,
        repo: MongoRepo,
    ) -> Result<(), JarvisError> {
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
    }

    pub async fn add_user(
        repo: MongoRepo,
        organization: &str,
        name: &str,
        email: &str,
        password: &str,
    ) -> Result<(), JarvisError> {
        let email = Email::from(email)?;

        if repo
            .find_user_by_email(&email)
            .await
            .expect("Fail to check e-mail address")
            .is_some()
        {
            let msg = format!("User with email {} already exists", email);
            return Err(JarvisError::new(msg));
        }

        let passwd = bcrypt::hash(password, bcrypt::DEFAULT_COST).expect("Could not hash password");

        let msg = format!("Could not find organization with name {}", organization);

        if let Some(orga) = repo.find_orga_by_name(organization).await.expect(&msg) {
            let user = User::new(orga, name, email, &passwd);
            let user = repo.insert_user(user).await.expect("Could not create user");

            println!("Created user with id {}", user.uuid);
            Ok(())
        } else {
            let msg = format!("Could find organization with name {}", organization);
            Err(JarvisError::new(msg))
        }
    }

    pub async fn show_user(repo: MongoRepo, email: &str) -> Result<(), JarvisError> {
        let email = Email::from(email)?;

        if let Some(user) = repo
            .find_user_by_email(&email)
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
            Ok(())
        } else {
            let msg = format!("Could not find user with email {}", email);
            Err(JarvisError::new(msg))
        }
    }

    pub async fn passwd_user(
        repo: MongoRepo,
        email: &str,
        password: &str,
    ) -> Result<(), JarvisError> {
        let msg = "Failed to hash password";

        let passwd = bcrypt::hash(password, bcrypt::DEFAULT_COST).expect(msg);

        if repo
            .update_user(email, &passwd)
            .await
            .expect("Failed to update password of user")
        {
            println!("Updated password of user");
            Ok(())
        } else {
            let msg = format!("No user with email {} exists", email);
            Err(JarvisError::new(msg))
        }
    }

    pub async fn delete_user(repo: MongoRepo, email: &str) -> Result<(), JarvisError> {
        let email = Email::from(email)?;

        if repo
            .delete_user(&email)
            .await
            .expect("Failed to delete user")
        {
            println!("Deleted user {}", email);
            Ok(())
        } else {
            let msg = format!("No user with email {} exists", email);
            Err(JarvisError::new(msg))
        }
    }
}

// ===== ===== ORGA CMD ===== =====

mod orga_cmd {
    use crate::cli::OrgaCommands;
    use crate::error::JarvisError;
    use crate::model::Organization;
    use crate::storage::MongoRepo;
    use std::io;

    pub async fn handle_orga_cmd(
        orga_cmd: &OrgaCommands,
        repo: MongoRepo,
    ) -> Result<(), JarvisError> {
        match orga_cmd {
            OrgaCommands::Add { name } => add_orga(repo, name).await,
            OrgaCommands::Show { name } => show_orga(repo, name).await,
            OrgaCommands::Delete { name, force } => delete_orga(repo, name, force).await,
        }
    }

    pub async fn add_orga(repo: MongoRepo, name: &str) -> Result<(), JarvisError> {
        if repo
            .find_orga_by_name(name)
            .await
            .expect("Failed to check organization name")
            .is_some()
        {
            let msg = format!("Organization with name '{}' already exists", name);
            return Err(JarvisError::new(msg));
        }

        let organization = Organization::new(name);

        let organization = repo
            .insert_orga(organization)
            .await
            .expect("Failed to create organization");

        println!("Create organization with id {}", organization.uuid);
        Ok(())
    }

    pub async fn show_orga(repo: MongoRepo, name: &str) -> Result<(), JarvisError> {
        let msg = "Failed to fetch orga";

        if let Some(orga) = repo.find_orga_by_name(name).await.expect(msg) {
            println!("{}", orga);
            Ok(())
        } else {
            let msg = format!("No organization with name {} exists", name);
            Err(JarvisError::new(msg))
        }
    }

    pub async fn delete_orga(repo: MongoRepo, name: &str, force: &bool) -> Result<(), JarvisError> {
        if !*force && !confirm("Are you sure? This will also delete all users!") {
            return Ok(());
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
            Ok(())
        } else {
            let msg = format!("No organization with name {} exists", name);
            Err(JarvisError::new(msg))
        }
    }

    fn confirm(msg: &str) -> bool {
        println!("{} - yes or no?", msg);

        loop {
            let mut user_input = String::new();
            let stdin = io::stdin();
            if let Err(err) = stdin.read_line(&mut user_input) {
                eprintln!("{}", err);
                return false;
            }

            let user_input = user_input.trim();

            if user_input == "yes" || user_input == "no" {
                return user_input == "yes";
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use std::env;
    use std::ops::Add;

    use uuid::Uuid;

    use crate::configuration::Database;
    use crate::model::Email;

    use super::*;

    #[test]
    fn test_add_orga_with_success() {
        runtime().block_on(async {
            // Arrange
            let repo = mongo_repo().await;
            let orga_name = random_orga();

            // Act
            let success = orga_cmd::add_orga(repo.clone(), &orga_name).await.is_ok();

            // Assert
            assert!(success, "Adding orga failed");
            let orga = repo.find_orga_by_name(&orga_name).await.unwrap();
            assert!(orga.is_some(), "Could not find new orga");
            let orga = orga.unwrap();
            assert_eq!(orga.name, orga_name);
        });
    }

    #[test]
    fn test_add_orga_when_orga_with_name_already_exists() {
        runtime().block_on(async {
            // Arrange
            let repo = mongo_repo().await;
            let orga_name = random_orga();

            // Act & Assert
            let success = orga_cmd::add_orga(repo.clone(), &orga_name).await.is_ok();
            assert!(success, "Adding orga failed");

            let failed = orga_cmd::add_orga(repo.clone(), &orga_name).await.is_err();
            assert!(
                failed,
                "Adding an orga with the same name twice should fail"
            );
        });
    }

    #[test]
    fn test_show_orga_which_exists() {
        runtime().block_on(async {
            // Arrange
            let repo = mongo_repo().await;
            let orga_name = random_orga();
            let success = orga_cmd::add_orga(repo.clone(), &orga_name).await.is_ok();
            assert!(success, "Adding orga failed");

            // Act
            let success = orga_cmd::show_orga(repo, &orga_name).await.is_ok();

            // Assert
            assert!(success);
        });
    }

    #[test]
    fn test_show_orga_which_is_missing() {
        runtime().block_on(async {
            // Arrange
            let repo = mongo_repo().await;
            let orga_name = random_orga();

            // Act
            let success = orga_cmd::show_orga(repo, &orga_name).await.is_ok();

            // Assert
            assert!(
                !success,
                "Should not be able to show an orga which does not exists"
            );
        });
    }

    #[test]
    fn test_delete_orga_with_force() {
        runtime().block_on(async {
            // Arrange
            let repo = mongo_repo().await;
            let first_orga_name = random_orga();
            let success = orga_cmd::add_orga(repo.clone(), &first_orga_name)
                .await
                .is_ok();
            assert!(success, "Adding second orga failed");
            let second_orga_name = random_orga();
            let success = orga_cmd::add_orga(repo.clone(), &second_orga_name)
                .await
                .is_ok();
            assert!(success, "Adding first orga failed");

            // Act
            let success = orga_cmd::delete_orga(repo.clone(), &second_orga_name, &true)
                .await
                .is_ok();

            // Assert
            assert!(success);

            let is_missing = repo
                .find_orga_by_name(&second_orga_name)
                .await
                .unwrap()
                .is_none();
            assert!(is_missing, "Found deleted orga");

            let should_exists = repo
                .find_orga_by_name(&first_orga_name)
                .await
                .unwrap()
                .is_some();
            assert!(should_exists, "Orga is missing which should not be deleted");
        });
    }

    #[test]
    fn test_add_user_with_success() {
        runtime().block_on(async {
            // Arrange
            let repo = mongo_repo().await;
            let orga_name = random_orga();
            let email = random_email();
            let success = orga_cmd::add_orga(repo.clone(), &orga_name).await.is_ok();
            assert!(success, "Adding orga failed");

            // Act
            let success = user_cmd::add_user(repo.clone(), &orga_name, "Alice", &email, "passwd")
                .await
                .is_ok();

            // Assert
            assert!(success, "Failed to create new user");

            let expected_email = Email::from(&email).unwrap();

            let user = repo
                .find_user_by_email(&expected_email)
                .await
                .expect("Failed to fetch user");
            assert!(user.is_some(), "No user in database");

            let user = user.unwrap();
            assert_eq!(user.email, expected_email);
            assert_eq!(user.name, "Alice");
            assert!(
                !user.password.trim().is_empty(),
                "Password should not be empty"
            );
        });
    }

    #[test]
    fn test_add_user_when_already_exists() {
        runtime().block_on(async {
            // Arrange
            let repo = mongo_repo().await;
            let orga_name = random_orga();
            let email = random_email();
            let success = orga_cmd::add_orga(repo.clone(), &orga_name).await.is_ok();
            assert!(success, "Adding orga failed");
            let success = user_cmd::add_user(repo.clone(), &orga_name, "Alice", &email, "passwd")
                .await
                .is_ok();
            assert!(success, "Failed to create new user");

            // Act
            let failed = user_cmd::add_user(repo.clone(), &orga_name, "Alice", &email, "passwd")
                .await
                .is_err();

            // Assert
            assert!(
                failed,
                "Should not be able to create an user with same email again"
            );
        });
    }

    #[test]
    fn test_delete_user() {
        runtime().block_on(async {
            // Arrange
            let repo = mongo_repo().await;
            let orga_name = random_orga();
            let email = random_email();
            let success = orga_cmd::add_orga(repo.clone(), &orga_name).await.is_ok();
            assert!(success, "Adding orga failed");
            let success = user_cmd::add_user(repo.clone(), &orga_name, "Alice", &email, "passwd")
                .await
                .is_ok();
            assert!(success, "Failed to create new user");

            // Act
            let success = user_cmd::delete_user(repo.clone(), &email).await.is_ok();

            // Assert
            assert!(success, "Failed to delete user");

            let email = Email::from(&email).unwrap();

            let user = repo
                .find_user_by_email(&email)
                .await
                .expect("Failed to fetch from DB");
            assert!(user.is_none(), "Found user which should be deleted");
        });
    }

    #[test]
    fn test_show_user() {
        runtime().block_on(async {
            // Arrange
            let repo = mongo_repo().await;
            let orga_name = random_orga();
            let email = random_email();
            let success = orga_cmd::add_orga(repo.clone(), &orga_name).await.is_ok();
            assert!(success, "Adding orga failed");
            let success = user_cmd::add_user(repo.clone(), &orga_name, "Alice", &email, "passwd")
                .await
                .is_ok();
            assert!(success, "Failed to create new user");

            // Act
            let success = user_cmd::show_user(repo, &email).await.is_ok();

            // Assert
            assert!(success, "Failed to show user");
        });
    }

    #[test]
    fn test_show_user_when_user_does_not_exists() {
        runtime().block_on(async {
            // Arrange
            let repo = mongo_repo().await;
            let email = random_email();

            // Act
            let failed = user_cmd::delete_user(repo, &email).await.is_err();

            // Assert
            assert!(
                failed,
                "Should not be able to show an user which does not exists"
            );
        });
    }

    // Helper

    fn mongo_url() -> String {
        let mongo_host = env::var("MONGODB_HOST").unwrap_or_else(|_| "localhost".to_string());
        let mongo_port = env::var("MONGODB_PORT").unwrap_or_else(|_| "27017".to_string());

        format!("mongodb://{}:{}", mongo_host, mongo_port)
    }

    fn random_orga() -> String {
        let uuid = Uuid::new_v4().to_string();
        String::from("an-orga-").add(&uuid)
    }

    fn random_email() -> String {
        let uuid = Uuid::new_v4().to_string();
        format!("{}@example.xyz", uuid)
    }

    fn runtime() -> Runtime {
        Runtime::new().unwrap()
    }

    async fn mongo_repo() -> MongoRepo {
        let config = Database {
            connection: mongo_url(),
        };
        MongoRepo::new(config).await
    }
}
