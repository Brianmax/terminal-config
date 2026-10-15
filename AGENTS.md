# terminal-config

This repo rebuilds one macOS terminal setup on a new machine: Warp as the terminal, herdr for agent workspaces, and zsh with Oh My Zsh and Powerlevel10k. `README.md` explains what each setting does. This file is the procedure.

## Layout

- `home/` mirrors `$HOME`. Every file in it is copied to the same relative path. `__HOME__` and `__USER__` are filled in during the copy.
- `Brewfile` lists the Homebrew packages, apps and fonts.
- `scripts/install-dotfiles.sh` copies `home/` into `$HOME`. It backs up any file that differs and leaves identical files alone.
- `scripts/verify.sh` is the completion criterion for the whole setup. It prints `ok` or `FAIL` per check and exits 0 only when every check passes.

## Setup

Run the steps in order. Each step lists the condition that means it's done. If a step needs a password, a GUI click or an interactive login, stop and hand that command to the human.

1. **Prerequisites.** You need macOS on Apple Silicon: `.zshrc` sources plugins from `/opt/homebrew/share`. Install Homebrew from https://brew.sh if `brew` isn't on `PATH`. Done when `brew --prefix` prints `/opt/homebrew`.
2. **Packages.** Run `brew bundle --file=Brewfile`. Done when `brew bundle check --no-upgrade --file=Brewfile` reports that the dependencies are satisfied.
3. **Oh My Zsh.** If `~/.oh-my-zsh` is missing, run:
   `RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`.
   `KEEP_ZSHRC=yes` keeps the installer from writing its own `.zshrc`, and step 5 installs the repo's copy. Done when `~/.oh-my-zsh/oh-my-zsh.sh` exists.
4. **herdr.** If `~/.local/bin/herdr` is missing, run `curl -fsSL https://herdr.dev/install.sh | sh`. Done when `~/.local/bin/herdr --version` prints a version.
5. **Dotfiles.** Run `scripts/install-dotfiles.sh`. Report every `backed up` line it prints to the human, since those are their previous files. Done when a second run prints only `unchanged` lines.
6. **Agent integrations.** For each of `claude`, `codex` and `pi` that is installed (check with `command -v`), run `herdr integration install <name>`. These hooks let herdr link each pane to its agent session. Done when `herdr integration status` lists each installed agent.
7. **Verify.** Run `scripts/verify.sh`. Done when it ends with `all checks passed`. For each `FAIL`, go back to the step that owns that check, fix it, and run the script again.
8. **Hand-off.** Tell the human to:
   - open Warp and sign in (Warp reads `~/.warp/settings.toml` itself)
   - run `exec zsh` in any terminal that was already open
   - start `herdr` inside Warp

## Changing the configuration

The live files in `$HOME` and the copies in `home/` must stay identical. After changing a setting, copy the live file back into `home/`. Restore the `__HOME__`/`__USER__` placeholders wherever an absolute home path or username appears. Then update the matching section of `README.md` and run `scripts/verify.sh`. To capture a new config file, add it under `home/` at its path relative to `$HOME`. Both scripts pick up new files automatically.

Some files are generated, not copied. Herdr's hook files (`~/.claude/hooks/herdr-agent-state.sh`, `~/.codex/herdr-agent-state.sh`, `~/.pi/agent/extensions/herdr-agent-state.ts`) come from step 6 and are overwritten whenever herdr updates. Herdr session and state files under `~/.config/herdr/` and `~/.local/state/herdr/` are per machine. Keep all of them out of `home/`.
