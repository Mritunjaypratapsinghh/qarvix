mod cmd;
mod util;

use clap::Parser;
use cmd::{battery, brightness, power, update, volume, wifi};

#[derive(Parser)]
#[command(name = "qarvix-ctl", about = "Qarvix system control", version)]
enum Cli {
    /// Manage WiFi connections
    Wifi(wifi::Args),
    /// Control screen brightness
    Brightness(brightness::Args),
    /// Control audio volume
    Volume(volume::Args),
    /// Show battery status
    Battery(battery::Args),
    /// Set power profile
    Power(power::Args),
    /// System updates
    Update(update::Args),
}

fn main() -> anyhow::Result<()> {
    match Cli::parse() {
        Cli::Wifi(args) => wifi::run(args),
        Cli::Brightness(args) => brightness::run(args),
        Cli::Volume(args) => volume::run(args),
        Cli::Battery(args) => battery::run(args),
        Cli::Power(args) => power::run(args),
        Cli::Update(args) => update::run(args),
    }
}
