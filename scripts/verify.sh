#!/usr/bin/env bash
# Check that this machine matches the repo. Prints one line per check, exits non-zero on any FAIL.
set -uo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
fails=0
ok()   { echo "ok    $1"; }
fail() { echo "FAIL  $1"; fails=$((fails + 1)); }

# Tools
for cmd in zsh fzf fd bat eza rg zoxide direnv nvim tmux psql python3 herdr; do
  PATH="$HOME/.local/bin:/opt/homebrew/opt/libpq/bin:$PATH" command -v "$cmd" >/dev/null \
    && ok "command $cmd" || fail "command $cmd not found"
done

# Files that zsh sources from fixed paths
for f in \
  /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  "$HOME/.oh-my-zsh/oh-my-zsh.sh"; do
  [[ -r "$f" ]] && ok "exists $f" || fail "missing $f"
done
[[ -d /Applications/Warp.app ]] && ok "Warp.app installed" || fail "Warp.app not in /Applications"

# Dotfiles match the repo
cd "$repo/home"
while read -r rel; do
  rendered="$(sed -e "s|__HOME__|$HOME|g" -e "s|__USER__|$USER|g" "$rel")"
  [[ "$rendered" == "$(cat "$HOME/$rel" 2>/dev/null)" ]] \
    && ok "matches ~/$rel" || fail "differs or missing ~/$rel"
done < <(find . -type f | sed 's|^\./||' | sort)

# An interactive zsh starts cleanly. `script` gives it a pty; without one, zle and p10k print false errors.
out="$(script -q /dev/null zsh -i -c exit 2>&1 | tr -d '\r')"
if grep -qiE "error|not found|no such file|can't" <<<"$out"; then
  fail "zsh -i printed errors: $out"
else
  ok "zsh -i starts without errors"
fi

# herdr agent integrations (only for agents installed on this machine)
grep -q herdr-agent-state "$HOME/.claude/settings.json" 2>/dev/null && ok "herdr hook in Claude Code" \
  || { command -v claude >/dev/null && fail "herdr hook missing from ~/.claude/settings.json"; }
grep -q herdr-agent-state "$HOME/.codex/hooks.json" 2>/dev/null && ok "herdr hook in Codex" \
  || { command -v codex >/dev/null && fail "herdr hook missing from ~/.codex/hooks.json"; }

echo
(( fails == 0 )) && echo "all checks passed" || echo "$fails check(s) failed"
exit $(( fails > 0 ))
