__zplug::job::hook::service()
{
    local    repo="$1" hook="$2"
    local -A tags

    if (( $# < 2 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    # There is no $hook file in /autoload/tags directory
    if (( ! $+tags[$hook] )); then
        __zplug::io::print::f \
            --die \
            --zplug \
            "'%s' is not defined as a hook (%s)\n" \
            "$hook" \
            "$fg[green]$repo$reset_color"
        return 1
    fi

    if [[ -n $tags[$hook] ]]; then
        (
        __zplug::utils::shell::cd "$tags[dir]"
        alias sudo=__zplug::utils::shell::sudo

        # Save a result to the log file (stdout/stderr)
        eval "$tags[$hook]" \
            2> >(__zplug::io::log::capture_error) \
            1> >(__zplug::io::log::capture_execution)
        return $status

        #if (( $status != 0 )); then
        #    __zplug::io::print::f \
        #        --die \
        #        --zplug \
        #        --error \
        #        "'%s' failed\n" \
        #        "$tags[$hook]"
        #fi
        )
    fi
}

__zplug::job::hook::build()
{
    local repo="$1"

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::job::hook::service \
        "$repo" \
        "hook-build"
    return $status
}

__zplug::job::hook::load()
{
    local repo="$1"

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::job::hook::service \
        "$repo" \
        "hook-load"
    return $status
}

__zplug::job::hook::build_failure()
{
    local repo="$1"

    [[ -f $_zplug_config[build_failure] ]] && grep -x "$repo" "$_zplug_config[build_failure]" &>/dev/null
    return $status
}

__zplug::job::hook::build_timeout()
{
    local repo="$1"

    [[ -f $_zplug_config[build_timeout] ]] && grep -x "$repo" "$_zplug_config[build_timeout]" &>/dev/null
    return $status
}
