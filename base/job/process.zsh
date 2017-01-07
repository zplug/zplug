__zplug::job::process::is_running()
{
    local job

    for job in "$argv[@]"
    do
        [[ $job == "" ]] && return 1
        if kill -0 "$job" &>/dev/null; then
            return 0
        fi
    done

    return 1
}

__zplug::job::process::get_status_code() {
    local repo="${1:?}" target="${2:?}"

    if [[ ! -f $_zplug_log[$target] ]]; then
        # TODO
        return 1
    fi

    cat "$_zplug_log[$target]" \
        | __zplug::utils::awk::ltsv \
        'key("repo")=="'"$repo"'"{print key("status")}'

    return $status
}

__zplug::job::process::kill() {
    local pid="${1:?}"

    if ! __zplug::job::process::is_running "$pid"; then
        # TODO
        return $status
    fi

    kill -9 $pid &>/dev/null
    return $status
}
