source ~/.zsh_profile
source ~/.zsh_aliases
source ~/.zsh_functions

# To add machine-local plugins, drop *.plugin.zsh files into $ZSH_CUSTOM/plugins/
# or add them to plugins+=() in ~/.zshrc.local before sourcing this file.

# fnm
eval "$(fnm env --use-on-cd --shell zsh)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# opencode
export PATH=/home/alexander/.opencode/bin:$PATH

# fnm
FNM_PATH="/home/alexander/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi
