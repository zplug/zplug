#!/bin/zsh

__import "print/print"

typeset -g spin_file=/tmp/.spin.$$$RANDOM

__is_spin() {
    [[ -f $spin_file ]]
}

__spin_lock() {
    if ! __is_spin; then
        set +m
        touch $spin_file &>/dev/null
    fi
}

__spin_unlock() {
    if __is_spin; then
        rm -f $spin_file &>/dev/null
    fi
}

__spinner() {
    local    spin format
    local -F latency
    local -a spinners

    # spinners=("⠄" "⠆" "⠇" "⠋" "⠙" "⠸" "⠰" "⠠" "⠰" "⠸" "⠙" "⠋" "⠇" "⠆")
    spinners=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    format="@\r"
    latency=0.03

    while __is_spin
    do
        for spin in $spinners
        do
            __is_spin || break
            __put "$format" | awk -v t=$latency -v i=$(__put "$spin" | sed 's/=/\\\=/') '
            {
                system("tput civis")
                gsub("@", i)
                printf("%s", $0)
                fflush()
                system("sleep "t"")
            }
            ' >/dev/stderr
        done
    done

    tput cnorm
    awk 'END { fflush() }'
    printf "\r\033[0K"
    set -m
}

__spinner_echo() {
    if __is_spin; then
        __put "$@"
        return 0
    else
        return 1
    fi
}
