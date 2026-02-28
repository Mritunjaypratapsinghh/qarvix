use crate::util;
use anyhow::Result;
use clap::{Args as ClapArgs, Subcommand};
use colored::Colorize;

#[derive(ClapArgs)]
pub struct Args {
    #[command(subcommand)]
    cmd: Option<Cmd>,
}

#[derive(Subcommand)]
enum Cmd {
    /// Check for updates
    Check,
    /// Install all updates
    Install,
    /// Search for a package
    Search { query: String },
    /// Install a package
    Add { package: String },
    /// Remove a package
    Remove { package: String },
}

pub fn run(args: Args) -> Result<()> {
    match args.cmd {
        None | Some(Cmd::Check) => check(),
        Some(Cmd::Install) => install(),
        Some(Cmd::Search { query }) => search(&query),
        Some(Cmd::Add { package }) => add(&package),
        Some(Cmd::Remove { package }) => remove(&package),
    }
}

fn check() -> Result<()> {
    println!("{}", "Checking for updates...".bold());
    util::exec("xbps-install", &["-Sun"])?;
    Ok(())
}

fn install() -> Result<()> {
    println!("{}", "Installing updates...".bold());
    let out = util::exec("xbps-install", &["-Syu"])?;
    println!("{out}");
    println!("{}", "System updated.".green());
    Ok(())
}

fn search(query: &str) -> Result<()> {
    let out = util::exec("xbps-query", &["-Rs", query])?;
    println!("{out}");
    Ok(())
}

fn add(package: &str) -> Result<()> {
    println!("Installing {}...", package.cyan());
    let out = util::exec("xbps-install", &["-S", package])?;
    println!("{out}");
    println!("{} {}", package.cyan(), "installed.".green());
    Ok(())
}

fn remove(package: &str) -> Result<()> {
    println!("Removing {}...", package.cyan());
    let out = util::exec("xbps-remove", &["-R", package])?;
    println!("{out}");
    println!("{} {}", package.cyan(), "removed.".yellow());
    Ok(())
}
