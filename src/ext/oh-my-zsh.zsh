#!/bin/sh

__import "support/omz"

__zplug::oh-my-zsh::check() {
    local    line
    local -A zspec

    line="$1"
    zspec=( ${(@f)"$(__parser__ "$line")"} )

    [[ -d ${zspec[dir]:h} ]]
}

__zplug::oh-my-zsh::install() {
}

__zplug::oh-my-zsh::load() {
}
