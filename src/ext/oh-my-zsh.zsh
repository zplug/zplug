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
    local    line
    local -A zspec

    line="$1"
    zspec=( ${(@f)"$(__parser__ "$line")"} )

    __clone__ \
        --use    ${zspec[use]:-""} \
        --from   "github" \
        --at     ${zspec[at]:-""} \
        --do     ${zspec[do]:-""} \
        --depth  ${zspec[depth]:-""} \
        "$_ZPLUG_OHMYZSH"

    return $status
}

__zplug::oh-my-zsh::load() {
}
