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
    /// Get current brightness
    Get,
    /// Set brightness (0-100)
    Set { value: u8 },
    /// Increase brightness
    Up {
        #[arg(default_value = "5")]
        step: u8,
    },
    /// Decrease brightness
    Down {
        #[arg(default_value = "5")]
        step: u8,
    },
}

pub fn run(args: Args) -> Result<()> {
    match args.cmd {
        Cmd::Get => get(),
        Cmd::Set { value } => set(value),
        Cmd::Up { step } => up(step),
        Cmd::Down { step } => down(step),
    }
}

fn get() -> Result<()> {
    let val = util::exec("light", &["-G"])?;
    println!("Brightness: {}", format!("{val}%").cyan());
    Ok(())
}

fn set(value: u8) -> Result<()> {
    let v = value.min(100).to_string();
    util::exec("light", &["-S", &v])?;
    println!("Brightness: {}", format!("{v}%").cyan());
    Ok(())
}

fn up(step: u8) -> Result<()> {
    util::exec("light", &["-A", &step.to_string()])?;
    get()
}

fn down(step: u8) -> Result<()> {
    util::exec("light", &["-U", &step.to_string()])?;
    get()
}
