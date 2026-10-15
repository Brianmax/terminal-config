# ── Powerlevel10k instant prompt (must stay at the top) ────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Oh My Zsh ───────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""                      # prompt is handled by powerlevel10k below
HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode reminder
plugins=(git gh docker sudo extract)
source $ZSH/oh-my-zsh.sh

# ── PATH ────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# ── Editor ──────────────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="$EDITOR"

# ── History ─────────────────────────────────────────────────────────────────
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY SHARE_HISTORY

# ── Prompt: powerlevel10k ───────────────────────────────────────────────────
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ── fzf: Ctrl+R history, Ctrl+T files, Alt+C dirs ───────────────────────────
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"

# ── zoxide: smarter cd ──────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── direnv ──────────────────────────────────────────────────────────────────
eval "$(direnv hook zsh)"

# ── Modern replacements ─────────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git'
alias la='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
alias grep='rg'
alias vim='nvim'
export BAT_THEME="ansi"

# ── Select all ──────────────────────────────────────────────────────────────
# Ctrl+A once  = go to beginning of line (unchanged).
# Ctrl+A twice = select the whole command line.
# Cmd+A        = select all, in terminals that send it as CSI-u (Ghostty, iTerm2, kitty).
# While selected: typing or pasting replaces it, Backspace/Delete removes it,
# any cursor movement cancels it.
select-all() { MARK=0; CURSOR=$#BUFFER; REGION_ACTIVE=1 }
zle -N select-all
beginning-of-line-or-select-all() {
  if (( CURSOR == 0 && $#BUFFER > 0 )) && [[ $LASTWIDGET == beginning-of-line-or-select-all ]]; then
    zle select-all
  else
    REGION_ACTIVE=0; zle .beginning-of-line
  fi
}
zle -N beginning-of-line-or-select-all
bindkey '^A' beginning-of-line-or-select-all
bindkey '^[[97;9u' select-all

_sel_replace() {
  if (( REGION_ACTIVE )); then
    zle .kill-region; REGION_ACTIVE=0
    [[ $WIDGET == (self-insert|bracketed-paste) ]] && zle _sel_orig_$WIDGET
  else
    zle _sel_orig_$WIDGET
  fi
}
_sel_cancel() { REGION_ACTIVE=0; zle _sel_orig_$WIDGET }
for w in self-insert bracketed-paste backward-delete-char delete-char; do
  zle -A $w _sel_orig_$w; zle -N $w _sel_replace
done
for w in forward-char backward-char end-of-line up-line-or-beginning-search down-line-or-beginning-search; do
  zle -A $w _sel_orig_$w 2>/dev/null && zle -N $w _sel_cancel
done

# ── Plugins (must be last) ──────────────────────────────────────────────────
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"

# --- git worktree navigation ---
# gwm: jump to the main worktree of the current repo (gm is oh-my-zsh git merge)
gwm() { cd "$(git worktree list --porcelain | sed -n '1s/^worktree //p')" ; }
# wt TPRV-1234: jump into a tpo-portal-api worktree (tab-completes)
wt() { cd ~/Desktop/tpo-portal-api-worktrees/"$1" ; }
compdef '_files -W ~/Desktop/tpo-portal-api-worktrees -/' wt
# wtl: list tpo-portal-api worktrees (works from anywhere)
wtl() { git -C ~/Desktop/tpo-portal-api worktree list ; }
