#!/usr/bin/env zsh
# init.zsh:
#   This file is called only once

if (( $+functions[__import] )); then
    return 0
fi

typeset -gx -T \
    _ZPLUG_LIB_CALLED \
    _zplug_lib_called

_zplug_lib_called=()

__import() {
    local f arg lib is_debug=false

    while (( $# > 0 ))
    do
        arg="$1"
        case "$arg" in
            --debug)
                shift
                is_debug=true
                ;;
            -*|--*)
                return 1
                ;;
            */*)
                shift
                f="$ZPLUG_ROOT/base/${arg}.zsh"
                if [[ ! -f $f ]]; then
                    f=""
                    continue
                fi
                ;;
            *)
                return 1
                ;;
        esac
    done

    # invalid argument
    if [[ -z $f ]]; then
        return 1
    fi

    lib="${f:h:t}/${f:t:r}"
    if (( ! $_zplug_lib_called[(I)$lib] )); then
        if $is_debug; then
            printf "$f\n"
        else
            fpath=(
            "${f:h}"
            "${fpath[@]}"
            )
            autoload -Uz "${f:t}" && eval "${f:t}"
            unfunction "${f:t}"
        fi
        _zplug_lib_called+=("$lib")
    fi
}
