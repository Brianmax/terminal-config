#!/usr/bin/env bash
# Copy every file under home/ into $HOME, filling in __HOME__ and __USER__.
# A file that already exists and differs is moved into a timestamped backup folder first.
# Safe to re-run: identical files are left alone.
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
backup="$HOME/.terminal-config-backup-$(date +%Y%m%d-%H%M%S)"

render() {
  sed -e "s|__HOME__|$HOME|g" -e "s|__USER__|$USER|g" "$1"
}

cd "$repo/home"
find . -type f | sed 's|^\./||' | sort | while read -r rel; do
  dst="$HOME/$rel"
  if [[ -e "$dst" ]] && cmp -s <(render "$rel") "$dst"; then
    echo "unchanged  ~/$rel"
    continue
  fi
  if [[ -e "$dst" ]]; then
    mkdir -p "$backup/$(dirname "$rel")"
    mv "$dst" "$backup/$rel"
    echo "backed up  ~/$rel -> $backup/$rel"
  fi
  mkdir -p "$(dirname "$dst")"
  render "$rel" >"$dst"
  echo "installed  ~/$rel"
done
