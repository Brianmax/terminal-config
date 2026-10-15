eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Added by Toolbox App
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# ── nvm: lazy-loaded so new shells start instantly ──────────────────────────
export NVM_DIR="$HOME/.nvm"
# Put the default node version on PATH without loading nvm itself.
if [[ -d "$NVM_DIR" ]]; then
  _nvm_ver="default"
  # Follow alias files (default -> lts/* -> lts/krypton -> v24.x.y), max 5 hops.
  for _ in 1 2 3 4 5; do
    [[ -r "$NVM_DIR/alias/$_nvm_ver" ]] || break
    _nvm_ver="$(<"$NVM_DIR/alias/$_nvm_ver")"
  done
  _nvm_resolved="$(ls -d "$NVM_DIR/versions/node/${_nvm_ver}"* 2>/dev/null | sort -V | tail -1)"
  # Fallback: newest installed version.
  [[ -d "$_nvm_resolved/bin" ]] || _nvm_resolved="$(ls -d "$NVM_DIR/versions/node/"v* 2>/dev/null | sort -V | tail -1)"
  [[ -d "$_nvm_resolved/bin" ]] && export PATH="$_nvm_resolved/bin:$PATH"
  unset _nvm_ver _nvm_resolved
fi
# Load the real nvm only when a command that needs it is first called.
_nvm_lazy_load() {
  unset -f nvm node npm npx corepack yarn pnpm 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm() { _nvm_lazy_load; nvm "$@"; }
