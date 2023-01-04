mod api_v1;
mod cli;
mod configuration;
mod dto;
mod model;
mod security;
mod server;
mod storage;

fn main() -> std::io::Result<()> {
    cli::exec()
}
