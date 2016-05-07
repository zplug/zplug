#!/bin/zsh

__import "print/print"

has_awk() {
    local    p awk_path awk_variant
    local -a all_awk

    # Look up all awk from PATH
    for p in ${^path[@]}/{g,n,m,}awk
    do
        if [[ -x $p ]]; then
            all_awk+=("$p")
        fi
    done

    # There is no awk execute file in PATH
    if (( $#all_awk == 0 )); then
        __zplug::print::print::die \
            "[zplug] has_awk(): cannot find awk\n"
        return 1
    fi

    # Detect awk variant from available awk list
    for p in "${all_awk[@]}"
    do
        if $p --version 2>&1 | grep -q "GNU Awk"; then
            # GNU Awk
            awk_path="$p"
            awk_variant="gawk"
            # Use gawk if it's already installed
            break
        elif $p -Wv 2>&1 | grep -q "mawk"; then
            # mawk
            awk_variant="mawk"
        else
            # nawk
            awk_path="$p"
            awk_variant="nawk"
            # Search another variant if awk is nawk
            continue
        fi
    done

    # If only mawk is installed
    if [[ $awk_variant == "mawk" ]]; then
        __zplug::print::print::die \
            "[zplug] your machine has only $awk_variant. zplug require nawk or more\n"
        return 1
    else
        __zplug::print::print::put \
            "$awk_path\n"
    fi
}
