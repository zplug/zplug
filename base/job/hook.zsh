__zplug::job::hook::service()
{
    local    repo="${1:?}" hook="${2:?}"
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

        eval "$tags[$hook]" 2> >(__zplug::io::log::capture)
        if (( $status != 0 )); then
            __zplug::io::print::f \
                --die \
                --zplug \
                --error \
                "'%s' failed\n" \
                "$tags[$hook]"
        fi
        )
    fi
}

__zplug::job::hook::build()
{
    local repo="${1:?}"

    __zplug::job::hook::service \
        "$repo" \
        "hook-build"
}

__zplug::job::hook::load()
{
    local repo="${1:?}"

    __zplug::job::hook::service \
        "$repo" \
        "hook-load"
}
