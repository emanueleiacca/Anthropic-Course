from __future__ import annotations

import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"


def reset_docs_dir() -> None:
    if DOCS.exists():
        shutil.rmtree(DOCS)
    DOCS.mkdir(parents=True, exist_ok=True)


def copy_path(relative_path: str) -> None:
    source = ROOT / relative_path
    destination = DOCS / relative_path

    if source.is_dir():
        shutil.copytree(source, destination, dirs_exist_ok=True)
    else:
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)


def main() -> None:
    reset_docs_dir()

    for path in [
        "index.md",
        ".nav.yml",
        "Topics",
        "Courses",
        "Data",
        "assets",
    ]:
        copy_path(path)


if __name__ == "__main__":
    main()
