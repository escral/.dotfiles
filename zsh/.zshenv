# Runs for every zsh (interactive, non-interactive, scripts).
# Keep this minimal so IDEs and subprocesses see node and PATH.

# ── Environment ───────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.local/scripts:$PATH"
export PATH="$HOME/.local/.npm-global/bin:$PATH"

# fnm (Fast Node Manager) — so IDEs and non-interactive shells find node
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

# deno
[ -f "$HOME/.deno/env" ] && source "$HOME/.deno/env"

# ── Node ──────────────────────────────────────────────────────────────────────
export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=4096}"
