use actix_web::rt::Runtime;
use clap::Parser;

use crate::cli::{Cli, Commands};
use crate::server::server;

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

    match &cli.command {
        Commands::Server{} => rt.block_on(server())
    }
}
