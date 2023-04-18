source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

source ~/.config/fzf/plugins/fzf-marks/fzf-marks.plugin.zsh 

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}
