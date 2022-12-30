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

    #[command(subcommand)]
    pub command: Commands
}

#[derive(Subcommand)]
pub enum Commands {
    Server{}
}