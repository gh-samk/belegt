#!/usr/bin/env bash
# Prüft die Logik der Mac-App (mac/Quelle/Logik.swift) mit mac/tests/main.swift.
set -euo pipefail

hier="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

swiftc -swift-version 5 "$hier/Quelle/Logik.swift" "$hier/tests/main.swift" -o "$tmp/logiktest"
"$tmp/logiktest"
