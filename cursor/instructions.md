# Cursor AI Instructions

## Core Workflow
- **Primary OS**: Linux > macOS > WSL (ensure cross-platform compatibility)
- **Main Stack**: Python (3.10+), Terminal/CLI, HTML Reports
- **Tools**: `uv` (deps), `ruff` (lint/fmt), `pytest` (test)

## 🐍 Python Standards

### Style & Typing
- **Format**: `ruff` defaults (88 chars). Double quotes.
- **Type Hints**: STRICT. Use `list[str]`, `dict[str, Any]`, `str | None` (Py3.10+ union).
- **Paths**: ALWAYS use `pathlib.Path`, NEVER `os.path`.
- **Docs**: Google style docstrings for public APIs.

```python
from pathlib import Path

def process_data(input_path: Path, verbose: bool = False) -> list[dict[str, Any]]:
    """Process data file and return records."""
    if not input_path.exists():
        raise FileNotFoundError(f"Missing: {input_path}")
    ...
```

### CLI Tools (`typer` + `rich`)
Prefer `typer` for CLI structure and `rich` for output.

```python
import typer
from rich.console import Console

app = typer.Typer()
console = Console()

@app.command()
def main(name: str, count: int = typer.Option(1, help="Number of greetings")):
    for _ in range(count):
        console.print(f"Hello [bold green]{name}[/bold green]!")

if __name__ == "__main__":
    app()
```

### HTML Report Generation
- **Engine**: Use **Jinja2** for templating. Logic != Presentation.
- **Portability**: Embed CSS/JS/Images as base64 for single-file reports.
- **Data**: Use Pandas styling for tables.

```python
import base64
from jinja2 import Environment, FileSystemLoader

def generate_report(df: pd.DataFrame, image_path: Path) -> str:
    env = Environment(loader=FileSystemLoader("templates"))
    template = env.get_template("report.html")
    
    img_b64 = base64.b64encode(image_path.read_bytes()).decode()
    
    return template.render(
        table=df.to_html(classes="display", border=0),
        chart_data=img_b64,
        title="Analysis Report"
    )
```

## 🖥️ Shell Scripting
- **Strict Mode**: Always `set -euo pipefail`.
- **Cross-Platform**: Check `[[ "$OSTYPE" == "darwin"* ]]` for macOS.
- **Reuse**: Source `~/.dotfiles/scripts/utils/helpers.sh` when possible.

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Running on macOS..."
fi
```

## 🔒 Security
- **Secrets**: NEVER hardcode. Use `python-dotenv`.
- **Config**: See `env.example` for patterns.

```python
from dotenv import load_dotenv
import os

load_dotenv()
api_key = os.getenv("API_KEY")
if not api_key:
    raise ValueError("API_KEY not set")
```

## 🧪 Testing
- Use `pytest` with fixtures. Avoid `unittest` classes.
- Mock external calls (APIs, DBs).

```python
import pytest

@pytest.fixture
def sample_data():
    return {"id": 1, "value": "test"}

def test_process(sample_data):
    assert process(sample_data) == "processed"
```
