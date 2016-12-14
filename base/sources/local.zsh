__zplug::sources::local::check()
{
    local    repo="$1"
    local -A tags
    local    expanded_path
    local -a expanded_paths

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    # Note: $tags[dir] can be a dir name or a file name
    expanded_paths=( ${(@f)"$( \
        __zplug::utils::shell::expand_glob "$tags[dir]"
    )"} )

    # Okay if at least one expanded path exists
    for expanded_path in ${expanded_paths[@]}
    do
        if [[ -e $expanded_path ]]; then
            return 0
        fi
    done

    __zplug::log::write::error \
        "no matching file or directory in $tags[dir]"
    return 1
}

__zplug::sources::local::load_plugin()
{
    __zplug::sources::github::load_plugin "$argv[@]"
}

__zplug::sources::local::load_command()
{
    __zplug::sources::github::load_command "$argv[@]"
}

__zplug::sources::local::load_theme()
{
    __zplug::sources::github::load_theme "$argv[@]"
}
