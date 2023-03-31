use std::process::exit;

mod api_v1;
mod cli;
mod configuration;
mod dto;
mod error;
mod model;
mod security;
mod server;
mod service;
mod storage;

fn main() {
    if let Err(err) = cli::exec() {
        eprintln!("{}", err);
        exit(1);
    }
}
