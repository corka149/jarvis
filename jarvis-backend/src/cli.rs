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

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
pub struct Cli {

    /// Path to jARVIS config - will use CONFIG_PATH as fallback
    #[arg(short, long)]
    pub config_path: Option<String>,

    #[command(subcommand)]
    pub command: Commands
}

#[derive(Subcommand)]
pub enum Commands {
    /// Launches the jARVIS server
    Server{},
    /// User management
    User{
        #[command(subcommand)]
        command: UserCommands
    }
}

#[derive(Subcommand)]
pub enum UserCommands {
    /// Adds a new user
    Add{
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
    Show{
        /// E-Mail of the new user
        #[arg(short, long)]
        email: String,
    },
    /// Updates password of an user
    Passwd{
        /// E-Mail of the new user
        #[arg(short, long)]
        email: String,

        /// Password for accessing jARVIS
        #[arg(short, long)]
        password: String,
    },
    /// Deletes an user from the system
    Delete{
        /// E-Mail of the new user
        #[arg(short, long)]
        email: String,
    }
}
