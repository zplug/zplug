__zplug::job::hook::service()
{
    local    repo="$1" hook="$2"
    local -A tags

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
            2> >(__zplug::log::capture::error) \
            1> >(__zplug::log::capture::debug)
        return $status
        )
    fi
}

__zplug::job::hook::build()
{
    local repo="$1"

    __zplug::job::hook::service \
        "$repo" \
        "hook-build"
    return $status
}

__zplug::job::hook::load()
{
    local repo="$1"

    __zplug::job::hook::service \
        "$repo" \
        "hook-load"
    return $status
}

__zplug::job::hook::build_failure()
{
    local repo="$1"

    [[ -f $_zplug_build_log[failure] ]] && grep -x "$repo" "$_zplug_build_log[failure]" &>/dev/null
    return $status
}

__zplug::job::hook::build_timeout()
{
    local repo="$1"

    [[ -f $_zplug_build_log[timeout] ]] && grep -x "$repo" "$_zplug_build_log[timeout]" &>/dev/null
    return $status
}
