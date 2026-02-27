# Profiler: run with ZSH_PROFILE=1 zsh to see timing report
[[ -n "$ZSH_PROFILE" ]] && zmodload zsh/zprof

ZD="${DOTFILES:-$HOME/.dotfiles}/zsh"
source "$ZD/.zsh_interactive"
source "$ZD/.zsh_aliases"
source "$ZD/.zsh_functions"

# fnm: interactive hook (use node version when cd'ing); env/PATH are in .zshenv
eval "$(fnm env --use-on-cd --shell zsh)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

[[ -n "$ZSH_PROFILE" ]] && zprof
