# Herdr & Terminal Configuration

As of 2026-10-15.

## Overview

The setup has four layers: Warp is the terminal, herdr runs inside it to manage agent workspaces, zsh runs in each pane, and agents (Claude Code, Codex, pi) report back to herdr through hooks. Three things need attention: the herdr Oh My Zsh plugin isn't enabled, herdr v0.9.1 is behind v0.9.5, and `Cmd+A` select-all in zsh likely doesn't work in Warp.

| Layer | Tool | Main config file |
| --- | --- | --- |
| Terminal | Warp | `~/.warp/settings.toml` |
| Agent multiplexer | herdr 0.9.1 | `~/.config/herdr/config.toml` |
| Shell | zsh + Oh My Zsh + Powerlevel10k | `~/.zshrc`, `~/.zprofile`, `~/.p10k.zsh` |
| Agent hooks | Claude Code, Codex, pi | `~/.claude/settings.json`, `~/.codex/hooks.json`, `~/.pi/agent/extensions/` |
| Classic multiplexer | tmux | `~/.tmux.conf` |

## Herdr configuration

Herdr runs coding agents (Claude Code, Codex, pi) in workspaces, tabs and panes. The user config is `~/.config/herdr/config.toml`: Dracula theme, `Cmd+U` as the prefix, and vim-style navigation. The installed binary is `~/.local/bin/herdr`, which reports **v0.9.1**. The cached release notes are for v0.9.5, so an update is available.

### config.toml

| Key | Value | What it does |
| --- | --- | --- |
| `onboarding` | `false` | Skips the first-run onboarding |
| `[theme] name` | `"dracula"` | Colour theme |
| `[theme] auto_switch` | `false` | Doesn't follow macOS light/dark mode |
| `[keys] prefix` | `cmd+u` | Leader key for prefixed shortcuts |
| `navigate_workspace_up` / `down` | `k` / `j` | Move between workspaces |
| `navigate_pane_up` / `down` | `up` / `down` | Move focus vertically between panes |
| `focus_pane_left` / `right` | `prefix+left` / `prefix+right` | Move focus horizontally between panes. These moved off `h`/`l` so they don't clash with the tab keys |
| `previous_tab` / `next_tab` | `cmd+shift+h` / `cmd+shift+l` | Switch tabs without the prefix, so you can press them repeatedly |

The config was built up in three steps. Each step left a backup next to the file:

1. `config.toml.pre-prefix.bak`: the theme only
2. `config.toml.pre-navkeys.bak`: adds `prefix = "cmd+u"`
3. `config.toml.pre-tabkeys.bak`: adds the workspace and pane `j`/`k`/arrow keys
4. Current `config.toml`: adds the tab keys and moves pane left/right to arrows

### Agent integrations

Herdr installs and manages these hooks. Updating an integration overwrites them, so put custom hooks in separate files next to them. Each hook reports the agent's session ID to the herdr socket (`pane.report_agent_session`) so herdr can link a pane to its agent session.

| Agent | Hook file | Registered in | Version |
| --- | --- | --- | --- |
| Claude Code | `~/.claude/hooks/herdr-agent-state.sh` | `~/.claude/settings.json` (`SessionStart` hook, `session` argument) | 10 |
| Codex | `~/.codex/herdr-agent-state.sh` | `~/.codex/hooks.json` | 8 |
| pi | `~/.pi/agent/extensions/herdr-agent-state.ts` | Loaded as a pi extension. It also reports the working, blocked and idle states | 9 |

A hook does nothing unless `HERDR_ENV=1`, `HERDR_SOCKET_PATH` and `HERDR_PANE_ID` are set. Herdr sets these inside its own panes. The release notes say v0.9.4+ no longer uses Codex turn hooks; run `herdr integration install codex` after updating.

### Runtime and state files (not hand-edited)

| Path | Contents |
| --- | --- |
| `~/.config/herdr/session.json` | The saved layout of workspaces, tabs and panes. For example, workspace `TPRV-3232` has two Claude panes in `~/Desktop/tpo-portal-api` |
| `~/.config/herdr/sessions/dafault/` | A named session (the name is spelled "dafault") with its own socket, logs and `session.json` |
| `~/.config/herdr/herdr.sock`, `herdr-client.sock` | Sockets for the server and client |
| `~/.config/herdr/*.log` | Server and client logs. The server log is about 540 KB |
| `~/.config/herdr/release-notes.json` | Cached release notes, shown at startup |
| `~/.herdr/worktrees/` | The folder where herdr creates git worktrees (it holds `tpo-portal-api`) |
| `~/.local/state/herdr/agent-detection/` | `status.toml`, plus one remote detection rule file per agent (`claude.toml`, `codex.toml` and about 20 more) |
| `~/.local/state/herdr/client-shell/` | State for the client shell |

### Oh My Zsh plugin

`~/.oh-my-zsh/plugins/herdr/herdr.plugin.zsh` is installed but **not enabled**. `herdr` isn't in the `plugins=(…)` list in `~/.zshrc`, so the aliases below don't work yet. To turn it on, add `herdr` to that list. That also gives you completion and a `herdr_prompt_info` prompt segment that shows the pane ID.

| Alias | Command |
| --- | --- |
| `hrdr` | `herdr` |
| `hrdrst` | `herdr status` |
| `hrdrup` | `herdr update` |
| `hrdrsl` / `hrdrsa` | `herdr session list` / `attach` |
| `hrdrs` | Pick a session with fzf (or a numbered menu) and attach to it |
| `hrdrr` | `herdr --remote` |
| `hrdral` | `herdr agent list` |
| `hrdrwl` / `hrdrwc` | `herdr workspace list` / `create` |
| `hrdrwt` | `herdr worktree create` |
| `hrdrps` | `herdr pane split` |
| `hrdrrc` | `herdr server reload-config` |

## Terminal emulator: Warp

Warp is the terminal (`TERM_PROGRAM=WarpTerminal`, `TERM=xterm-256color`), and herdr runs inside it. Warp settings live in `~/.warp/settings.toml`. Warp syncs that file with its app preferences (`defaults` domain `dev.warp.Warp-Stable`).

### Appearance

| Setting | Value |
| --- | --- |
| `appearance.text.font_size` | 18.0 |
| `appearance.text.notebook_font_size` | 14.0 |
| `appearance.window.zoom_level` | 110% |
| `appearance.vertical_tabs.enabled` | true |

### Warp agent (default execution profile)

| Setting | Value |
| --- | --- |
| `execute_commands` | always_ask |
| `read_files` | agent_decides |
| `apply_code_diffs` | agent_decides |
| `ask_user_question` | always_ask |
| `run_agents` | always_ask |
| `computer_use` | always_ask |
| `mcp_permissions` | agent_decides |
| `write_to_pty` | always_allow |
| `web_search_enabled` | true |
| `autosync_plans_to_warp_drive` | true |
| `command_denylist` | Shells (`bash`, `sh`, `zsh`, `fish`, `pwsh`), `eval`, `exec`, `source`, network tools (`curl`, `wget`, `ssh`, `scp`, `rsync`, `telnet`, `dig`, `nslookup`, `host`) and `rm` |
| `nld_in_terminal_enabled` | true: Warp detects plain-English input typed in the terminal |
| `cloud_conversation_storage_enabled` | true |

### Notifications, privacy and terminal

- **Notifications** are on, with sound and an 8-second toast. They fire when an agent task completes, when something needs attention, at a password prompt, and when a command runs longer than 30 seconds.
- **Privacy**: telemetry and crash reporting are on. Warp's default secret-redaction regexes are enabled. They cover IP addresses, phone numbers, MAC addresses, JWTs, and AWS, GitHub, Google, Slack, Stripe, OpenAI, Anthropic and Fireworks keys.
- **Terminal**: `osc52_clipboard_access = "write_only"`. Programs in the terminal (including herdr and remote shells) can copy to the clipboard but can't read it.

### Startup tab

`~/.warp/tab_configs/startup_config.toml` opens new tabs with a single **agent** pane in `~` (`/Users/georgemaxiccapa`).

## Shell: zsh

The shell is zsh with Oh My Zsh and a Powerlevel10k prompt. Config is in `~/.zprofile` (login shells) and `~/.zshrc` (interactive shells). Both were rewritten on 2026-10-12, and the previous versions are in `~/.dotfiles-backup-20261012-003023/`.

### ~/.zprofile

- Sets up Homebrew with `brew shellenv` (`/opt/homebrew`).
- Adds the JetBrains Toolbox scripts folder to `PATH`.
- Loads nvm lazily: it puts the default Node version's `bin` on `PATH` without loading nvm. It does this by following the alias chain, for example `default → lts/* → v24.x`. The real `nvm.sh` loads the first time you run `nvm`.

### ~/.zshrc, in load order

1. **Powerlevel10k instant prompt.** This must stay at the top of the file.
2. **Oh My Zsh** with `ZSH_THEME=""` (Powerlevel10k draws the prompt), `HYPHEN_INSENSITIVE=true`, and update `mode reminder`. Plugins: `git gh docker sudo extract`.
3. **PATH**: `~/.local/bin` (where herdr is installed) and Homebrew `libpq/bin` (`psql`).
4. **Editor**: `EDITOR` and `VISUAL` are set to `nvim`.
5. **History**: 100,000 entries, shared between sessions. Duplicates and extra blanks are removed, and `HIST_VERIFY` is on.
6. **Prompt**: Powerlevel10k from Homebrew plus `~/.p10k.zsh`. It uses the lean wizard style generated on 2026-10-12: two lines, sparse, transient prompt, Nerd Font icons. The left side shows `dir · vcs`, then `prompt_char` on a new line. The right side shows the exit status, the command duration, background jobs, direnv and more.
7. **fzf**: `Ctrl+R` searches history, `Ctrl+T` finds files, and `Alt+C` finds folders. All three use `fd` (including hidden files, excluding `.git`) and open a reversed list at 40% height. `Ctrl+T` shows a `bat` preview.
8. **zoxide** (a smarter `cd` via `z`) and the **direnv** hook.
9. **Aliases for modern tools**: `ls`, `ll`, `la` and `lt` run `eza` (with icons and git status), `cat` runs `bat --paging=never`, `grep` runs `rg`, and `vim` runs `nvim`. `BAT_THEME=ansi`.
10. **Select all**: press `Ctrl+A` once to jump to the start of the line, and twice to select the whole line. `Cmd+A` (sent as CSI-u `^[[97;9u`) selects everything too. With the line selected, typing or pasting replaces it, Backspace deletes it, and moving the cursor cancels the selection.
11. **zsh-autosuggestions** (suggestions in grey, `fg=244`) and **zsh-syntax-highlighting**, both from Homebrew. These load last.
12. **Worktree helpers**: `gwm` jumps to the repo's main worktree. `wt <TPRV-1234>` jumps into `~/Desktop/tpo-portal-api-worktrees/<name>`, with tab completion. `wtl` lists the tpo-portal-api worktrees.

The `Cmd+A` select-all binding only works if the terminal sends `Cmd+A` as CSI-u. The comment in `.zshrc` names Ghostty, iTerm2 and kitty, not Warp. In Warp, `Cmd+A` probably goes to Warp's own select-all.

## Related tooling: tmux

There's a small tmux config in `~/.tmux.conf`. It's separate from herdr and only applies if you start `tmux` yourself.

| Setting | Value |
| --- | --- |
| Prefix | `Ctrl+A`, replacing `Ctrl+B`. Press `Ctrl+A` `Ctrl+A` to send a literal `Ctrl+A` |
| Mouse | On |
| Split side by side / stacked | `prefix` + `\|` / `prefix` + `-` (the defaults `"` and `%` are unbound) |
| Window and pane numbering | Starts at 1 |
| `default-terminal` | `screen-256color` |

The tmux prefix `Ctrl+A` overrides the shell's `Ctrl+A` start-of-line and select-all binding inside tmux. Herdr uses `Cmd+U`, so herdr doesn't clash with either.

## Quick reference: applying changes

| After editing | Run this |
| --- | --- |
| `~/.config/herdr/config.toml` | `herdr server reload-config` (or `hrdrrc` once the plugin is enabled) |
| Herdr version or agent hooks | `herdr update`, then `herdr integration install codex` (or `claude`, `pi`) |
| `~/.zshrc`, `~/.zprofile` | `exec zsh` (or open a new tab) |
| `~/.p10k.zsh` | `p10k configure` to rerun the wizard, or `exec zsh` after a manual edit |
| `~/.tmux.conf` | `tmux source-file ~/.tmux.conf` |
| `~/.warp/settings.toml` | Warp applies it automatically, or change it in Settings |

Don't edit the herdr hook files under `~/.claude/hooks/`, `~/.codex/` or `~/.pi/agent/extensions/`. Herdr overwrites them on update, so put custom hooks in separate files next to them.
