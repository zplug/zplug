#!/usr/bin/env zsh

if [[ -z $ZPLUG_ROOT ]]; then
    exit 1
fi

source "$ZPLUG_ROOT/base/core/core.zsh"

local    filter
local    dir
local -a wc_files

filter="$(__zplug::core::core::get_filter "${ZPLUG_FILTER:-"fzf --tac:peco:percol:zaw"}")"
if [[ -z $filter ]]; then
    exit
fi

case "$1" in
    "autoload")
        dir="autoload"
        ;;
    "test")
        dir="test"
        ;;
    *)
        dir="$(echo -e "autoload\ntest" | eval "$filter")"
        if [[ -z $dir ]]; then
            exit
        fi
        ;;
esac

wc_files=( ${(@f)"$(wc -l $ZPLUG_ROOT/$dir/**/*(N.) | eval "$filter" | awk '{print $2}')"} )
if (( $#wc_files > 0 )); then
    vim -p "${wc_files[@]}"
fi
