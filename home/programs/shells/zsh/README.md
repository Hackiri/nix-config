# Zsh Configuration

A modern Zsh configuration managed through Home Manager with vim mode, fzf-tab completion, and FZF-powered commands for Git, Kubernetes, Cilium, and Claude Code.

## Overview

This configuration provides a native Zsh environment without frameworks like oh-my-zsh. Shell options, completion, keybindings, and FZF integrations are each defined in dedicated Nix modules imported by `default.nix`.

### Key Features

- **Vim mode** with cursor shape switching (block in normal, beam in insert)
- **fzf-tab** for fuzzy completion with file/directory previews
- **Native plugins**: syntax highlighting, autosuggestions, history-substring-search
- **FZF commands** for Git, Kubernetes, Cilium, and Claude Code
- **Direnv auto-detect** hook that creates `.envrc` when project markers are found
- **Starship prompt** for fast, customizable shell prompt
- **50,000-entry shared history** with deduplication
- Optimized completion loading (cache rebuilt once per day)

## Directory Structure

```
zsh/
├── default.nix         # Main module: imports, session vars, history, zoxide
├── options.nix         # Shell options (setopt), zmodload, named directories
├── keybindings.nix     # Vim mode, cursor switching, history-substring-search keys
├── completion.nix      # fzf-tab plugin, compinit optimization, zstyle config
├── fzf.nix             # Shared FZF config: env vars, fzf-down, compgen, comprun
├── fzf-git.nix         # Git FZF commands (gff, gfb, gft, gfh, gfr, gfs, gfst, gfa, gfc)
├── fzf-kubectl.nix     # Kubectl FZF commands (kfp, kfn, kfc, kfl, kfe, kfs, kfd, kfx, kff)
├── fzf-cilium.nix      # Cilium FZF commands (cfp, cfs, cft, cfe, cfm, cfl, cfv, cfu, cfo, cfh, cfd)
├── fzf-claude.nix      # Claude Code FZF commands (clh, cls, clp, clr, claude-search)
├── direnv-hook.nix     # chpwd hook: auto-detect project markers, create .envrc
├── aliases.nix         # All command aliases (nix, k8s, git, modern tools, etc.)
└── README.md
```

## Vim Mode

Vim mode is enabled via `bindkey -v` in `keybindings.nix` with `lib.mkBefore` to ensure it loads before FZF commands.

| Key | Mode | Action |
|-----|------|--------|
| `Esc` | insert | Switch to normal mode (block cursor) |
| `i` | normal | Switch to insert mode (beam cursor) |
| `v` | normal | Edit command in `$EDITOR` |
| `Ctrl+X Ctrl+E` | insert | Edit command in `$EDITOR` |
| `Esc Esc` | any | Toggle `sudo` prefix on current line |
| `Up` / `Down` | any | History substring search |
| `k` / `j` | normal | History substring search |
| `Ctrl+\` | any | Accept and hold (run command, keep on line) |

## FZF Commands

All FZF integration modules define plain shell commands (not ZLE keybindings). Each module is guarded by `command -v` so it only loads when the relevant tool is installed.

### Git Commands (`fzf-git.nix`)

Only available inside git repositories.

| Command | Description |
|---------|-------------|
| `gff` | File status browser — modified/untracked files with diff preview |
| `gfb` | Branch browser — local and remote branches with commit history |
| `gft` | Tag browser — tags with version sorting and details |
| `gfh` | History browser — commit log with diff preview (Ctrl+S toggles sort) |
| `gfr` | Remote browser — remotes with commit history |
| `gfs` | Stash browser — stashed changes with preview |
| `gfst` | Interactive status — Ctrl+A to add/unstage, Ctrl+C to commit |
| `gfa` | Interactive add — multi-select files to stage (TAB) |
| `gfc` | Interactive commit — opens editor with staged file list |

### Kubectl Commands (`fzf-kubectl.nix`)

| Command | Description |
|---------|-------------|
| `kfp` | Pod selector — browse pods with describe preview |
| `kfn` | Namespace selector — switch namespace with resource preview |
| `kfc` | Context selector — switch cluster context |
| `kfl` | Log viewer — select pod, view logs (Ctrl+F to follow) |
| `kfe` | Exec into pod — select pod/container, open shell |
| `kfs` | Service selector — browse services with endpoints |
| `kfd` | Deployment selector — browse deployments with replica status |
| `kfx` | Delete resource — select type, then resource, with confirmation |
| `kff` | Port forward — select pod, enter port mapping |

### Cilium Commands (`fzf-cilium.nix`)

| Command | Description |
|---------|-------------|
| `cfp` | Pod selector — browse Cilium agent pods |
| `cfs` | Status — show Cilium status |
| `cft` | Connectivity test — run Cilium connectivity tests |
| `cfe` | Endpoint browser — select pod, view endpoint list |
| `cfm` | Monitor — start Cilium monitor on selected pod |
| `cfl` | Policy browser — browse CNP/CCNP policies |
| `cfv` | Service map — view cluster service list |
| `cfu` | Hubble UI — open with port-forward |
| `cfo` | Hubble observe — interactive flow observation with filters |
| `cfh` | Health check — quick Cilium health overview |
| `cfd` | Debug info — version, status, events from selected pod |

### Claude Code Commands (`fzf-claude.nix`)

| Command | Description |
|---------|-------------|
| `clh` | History — browse all prompts across projects |
| `cls` | Sessions — browse sessions for current project |
| `clp` | Projects — list all projects with conversation counts |
| `clr` | Recent — conversations from the last 7 days |
| `claude-search` | Full-text search across all conversations |

### Built-in FZF Shortcuts

These are standard FZF shell integration shortcuts configured in `fzf.nix`:

| Key | Action |
|-----|--------|
| `Ctrl+T` | Fuzzy file finder (preview with bat/eza) |
| `Alt+C` | Fuzzy directory finder + cd (preview with eza tree) |
| `Ctrl+R` | Command history search |
| `Ctrl+/` | Toggle preview in any FZF window |

## Command Aliases

All aliases are defined in `aliases.nix` and shared between zsh and bash.

### System Management (Nix)

```bash
nixswitch    # Build and activate configuration
nixbuild     # Build only (no activation)
nixcheck     # Check configuration validity
nixdry       # Dry run (test build without changes)
nixedit      # Open configuration in $EDITOR
nixlist      # List all generations
nixrollback  # Rollback to previous generation
nixclean     # Clean old generations and garbage collect
nixtrace     # Show trace for debugging
nixverbose   # Verbose output
```

### Nix Utilities

```bash
nxsearch     # Search packages (nix search nixpkgs)
nxrepl       # Interactive nix REPL
nxdev        # Enter development shell
```

### Kubernetes

```bash
k            # kubectl
kns          # Set namespace for current context
kg/kd/kl/ke  # Get/describe/logs/edit resources
kx           # Exec into container
ka           # Apply configuration file
kgp/kgs/kgd  # Get pods/services/deployments
kgn/kgc/kgsec/kgns  # Get nodes/configmaps/secrets/namespaces
kgaa         # Get all resources in all namespaces
ktop/ktopnodes  # Resource usage for pods/nodes
kdebug       # Start debug container
kevents      # Events sorted by time
kusectx/kgctx  # Switch/list contexts
kroll/kstatus/kscale  # Rollout restart/status/scale
kfwd         # Port forward
kapplyd      # Apply kustomization in current directory
```

### Helm

```bash
h/hi/hu/hl/hd  # helm/install/upgrade/list/delete
hr/hru/hs      # repo/repo-update/search
```

### Git

```bash
gaa/gcmsg/gst  # Add all / commit -m / status
gco/gcb/gcm    # Checkout / new branch / main
gl/glast       # Log graph / last commit
gpull/gpush    # Pull --rebase / push
gd/gds/gdw/gdn  # Diff / staged / word / name-only
```

### Container Operations (Podman)

```bash
pps/pi         # List containers/images
pclean/piclean # Clean stopped containers / dangling images
pcomp/prestart # Compose / restart compose
docker         # Alias to podman
docker-compose # Alias to podman-compose
```

### Modern Unix Replacements

```bash
l / ll         # eza -l / eza -la (with icons)
lse            # eza tree (1 level)
lstree         # eza tree (full)
cdiff          # colordiff
prs            # procs
lg             # lazygit
md             # glow (markdown viewer)
```

### FZF Combinations

```bash
vif            # Open file with FZF + bat preview in nvim
fcd            # Fuzzy cd to directory
fh             # Fuzzy search history
fkill          # Fuzzy kill process
fenv           # Fuzzy search environment variables
frg            # Fuzzy ripgrep with preview
fin            # FZF → open in nvim
```

### File and Navigation

```bash
vi             # nvim
files          # yazi file manager
dots           # cd ~/nix-config
..  ...  ....  # cd up 1/2/3 levels
```

### Zsh-specific Features

Defined in `aliases.nix` `initContent` (not available in bash):

**Suffix aliases** — open files by typing the filename:
```bash
file.py        # runs python3 file.py
file.md        # runs glow file.md
file.json      # runs jq . file.json
repo.git       # runs git clone repo.git
```

**Global aliases** — substituted anywhere on the line:
```bash
command G      # | grep
command L      # | less
command H      # | head -20
command J      # | jq .
command C      # | wc -l
```

**Extract function** — handles tar.gz, zip, 7z, xz, zst, rar, bz2, etc.

## Direnv Auto-detect Hook

When you `cd` into a directory, `direnv-hook.nix` checks for project markers and offers to create a devShell environment:

| Marker file | DevShell |
|-------------|----------|
| `Cargo.toml` | rust |
| `package.json` | node |
| `go.mod` | go |
| `pyproject.toml` / `requirements.txt` / `setup.py` | python |
| `Gemfile` | ruby |
| `composer.json` | php |

The hook generates a `flake.nix` in `~/.cache/direnv-flakes/` and a `.envrc` pointing to it, keeping the project directory clean. It also adds `.envrc` and `.direnv` to `.git/info/exclude`.

Skipped when: `.envrc` already exists, current directory is `$HOME` or `~/nix-config`, no markers found.

## Core Packages

The following are automatically installed and configured:

- `zsh-fzf-tab` — Fuzzy completion with previews (replaces default tab menu)
- `zsh-syntax-highlighting` — Real-time command highlighting
- `zsh-autosuggestions` — History-based command suggestions
- `zsh-history-substring-search` — Type then Up/Down to filter history
- `fzf` + `fd` — Fuzzy finding with modern file search
- `bat` — Syntax-highlighted file previews
- `eza` — Modern ls with icons and tree view
- `ripgrep` — Fast grep for FZF integrations
- `zoxide` — Smart directory jumping via `z` / `zi` commands (does NOT override `cd`)
- `starship` — Cross-shell prompt
- `direnv` — Per-directory environment management

## Maintenance

### Configuration Files

| File | Purpose |
|------|---------|
| `default.nix` | Main module: imports, session vars, history, zoxide init |
| `options.nix` | Shell options (setopt), zmodload, named directories |
| `keybindings.nix` | Vim mode, cursor shape, history-substring-search bindings |
| `completion.nix` | fzf-tab plugin, compinit cache, zstyle completion config |
| `fzf.nix` | FZF defaults, preview config, compgen/comprun |
| `fzf-git.nix` | Git FZF commands |
| `fzf-kubectl.nix` | Kubectl FZF commands |
| `fzf-cilium.nix` | Cilium FZF commands |
| `fzf-claude.nix` | Claude Code FZF commands |
| `direnv-hook.nix` | Auto-detect chpwd hook |
| `aliases.nix` | All aliases (shared zsh + bash) |

### Update Process

1. Modify configuration files as needed
2. Test changes with `nixdry` to verify no errors
3. Apply changes with `nixswitch`
4. If issues occur, use `nixrollback` to revert

## Troubleshooting

### FZF Commands Not Working

- Verify FZF is installed: `fzf --version`
- Git commands require being inside a git repo
- Kubectl/Cilium commands require the tool to be installed
- Claude commands require `claude` CLI to be installed

### Completion Issues

- Rebuild completion cache: delete `~/.cache/zsh/.zcompdump` and restart shell
- Verify fzf-tab is loaded: `type _fzf_tab_complete` should show a function

### Vim Mode Issues

- `KEYTIMEOUT=1` is set for responsive mode switching
- If chords feel sluggish, check for conflicting keybindings
- Backspace and delete keys are explicitly bound for insert mode

### Zoxide Not Working

- Uses `z` and `zi` commands (does NOT override `cd`)
- Verify zoxide is installed: `zoxide --version`
- Check database: `zoxide query --list`

### Direnv Auto-detect Not Triggering

- Only runs on `chpwd` (directory change), not in current directory
- Skipped if `.envrc` already exists
- Check that the hook is registered: `type _direnv_auto_detect`
