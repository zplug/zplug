# This file just loads some files within autoload directory
# Also, load the body of zplug

fpath=(
"$ZPLUG_ROOT"/autoload(N-/)
"$ZPLUG_ROOT"/autoload/*(N-/)
"$fpath[@]"
)

autoload -Uz add-zsh-hook
autoload -Uz colors
autoload -Uz compinit
autoload -Uz zplug

colors
