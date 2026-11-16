#!/usr/bin/env python3
"""Imports the documentation of the Playx ecosystem packages into doc/packages/<name>/.

The imported pages are the guides each package ships (for example
playx_core's doc/ folder or playx_navigation's docs/ folder). They are taken from the
version Playx uses, so the site always describes the APIs Playx 3.x ships with.

Usage (from the repository root):

    python3 tool/sync_package_docs.py \\
        --source playx_core=<dir with the doc folder>:2.0.0 ... \\
        --check-only   # optional: only report problems

Each --source is `name=<docs dir>:<version>`. `<docs dir>` is the package's `doc/` (pub.dev
archive, `~/.pub-cache/hosted/pub.dev/<name>-<version>/doc`) or `docs/` (GitHub) folder.
playx_navigation and playx_network do not publish their docs in the pub.dev archive, so
clone their repositories at the matching tag and pass their `docs/` folder.

The script:
  * strips Jekyll front matter and turns `{: .note }` callouts into MkDocs admonitions,
  * renames README.md / index.md to index.md and fixes links to them,
  * rewrites links that leave the docs folder to GitHub URLs at the version tag,
  * adds a source footer to every page.

It never edits files that are not part of a package's docs, so hand-written pages in
doc/packages/<name>/ (for example migration pages) are kept.
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
OUT_ROOT = REPO_ROOT / "doc" / "packages"
GITHUB = "https://github.com/playx-flutter"
PAGES = "https://playx-flutter.github.io"

# Files that are not guides (build files, changelog includes, ...).
SKIP_NAMES = {"_config.yml", "requirements.txt", "changelog.md", "llms.txt"}
SKIP_DIRS = {"stylesheets", "ci"}
ASSET_SUFFIXES = {".svg", ".png", ".jpg", ".jpeg", ".gif", ".webp"}

FRONT_MATTER = re.compile(r"\A---\n(.*?)\n---\n", re.DOTALL)
LINK = re.compile(r"(?<!\!)\[([^\]]*)\]\(([^)\s]+)(\s+\"[^\"]*\")?\)")
IMAGE = re.compile(r"!\[([^\]]*)\]\(([^)\s]+)\)")
CALLOUT = re.compile(r"^\{: \.(note|important|warning|highlight|new)\s*\}\n((?:[^\n]+\n?)+)", re.MULTILINE)
BUTTON = re.compile(r"\[([^\]]+)\]\(\{\{ site\.baseurl \}\}/([^)]*)\)\{: ([^}]*)\}")
JEKYLL_KIND = {
    "note": "note",
    "important": "warning",
    "warning": "warning",
    "highlight": "tip",
    "new": "tip",
}


def parse_front_matter(text: str) -> tuple[dict[str, str], str]:
    match = FRONT_MATTER.match(text)
    if not match:
        return {}, text
    meta: dict[str, str] = {}
    for line in match.group(1).splitlines():
        if ":" in line:
            key, value = line.split(":", 1)
            meta[key.strip()] = value.strip()
    return meta, text[match.end():]


def target_name(rel: Path) -> Path:
    """README.md and index.md both become index.md."""
    if rel.name.lower() in ("readme.md", "index.md"):
        return rel.with_name("index.md")
    return rel


BASEURL_LINK = re.compile(r"\{\{ site\.baseurl \}\}/([A-Za-z0-9_\-/]*)(#[^)\s]*)?")


def convert_baseurl_links(text: str, name: str) -> str:
    """Jekyll `{{ site.baseurl }}/page` links become relative `page.md` links."""

    def repl(match: re.Match[str]) -> str:
        page, anchor = match.group(1).strip("/"), match.group(2) or ""
        if page.startswith("api"):
            return f"{PAGES}/{name}/api/"
        return f"{page or 'index'}.md{anchor}"

    return BASEURL_LINK.sub(repl, text)


def convert_callouts(text: str) -> str:
    def repl(match: re.Match[str]) -> str:
        kind = JEKYLL_KIND[match.group(1)]
        body = match.group(2).rstrip("\n").splitlines()
        return f"!!! {kind}\n" + "\n".join(f"    {line}" for line in body) + "\n"

    return CALLOUT.sub(repl, text)


def convert_buttons(text: str, name: str, version: str) -> str:
    def repl(match: re.Match[str]) -> str:
        label, target, attrs = match.groups()
        target = target.strip("/")
        if target.startswith("api"):
            url = f"{PAGES}/{name}/api/"
        else:
            url = (target or "index") + ".md"
        classes = " ".join(
            c.replace(".btn-primary", ".md-button--primary").replace(".btn", ".md-button")
            for c in attrs.split()
        )
        return f"[{label}]({url}){{ {classes} }}"

    return BUTTON.sub(repl, text)


def rewrite_links(
    text: str, src_file: Path, src_root: Path, imported: set[Path], name: str, version: str
) -> tuple[str, list[str]]:
    problems: list[str] = []

    def fix(target: str) -> str:
        if re.match(r"^(https?:|mailto:|#)", target) or target.startswith("{{"):
            return target
        path_part, _, anchor = target.partition("#")
        anchor = f"#{anchor}" if anchor else ""
        if not path_part:
            return target
        resolved = (src_file.parent / path_part).resolve()
        try:
            rel = resolved.relative_to(src_root.resolve())
        except ValueError:
            # Leaves the docs folder: point at the repository at the version tag.
            return target  # handled below (needs repo-relative path)
        if rel in imported or rel.with_suffix(".md") in imported:
            mapped = target_name(rel if rel in imported else rel.with_suffix(".md"))
            new = Path(
                _relpath(OUT_ROOT / name / mapped, OUT_ROOT / name / target_name(src_file.relative_to(src_root)).parent)
            )
            return f"{new.as_posix()}{anchor}"
        if resolved.exists():
            return f"{GITHUB}/{name}/blob/{tag(name, version)}/{src_root.name}/{rel.as_posix()}{anchor}"
        if resolved.suffix == ".txt":
            # Generated files (llms.txt, ...) only exist on the published package site.
            return f"{PAGES}/{name}/{rel.as_posix()}{anchor}"
        problems.append(f"{src_file.relative_to(src_root)}: broken link {target}")
        return target

    def link_repl(match: re.Match[str]) -> str:
        label, target, title = match.group(1), match.group(2), match.group(3) or ""
        return f"[{label}]({fix(target)}{title})"

    def image_repl(match: re.Match[str]) -> str:
        return f"![{match.group(1)}]({fix(match.group(2))})"

    text = LINK.sub(link_repl, text)
    text = IMAGE.sub(image_repl, text)
    return text, problems


def _relpath(target: Path, start: Path) -> str:
    import os

    return os.path.relpath(target, start)


def tag(name: str, version: str) -> str:
    # The packages do not publish version tags, so link to the main branch.
    return "main"


def escape_outside_links(text: str, src_file: Path, src_root: Path, name: str, version: str) -> str:
    """Links like ../README.md leave the docs folder; point them at GitHub."""

    def repl(match: re.Match[str]) -> str:
        label, target, title = match.group(1), match.group(2), match.group(3) or ""
        if re.match(r"^(https?:|mailto:|#)", target) or target.startswith("{{"):
            return match.group(0)
        path_part, _, anchor = target.partition("#")
        if not path_part:
            return match.group(0)
        resolved = (src_file.parent / path_part).resolve()
        try:
            resolved.relative_to(src_root.resolve())
            return match.group(0)
        except ValueError:
            pass
        repo_rel = resolved.relative_to(src_root.resolve().parent) if src_root.resolve().parent in resolved.parents else None
        if repo_rel is None:
            return match.group(0)
        anchor = f"#{anchor}" if anchor else ""
        return f"[{label}]({GITHUB}/{name}/blob/{tag(name, version)}/{repo_rel.as_posix()}{anchor}{title})"

    return LINK.sub(repl, text)


def import_package(name: str, src_root: Path, version: str, check_only: bool) -> list[str]:
    problems: list[str] = []
    if not src_root.is_dir():
        return [f"{name}: source folder {src_root} does not exist"]

    files = sorted(
        p.relative_to(src_root)
        for p in src_root.rglob("*")
        if p.is_file()
        and p.name not in SKIP_NAMES
        and not any(part in SKIP_DIRS for part in p.relative_to(src_root).parts)
    )
    markdown = {f for f in files if f.suffix == ".md"}
    out_dir = OUT_ROOT / name

    for rel in sorted(files):
        src = src_root / rel
        dest = out_dir / (target_name(rel) if rel.suffix == ".md" else rel)
        if rel.suffix != ".md":
            if rel.suffix in ASSET_SUFFIXES and not check_only:
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(src, dest)
            continue

        text = src.read_text(encoding="utf-8")
        meta, body = parse_front_matter(text)
        body = convert_buttons(body, name, version)
        body = convert_baseurl_links(body, name)
        body = convert_callouts(body)
        body = escape_outside_links(body, src, src_root, name, version)
        body, file_problems = rewrite_links(body, src, src_root, markdown, name, version)
        problems += [f"{name}/{p}" for p in file_problems]
        if not re.search(r"^# ", body, re.MULTILINE) and meta.get("title"):
            body = f"# {meta['title']}\n\n{body.lstrip()}"
        source_url = f"{GITHUB}/{name}/blob/{tag(name, version)}/{src_root.name}/{rel.as_posix()}"
        footer = (
            "\n\n---\n\n"
            f"*Imported from the [{name} {version} documentation]({source_url}). "
            f"[Package site]({PAGES}/{name}/) · [pub.dev](https://pub.dev/packages/{name}).*\n"
        )
        if not check_only:
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_text(body.rstrip() + footer, encoding="utf-8")
    return problems


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("--source", action="append", default=[], required=True, metavar="NAME=DIR:VERSION")
    parser.add_argument("--check-only", action="store_true")
    args = parser.parse_args()

    problems: list[str] = []
    for spec in args.source:
        name, _, rest = spec.partition("=")
        directory, _, version = rest.rpartition(":")
        if not (name and directory and version):
            parser.error(f"bad --source {spec!r}")
        problems += import_package(name, Path(directory).expanduser(), version, args.check_only)

    for problem in problems:
        print(f"warning: {problem}", file=sys.stderr)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
