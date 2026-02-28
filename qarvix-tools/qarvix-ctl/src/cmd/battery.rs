use anyhow::Result;
use clap::Args as ClapArgs;
use colored::Colorize;
use std::fs;

#[derive(ClapArgs)]
pub struct Args;

pub fn run(_args: Args) -> Result<()> {
    let base = "/sys/class/power_supply/BAT0";

    let status = fs::read_to_string(format!("{base}/status"))?
        .trim()
        .to_string();
    let capacity = fs::read_to_string(format!("{base}/capacity"))?
        .trim()
        .to_string();
    let energy_now: f64 = fs::read_to_string(format!("{base}/energy_now"))?
        .trim()
        .parse()?;
    let power_now: f64 = fs::read_to_string(format!("{base}/power_now"))?
        .trim()
        .parse()?;

    let cap: u8 = capacity.parse()?;
    let colored_cap = match cap {
        0..=20 => format!("{cap}%").red(),
        21..=50 => format!("{cap}%").yellow(),
        _ => format!("{cap}%").green(),
    };

    println!("{} {}", "Battery:".bold(), colored_cap);
    println!("{} {}", "Status:".bold(), status.cyan());

    if power_now > 0.0 {
        let hours = energy_now / power_now;
        let h = hours as u32;
        let m = ((hours - h as f64) * 60.0) as u32;
        let label = if status == "Charging" {
            "Until full"
        } else {
            "Remaining"
        };
        println!("{} {}h {}m", format!("{label}:").bold(), h, m);
    }

    Ok(())
}
