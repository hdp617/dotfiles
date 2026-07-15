#!/usr/bin/env python3
"""Maintain commit-pinned chezmoi archive externals.

Parses GitHub archive pins in .chezmoiexternal.toml, scans pinned commits via
the OSV API, and optionally bumps pins to each repo's default-branch HEAD
(rewriting url + checksum.sha256 in place).
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import ssl
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_EXTERNAL = ROOT / ".chezmoiexternal.toml"

ARCHIVE_URL_RE = re.compile(
    r'url\s*=\s*"https://github\.com/(?P<owner>[^/"]+)/(?P<repo>[^/"]+)/'
    r'archive/(?P<commit>[0-9a-fA-F]{7,40})\.tar\.gz"'
)
SHA256_RE = re.compile(r'(sha256\s*=\s*")([0-9a-fA-F]{64})(")')

USER_AGENT = "hdp617-dotfiles-chezmoi-externals/1.0"
OSV_QUERYBATCH = "https://api.osv.dev/v1/querybatch"


@dataclass(frozen=True)
class Pin:
    owner: str
    repo: str
    commit: str
    url_span: tuple[int, int]
    sha_span: tuple[int, int] | None

    @property
    def name(self) -> str:
        return f"{self.owner}/{self.repo}"

    @property
    def archive_url(self) -> str:
        return f"https://github.com/{self.owner}/{self.repo}/archive/{self.commit}.tar.gz"


def _ssl_context() -> ssl.SSLContext:
    return ssl.create_default_context()


def _http_json(url: str, *, data: dict | None = None, token: str | None = None) -> dict:
    body = None if data is None else json.dumps(data).encode()
    headers = {
        "Accept": "application/vnd.github+json" if "api.github.com" in url else "application/json",
        "User-Agent": USER_AGENT,
    }
    if body is not None:
        headers["Content-Type"] = "application/json"
    if token and "api.github.com" in url:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(url, data=body, headers=headers, method="GET" if body is None else "POST")
    try:
        with urllib.request.urlopen(req, context=_ssl_context(), timeout=60) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code} for {url}: {detail}") from exc


def _http_bytes(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, context=_ssl_context(), timeout=120) as resp:
        return resp.read()


def parse_pins(text: str) -> list[Pin]:
    pins: list[Pin] = []
    for match in ARCHIVE_URL_RE.finditer(text):
        # Prefer the next sha256 after this url (chezmoi checksum table).
        sha_match = SHA256_RE.search(text, match.end())
        next_url = ARCHIVE_URL_RE.search(text, match.end())
        sha_span = None
        if sha_match and (next_url is None or sha_match.start() < next_url.start()):
            sha_span = sha_match.span(2)
        pins.append(
            Pin(
                owner=match.group("owner"),
                repo=match.group("repo"),
                commit=match.group("commit").lower(),
                url_span=match.span("commit"),
                sha_span=sha_span,
            )
        )
    return pins


def github_token() -> str | None:
    return os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")


def default_branch_head(owner: str, repo: str, token: str | None) -> tuple[str, str]:
    meta = _http_json(f"https://api.github.com/repos/{owner}/{repo}", token=token)
    branch = meta["default_branch"]
    commit = _http_json(
        f"https://api.github.com/repos/{owner}/{repo}/commits/{branch}",
        token=token,
    )
    return branch, commit["sha"].lower()


def archive_sha256(url: str) -> str:
    data = _http_bytes(url)
    return hashlib.sha256(data).hexdigest()


def scan_osv(commits: Iterable[str]) -> dict[str, list[dict]]:
    unique = list(dict.fromkeys(commits))
    if not unique:
        return {}
    payload = {"queries": [{"commit": c} for c in unique]}
    result = _http_json(OSV_QUERYBATCH, data=payload)
    out: dict[str, list[dict]] = {}
    results = result.get("results") or []
    for i, commit in enumerate(unique):
        entry = results[i] if i < len(results) else {}
        out[commit] = entry.get("vulns") or []
    return out


def cmd_list(path: Path) -> int:
    text = path.read_text(encoding="utf-8")
    pins = parse_pins(text)
    if not pins:
        print(f"No GitHub archive pins found in {path}", file=sys.stderr)
        return 1
    for pin in pins:
        sha = text[pin.sha_span[0] : pin.sha_span[1]] if pin.sha_span else "(missing)"
        print(f"{pin.name}\t{pin.commit}\t{sha}")
    return 0


def cmd_scan(path: Path, *, fail_on_vuln: bool) -> int:
    text = path.read_text(encoding="utf-8")
    pins = parse_pins(text)
    if not pins:
        print(f"No GitHub archive pins found in {path}", file=sys.stderr)
        return 1

    token = github_token()
    osv = scan_osv(p.commit for p in pins)
    findings = 0
    stale = 0

    print(f"Scanning {len(pins)} pinned archive(s) from {path}")
    for pin in pins:
        vulns = osv.get(pin.commit, [])
        status = "ok"
        tip_note = ""
        try:
            branch, tip = default_branch_head(pin.owner, pin.repo, token)
            if tip != pin.commit:
                stale += 1
                tip_note = f" (behind {branch} {tip[:12]})"
        except Exception as exc:  # noqa: BLE001 - report and continue
            tip_note = f" (tip check failed: {exc})"

        if vulns:
            findings += len(vulns)
            status = "VULN"
            ids = ", ".join(v.get("id", "?") for v in vulns)
            print(f"[{status}] {pin.name}@{pin.commit[:12]}{tip_note}: {ids}")
            for vuln in vulns:
                summary = (vuln.get("summary") or vuln.get("details") or "").strip().splitlines()
                summary_line = summary[0] if summary else "(no summary)"
                print(f"         - {vuln.get('id')}: {summary_line}")
        else:
            print(f"[{status}] {pin.name}@{pin.commit[:12]}{tip_note}")

    print(f"Summary: {findings} vulnerabilit(y/ies), {stale} pin(s) behind default branch")
    if fail_on_vuln and findings:
        return 2
    return 0


def cmd_update(path: Path, *, dry_run: bool) -> int:
    text = path.read_text(encoding="utf-8")
    pins = parse_pins(text)
    if not pins:
        print(f"No GitHub archive pins found in {path}", file=sys.stderr)
        return 1

    token = github_token()
    # Apply replacements from the end so earlier offsets stay valid.
    replacements: list[tuple[int, int, str]] = []
    changed: list[str] = []

    for pin in pins:
        branch, tip = default_branch_head(pin.owner, pin.repo, token)
        if tip == pin.commit:
            print(f"[skip] {pin.name} already at {branch} {tip[:12]}")
            continue
        new_url = f"https://github.com/{pin.owner}/{pin.repo}/archive/{tip}.tar.gz"
        digest = archive_sha256(new_url)
        print(f"[bump] {pin.name}: {pin.commit[:12]} -> {tip[:12]} ({branch})")
        print(f"       sha256 {digest}")
        replacements.append((pin.url_span[0], pin.url_span[1], tip))
        if pin.sha_span is None:
            print(f"error: missing checksum.sha256 for {pin.name}", file=sys.stderr)
            return 1
        replacements.append((pin.sha_span[0], pin.sha_span[1], digest))
        changed.append(f"{pin.name} {pin.commit[:12]}->{tip[:12]}")

    if not replacements:
        print("No updates needed.")
        return 0

    replacements.sort(key=lambda r: r[0], reverse=True)
    updated = text
    for start, end, value in replacements:
        updated = updated[:start] + value + updated[end:]

    if dry_run:
        print(f"Dry run: would update {len(changed)} pin(s)")
        return 0

    path.write_text(updated, encoding="utf-8")
    verify_text = path.read_text(encoding="utf-8")
    changed_names = {c.split()[0] for c in changed}
    for pin in parse_pins(verify_text):
        if pin.name not in changed_names:
            continue
        if pin.sha_span is None:
            print(f"error: missing checksum after update for {pin.name}", file=sys.stderr)
            return 1
        got = archive_sha256(pin.archive_url)
        want = verify_text[pin.sha_span[0] : pin.sha_span[1]]
        if got != want:
            print(f"error: checksum verify failed for {pin.name}", file=sys.stderr)
            return 1
    print("Updated:", ", ".join(changed))
    # Emit a markdown summary for GitHub Actions step summaries / PR bodies.
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as fh:
            fh.write("### Chezmoi external pin bumps\n\n")
            for line in changed:
                fh.write(f"- `{line}`\n")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--file",
        type=Path,
        default=DEFAULT_EXTERNAL,
        help="Path to .chezmoiexternal.toml (default: repo root)",
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("list", help="List pinned GitHub archive externals")
    scan_p = sub.add_parser("scan", help="Scan pinned commits with OSV")
    scan_p.add_argument(
        "--fail-on-vuln",
        action="store_true",
        help="Exit 2 when OSV reports vulnerabilities for a pin",
    )
    update_p = sub.add_parser("update", help="Bump pins to default-branch HEAD and refresh sha256")
    update_p.add_argument("--dry-run", action="store_true", help="Print bumps without writing")

    args = parser.parse_args(argv)
    path: Path = args.file
    if not path.is_file():
        print(f"File not found: {path}", file=sys.stderr)
        return 1

    if args.cmd == "list":
        return cmd_list(path)
    if args.cmd == "scan":
        return cmd_scan(path, fail_on_vuln=args.fail_on_vuln)
    if args.cmd == "update":
        return cmd_update(path, dry_run=args.dry_run)
    parser.error(f"unknown command {args.cmd}")
    return 2


if __name__ == "__main__":
    sys.exit(main())
