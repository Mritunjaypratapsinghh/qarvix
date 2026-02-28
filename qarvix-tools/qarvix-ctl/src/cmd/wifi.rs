use crate::util;
use anyhow::Result;
use clap::{Args as ClapArgs, Subcommand};
use colored::Colorize;

#[derive(ClapArgs)]
pub struct Args {
    #[command(subcommand)]
    cmd: Cmd,
}

#[derive(Subcommand)]
enum Cmd {
    /// List available networks
    List,
    /// Connect to a network
    Connect { ssid: String },
    /// Disconnect from current network
    Disconnect,
    /// Show current connection
    Status,
}

pub fn run(args: Args) -> Result<()> {
    match args.cmd {
        Cmd::List => list(),
        Cmd::Connect { ssid } => connect(&ssid),
        Cmd::Disconnect => disconnect(),
        Cmd::Status => status(),
    }
}

fn list() -> Result<()> {
    let out = util::exec("iwctl", &["station", "wlan0", "get-networks"])?;
    println!("{}", "Available networks:".bold());
    println!("{out}");
    Ok(())
}

fn connect(ssid: &str) -> Result<()> {
    println!("Connecting to {}...", ssid.cyan());
    util::exec("iwctl", &["station", "wlan0", "connect", ssid])?;
    println!("{}", "Connected.".green());
    Ok(())
}

fn disconnect() -> Result<()> {
    util::exec("iwctl", &["station", "wlan0", "disconnect"])?;
    println!("{}", "Disconnected.".yellow());
    Ok(())
}

fn status() -> Result<()> {
    let out = util::exec("iwctl", &["station", "wlan0", "show"])?;
    println!("{out}");
    Ok(())
}
