#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap_link.sh /path/to/client/repo [more repos...]

Sets up a client repo to consume governance from this repo:
- sets ai.governanceRoot in client repo config
- sets core.hooksPath to .githooks if present
- links governance files into the client repo
USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LINKER="$ROOT/scripts/link_ai_governance.sh"

if [[ ! -x "$LINKER" ]]; then
  echo "Missing linker: $LINKER" >&2
  exit 1
fi

for TARGET in "$@"; do
  if [[ ! -d "$TARGET" ]]; then
    echo "Skip (not found): $TARGET" >&2
    continue
  fi

  echo "\n🏗️  Bootstrapping: $TARGET"
  git -C "$TARGET" config ai.governanceRoot "$ROOT"

  if [[ -d "$TARGET/.githooks" ]]; then
    git -C "$TARGET" config core.hooksPath .githooks
  else
    echo "⚠️  .githooks not found in $TARGET (skipping hooksPath)"
  fi

  "$LINKER" --source "$ROOT" --env "$TARGET" --force

done

echo "\n✅ Bootstrap complete."
