#!/bin/zsh

if (( $+functions[__import] )); then
    return 0
fi

typeset -gx -a ZPLUG_LIBS
ZPLUG_LIBS=()

__import() {
    local f arg is_debug=false

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

    if (( ! $ZPLUG_LIBS[(I)$f] )); then
        if $is_debug; then
            printf "$f\n"
        else
            source "$f"
        fi
        ZPLUG_LIBS+=("$f")
    fi
}
