#!/bin/zsh

__zplug::sources::${0:t:r}::install() {
    local    line
    local -A zspec

    line="$1"
    __parser__ "$line"
    zspec=( "${reply[@]}" )

    __clone__ \
        --use    ${zspec[use]:-""} \
        --from   ${zspec[from]:-""} \
        --at     ${zspec[at]:-""} \
        --depth  ${zspec[depth]:-""} \
        "$line"

    return $status
}
