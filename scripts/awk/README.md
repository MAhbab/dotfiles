# gawk-tools 🪶

A modular command-line toolkit for handy `gawk` scripts, designed to grow gradually and stay easy to maintain.

## ✨ Overview

`gawk-tools` is a single-entry-point CLI that dispatches to useful `awk` scripts. It's meant for users who regularly do one-off data manipulations, CSV inspection, and text processing from the terminal—and want something scalable beyond a mess of aliases.

## 📦 Installation

Clone this repo and make the `gawk-tools` script executable:

```bash
git clone https://github.com/yourusername/gawk-tools.git
cd gawk-tools
chmod +x gawk-tools
```

Then optionally add it to your `PATH`:

```bash
echo 'export PATH="$HOME/path/to/gawk-tools:$PATH"' >> ~/.zshrc # or ~/.bashrc
source ~/.zshrc
```

Now you can run:

```bash
gawk-tools <command> [args...]
```

## 🔧 Available Commands

To see all available commands:

```bash
gawk-tools help
```

To get help for a specific command:

```bash
gawk-tools help <command>
```

## 🧪 Example Scripts

- `show-columns`: Print header columns of a CSV file with their index
- `bq-dryrun`: Parse BigQuery dry run output and show estimated bytes in GB

Each script is self-documented with a `# Usage:` comment and optional inline help.

## 🧱 Project Structure

```
gawk-tools/         # Entry-point script
├── scripts/        # Individual awk scripts
│   ├── show-columns.awk
│   └── bq-dryrun.awk
└── README.md
```

## 🧠 Philosophy

- One entry point (`gawk-tools`)
- Drop-in extensibility—just add scripts to `scripts/`
- Discoverable and documented (via `help`)

## 🪄 Coming Soon?

- Optional test runner
- Tab completion
- Shared libraries (`lib/`)
- Flag/arg parsing improvements

---
