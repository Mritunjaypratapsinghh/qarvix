use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use colored::Colorize;
use serde::Deserialize;
use std::{collections::HashMap, fs, process::Command};

#[derive(Parser)]
#[command(
    name = "qarvix-dev",
    about = "Qarvix developer environment manager",
    version
)]
struct Cli {
    #[command(subcommand)]
    cmd: Cmd,
}

#[derive(Subcommand)]
enum Cmd {
    /// Initialize a new project from template
    Init {
        /// Project name
        name: String,
        /// Language/framework template
        #[arg(short, long)]
        template: String,
    },
    /// Spin up a dev environment with Docker
    Up {
        /// Path to qarvix-dev.toml (default: ./qarvix-dev.toml)
        #[arg(short, long, default_value = "qarvix-dev.toml")]
        config: String,
    },
    /// Tear down dev environment
    Down,
    /// List available templates
    Templates,
    /// Show dev environment status
    Status,
}

#[derive(Deserialize)]
struct DevConfig {
    name: String,
    services: HashMap<String, Service>,
}

#[derive(Deserialize)]
struct Service {
    image: String,
    ports: Option<Vec<String>>,
    volumes: Option<Vec<String>>,
    env: Option<HashMap<String, String>>,
}

fn main() -> Result<()> {
    match Cli::parse().cmd {
        Cmd::Init { name, template } => init(&name, &template),
        Cmd::Up { config } => up(&config),
        Cmd::Down => down(),
        Cmd::Templates => templates(),
        Cmd::Status => status(),
    }
}

fn templates() -> Result<()> {
    println!("{}", "Available templates:".bold());
    let list = [
        ("rust", "Rust + Cargo project"),
        ("node", "Node.js + npm project"),
        ("python", "Python + venv project"),
        ("go", "Go module project"),
        ("web", "HTML/CSS/JS static site"),
        ("api", "REST API (Rust + Actix)"),
        ("fullstack", "Frontend + Backend + DB"),
    ];
    for (name, desc) in list {
        println!("  {} - {}", name.cyan(), desc);
    }
    Ok(())
}

fn init(name: &str, template: &str) -> Result<()> {
    println!(
        "Creating {} with {} template...",
        name.cyan(),
        template.green()
    );

    fs::create_dir_all(name)?;

    match template {
        "rust" => init_rust(name)?,
        "node" => init_node(name)?,
        "python" => init_python(name)?,
        "go" => init_go(name)?,
        _ => anyhow::bail!("Unknown template: {template}. Run `qarvix-dev templates`"),
    }

    // Create default qarvix-dev.toml
    let dev_toml = format!(
        r#"name = "{name}"

[services.app]
image = "{img}"
ports = ["8080:8080"]
volumes = [".:/app"]
"#,
        name = name,
        img = match template {
            "rust" => "rust:latest",
            "node" => "node:lts-alpine",
            "python" => "python:3-slim",
            "go" => "golang:latest",
            _ => "alpine:latest",
        }
    );
    fs::write(format!("{name}/qarvix-dev.toml"), dev_toml)?;

    // Git init
    exec("git", &["init", name])?;

    println!("{} {} created!", "⚡".green(), name.cyan());
    println!("  cd {name} && qarvix-dev up");
    Ok(())
}

fn init_rust(name: &str) -> Result<()> {
    exec("cargo", &["init", name])?;
    Ok(())
}

fn init_node(name: &str) -> Result<()> {
    let pkg = format!(
        r#"{{"name":"{name}","version":"1.0.0","scripts":{{"start":"node index.js","dev":"node --watch index.js"}}}}"#
    );
    fs::write(format!("{name}/package.json"), pkg)?;
    fs::write(format!("{name}/index.js"), "console.log('⚡ Qarvix');\n")?;
    Ok(())
}

fn init_python(name: &str) -> Result<()> {
    fs::write(format!("{name}/main.py"), "print('⚡ Qarvix')\n")?;
    fs::write(format!("{name}/requirements.txt"), "")?;
    Ok(())
}

fn init_go(name: &str) -> Result<()> {
    let main = "package main\n\nimport \"fmt\"\n\nfunc main() {\n\tfmt.Println(\"⚡ Qarvix\")\n}\n"
        .to_string();
    fs::write(format!("{name}/main.go"), main)?;
    exec("go", &["mod", "init", name]).ok();
    Ok(())
}

fn up(config_path: &str) -> Result<()> {
    let content = fs::read_to_string(config_path)
        .with_context(|| format!("No {config_path} found. Run `qarvix-dev init`"))?;
    let config: DevConfig = toml::from_str(&content)?;

    println!("{} Starting {}...", "⚡".green(), config.name.cyan());

    for (svc_name, svc) in &config.services {
        let container_name = format!("qarvix-{}", svc_name);
        let mut args: Vec<String> =
            vec!["run".into(), "-d".into(), "--name".into(), container_name];

        if let Some(ports) = &svc.ports {
            for p in ports {
                args.push("-p".into());
                args.push(p.clone());
            }
        }
        if let Some(volumes) = &svc.volumes {
            for v in volumes {
                args.push("-v".into());
                args.push(v.clone());
            }
        }
        if let Some(env) = &svc.env {
            for (k, v) in env {
                args.push("-e".into());
                args.push(format!("{k}={v}"));
            }
        }
        args.push(svc.image.clone());

        let arg_refs: Vec<&str> = args.iter().map(|s| s.as_str()).collect();
        println!("  {} {}", "↑".green(), svc_name.cyan());
        exec("docker", &arg_refs)?;
    }

    println!("{}", "Dev environment running.".green());
    Ok(())
}

fn down() -> Result<()> {
    println!("{}", "Stopping dev environment...".yellow());
    let out = exec(
        "docker",
        &[
            "ps",
            "-a",
            "--filter",
            "name=qarvix-",
            "--format",
            "{{.Names}}",
        ],
    )?;
    for name in out.lines() {
        if !name.is_empty() {
            exec("docker", &["rm", "-f", name])?;
            println!("  {} {}", "↓".red(), name.cyan());
        }
    }
    println!("{}", "Stopped.".yellow());
    Ok(())
}

fn status() -> Result<()> {
    println!("{}", "Dev containers:".bold());
    let out = exec(
        "docker",
        &[
            "ps",
            "-a",
            "--filter",
            "name=qarvix-",
            "--format",
            "table {{.Names}}\t{{.Status}}\t{{.Ports}}",
        ],
    )?;
    if out.is_empty() {
        println!("  No running environments. Run `qarvix-dev up`");
    } else {
        println!("{out}");
    }
    Ok(())
}

fn exec(cmd: &str, args: &[&str]) -> Result<String> {
    let output = Command::new(cmd)
        .args(args)
        .output()
        .with_context(|| format!("failed to run: {cmd}"))?;
    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}
