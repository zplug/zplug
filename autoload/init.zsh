#!/bin/zsh
# init.zsh:
#   This file is called only once

if (( $+functions[__import] )); then
    return 0
fi

source "$ZPLUG_ROOT/lib/init.zsh"

__import "zplug/variables"
__import "core/core"
__import "job/notify"
__import "print/print"

if ! __zsh_version 4.3.9; then
    __die "[zplug] zplug does not work this version of zsh $ZSH_VERSION.\n"
    __die "[zplug] You must use zsh 4.3.9 or later.\n"
    return 1
fi

if (( ! $+commands[git] )); then
    __die "[zplug] git command not found in \$PATH\n"
    __die "[zplug] zplug depends on git 1.7 or later.\n"
    return 1
fi

autoload -Uz add-zsh-hook
autoload -Uz colors; colors
autoload -Uz compinit

if ${ZPLUG_CHECK_UPDATE:-false}; then
    __check_zplug_update
fi
