#!/usr/bin/env zsh

__import "print/print"

typeset -g spin_file=/tmp/.spin.$$$RANDOM

__zplug::job::spinner::is_spin() {
    [[ -f $spin_file ]]
}

__zplug::job::spinner::lock() {
    if ! __zplug::job::spinner::is_spin; then
        set +m
        touch $spin_file &>/dev/null
    fi
}

__zplug::job::spinner::unlock() {
    if __zplug::job::spinner::is_spin; then
        rm -f $spin_file &>/dev/null
    fi
}

__zplug::job::spinner::spinner() {
    local    spin format
    local -F latency
    local -a spinners

    # spinners=("⠄" "⠆" "⠇" "⠋" "⠙" "⠸" "⠰" "⠠" "⠰" "⠸" "⠙" "⠋" "⠇" "⠆")
    spinners=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    format="@"
    latency=0.03

    while __zplug::job::spinner::is_spin
    do
        for spin in $spinners
        do
            __zplug::job::spinner::is_spin || break
            __zplug::print::print::put "$format" | awk -v t=$latency -v i=$(__zplug::print::print::put "$spin" | sed 's/=/\\\=/') '
            {
                system("tput civis")
                gsub("@", i)
                printf("%s\r", $0)
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

__zplug::job::spinner::echo() {
    if __zplug::job::spinner::is_spin; then
        __zplug::print::print::put "$@"
        return 0
    else
        return 1
    fi
}
