#![forbid(unsafe_code)]

use std::{env, fs, path::Path, process::ExitCode};

use slic3r_flavors::prusa_wall_seam_summary_lines;

fn main() -> ExitCode {
    let args: Vec<_> = env::args().collect();
    let result = match args.as_slice() {
        [_, expected_wall_seam_summary] => run_summary(Path::new(expected_wall_seam_summary)),
        _ => Err("expected expected-wall-seam-summary.tsv".to_owned()),
    };

    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("error: {error}");
            ExitCode::FAILURE
        }
    }
}

fn run_summary(path: &Path) -> Result<(), String> {
    let input = fs::read_to_string(path)
        .map_err(|error| format!("failed to read {}: {error}", path.display()))?;
    let lines = prusa_wall_seam_summary_lines(&input).map_err(|error| {
        format!(
            "failed to summarize wall-seam {}: {error:?}",
            path.display()
        )
    })?;

    for line in lines {
        println!("{line}");
    }

    Ok(())
}
