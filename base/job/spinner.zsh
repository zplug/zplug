typeset -g _zplug_spin_file="/tmp/._zplug_spin_file.$$$RANDOM"

__zplug::job::spinner::is_spin()
{
    [[ -f $_zplug_spin_file ]]
    return $status
}

__zplug::job::spinner::lock()
{
    __zplug::job::spinner::is_spin && return 1

    set +m
    touch "$_zplug_spin_file"
}

__zplug::job::spinner::unlock()
{
    __zplug::job::spinner::is_spin || return 1

    rm -f "$_zplug_spin_file"
}

__zplug::job::spinner::spin()
{
    local    spinner format="@"
    local -F latency=0.05
    local -a spinners

    spinners=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

    tput civis

    while __zplug::job::spinner::is_spin
    do
        for spinner in "${spinners[@]}"
        do
            __zplug::job::spinner::is_spin || break

            printf " $spinner\r" >/dev/stderr
            sleep "$latency"
        done
    done

    tput cnorm
    set -m
}

__zplug::job::spinner::echo()
{
    __zplug::job::spinner::is_spin || return 1
    __zplug::io::print::f "$argv[@]"
}
