use anyhow::Result;
use clap::{Args as ClapArgs, Subcommand};
use colored::Colorize;
use std::fs;

const GOV_PATH: &str = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor";
const EPP_PATH: &str = "/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference";

#[derive(ClapArgs)]
pub struct Args {
    #[command(subcommand)]
    cmd: Option<Cmd>,
}

#[derive(Subcommand)]
enum Cmd {
    /// Maximum performance
    Performance,
    /// Balanced performance and battery
    Balanced,
    /// Maximum battery saving
    Saving,
}

pub fn run(args: Args) -> Result<()> {
    match args.cmd {
        None => status(),
        Some(Cmd::Performance) => set("performance", "performance"),
        Some(Cmd::Balanced) => set("powersave", "balance_performance"),
        Some(Cmd::Saving) => set("powersave", "power"),
    }
}

fn status() -> Result<()> {
    let gov = fs::read_to_string(GOV_PATH)?.trim().to_string();
    let epp = fs::read_to_string(EPP_PATH).unwrap_or_default().trim().to_string();
    println!("{} {}", "Governor:".bold(), gov.cyan());
    if !epp.is_empty() {
        println!("{} {}", "Energy pref:".bold(), epp.cyan());
    }
    Ok(())
}

fn set(governor: &str, epp: &str) -> Result<()> {
    let cpus = glob_cpu_paths()?;
    for cpu in &cpus {
        fs::write(format!("{cpu}/cpufreq/scaling_governor"), governor)?;
        let epp_path = format!("{cpu}/cpufreq/energy_performance_preference");
        if std::path::Path::new(&epp_path).exists() {
            fs::write(&epp_path, epp)?;
        }
    }
    println!("{} {} ({})", "Power:".bold(), governor.green(), epp);
    Ok(())
}

fn glob_cpu_paths() -> Result<Vec<String>> {
    let mut paths = Vec::new();
    for entry in fs::read_dir("/sys/devices/system/cpu")? {
        let name = entry?.file_name().to_string_lossy().to_string();
        if name.starts_with("cpu") && name[3..].chars().all(|c| c.is_ascii_digit()) {
            paths.push(format!("/sys/devices/system/cpu/{name}"));
        }
    }
    Ok(paths)
}
