#!/bin/zsh

if (( $+functions[__import] )); then
    return 0
fi
source $ZPLUG_ROOT/lib/core/core.zsh

typeset -gx -T _ZPLUG_LIB_CALLED _zplug_lib_called
_zplug_lib_called=()
local -a _zplug_lib_called

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
                f="$ZPLUG_ROOT/lib/${arg}.zsh"
                if [[ ! -f $f ]]; then
                    continue
                fi
                ;;
            *)
                return 1
                ;;
        esac
    done

    lib="${f:h:t}/${f:t:r}"
    if (( ! $_zplug_lib_called[(I)$lib] )); then
        if $is_debug; then
            printf "$f\n"
        else
            source "$f"
        fi
        _zplug_lib_called+=("$lib")
    fi
}
