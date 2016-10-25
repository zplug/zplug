__zplug::job::state::running()
{
    local job

    for job in "$argv[@]"
    do
        if kill -0 "$job" &>/dev/null; then
            return 0
        fi
    done

    return 1
}

__zplug::job::state::get() {
    local repo="${1:?}"
    local target="${2:-"install"}"

    if [[ ! -f $_zplug_config[${target}_status] ]]; then
        # TODO
        return 1
    fi

    cat "$_zplug_config[${target}_status]" \
        | grep "^repo:$repo" \
        | awk '{print $2}' \
        | cut -d: -f2
    return $status
}

__zplug::job::state::kill() {
    local pid="${1:?}"

    if ! __zplug::job::state::running "$pid"; then
        # TODO
        return $status
    fi

    kill -9 $pid &>/dev/null
    return $status
}

__zplug::job::state::flock()
{
    local file="${1:?}" contents="${2:?}"

    (
    zsystem flock -t 180 "$file"
    cant_lock=$status
    if (( cant_lock > 0 )); then
        {
            printf "Can't acquire lock for ${file}."
            if (( cant_lock == 2 )); then
                printf " timeout."
            fi
            printf "\n"
        } 1> >(__zplug::io::log::capture)
        return 1
    fi

    # Save the status code with LTSV
    __zplug::io::print::f "$contents\n" >>|"$file"
    )
}
