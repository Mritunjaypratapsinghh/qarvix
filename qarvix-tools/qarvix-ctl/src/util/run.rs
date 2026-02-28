use anyhow::{Context, Result};
use std::process::Command;

pub fn exec(cmd: &str, args: &[&str]) -> Result<String> {
    let output = Command::new(cmd)
        .args(args)
        .output()
        .with_context(|| format!("failed to run: {cmd}"))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("{cmd} failed: {stderr}");
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}
