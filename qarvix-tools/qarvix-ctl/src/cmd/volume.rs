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
    /// Get current volume
    Get,
    /// Set volume (0-100)
    Set { value: u8 },
    /// Increase volume
    Up {
        #[arg(default_value = "5")]
        step: u8,
    },
    /// Decrease volume
    Down {
        #[arg(default_value = "5")]
        step: u8,
    },
    /// Toggle mute
    Mute,
}

pub fn run(args: Args) -> Result<()> {
    match args.cmd {
        Cmd::Get => get(),
        Cmd::Set { value } => set(value),
        Cmd::Up { step } => up(step),
        Cmd::Down { step } => down(step),
        Cmd::Mute => mute(),
    }
}

fn get() -> Result<()> {
    let out = util::exec("wpctl", &["get-volume", "@DEFAULT_AUDIO_SINK@"])?;
    println!("Volume: {}", out.cyan());
    Ok(())
}

fn set(value: u8) -> Result<()> {
    let v = format!("{}%", value.min(100));
    util::exec("wpctl", &["set-volume", "@DEFAULT_AUDIO_SINK@", &v])?;
    get()
}

fn up(step: u8) -> Result<()> {
    let v = format!("{}%+", step);
    util::exec("wpctl", &["set-volume", "@DEFAULT_AUDIO_SINK@", &v])?;
    get()
}

fn down(step: u8) -> Result<()> {
    let v = format!("{}%-", step);
    util::exec("wpctl", &["set-volume", "@DEFAULT_AUDIO_SINK@", &v])?;
    get()
}

fn mute() -> Result<()> {
    util::exec("wpctl", &["set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])?;
    println!("{}", "Mute toggled.".yellow());
    Ok(())
}
