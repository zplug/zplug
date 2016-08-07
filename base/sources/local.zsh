__zplug::sources::local::check()
{
    local    repo="${1:?}"
    local -A tags
    local    expanded_path
    local -a expanded_paths

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    # Note: $tags[dir] can be a dir name or a file name
    expanded_paths=( $(
    zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo ${tags[dir]}" \
        2> >(__zplug::io::log::capture)
    ) )

    # Okay if at least one expanded path exists
    for expanded_path in ${expanded_paths[@]}
    do
        if [[ -e $expanded_path ]]; then
            return 0
        fi
    done

    __zplug::io::log::warn \
        "no matching file or directory in $tags[dir]"
    return 1
}

__zplug::sources::local::load_plugin()
{
    local    repo="${1:?}"
    local -A tags
    local -a load_plugins
    local -a load_fpaths
    local    expanded_path
    local -a expanded_paths

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    expanded_paths=( $(
    zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo ${tags[dir]}" \
        2> >(__zplug::io::log::capture)
    ) )

    for expanded_path in "${expanded_paths[@]}"
    do
        if [[ -f $expanded_path ]]; then
            load_plugins+=( "$expanded_path" )
        elif [[ -d $expanded_path ]]; then
            if [[ -n $tags[use] ]]; then
                load_plugins+=( $(
                zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo $expanded_path/$tags[use]" \
                    2> >(__zplug::io::log::capture)
                ) )
            else
                load_fpaths+=(
                    "$expanded_path"/{_*,**/_*}(N-.:h)
                )
            fi
        fi
    done

    if (( $#load_plugins == 0 )); then
        __zplug::io::log::warn \
            "no matching file or directory in $tags[dir]"
        return 1
    fi

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_plugins ]] && reply+=( load_plugins "${(F)load_plugins}" )

    return 0
}

__zplug::sources::local::load_command()
{
    local    repo="${1:?}"
    local -A tags
    local -a load_fpaths
    local -a load_commands
    local    expanded_path
    local -a expanded_paths
    local    dst

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    expanded_paths=( $(
    zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo $tags[dir]" \
        2> >(__zplug::io::log::capture)
    ) )
    dst=${${tags[rename-to]:+$ZPLUG_HOME/bin/$tags[rename-to]}:-"$ZPLUG_HOME/bin"}

    for expanded_path in "${expanded_paths[@]}"
    do
        if [[ -f $expanded_path ]]; then
            load_commands+=( "$expanded_path" )
        elif [[ -d $expanded_path ]]; then
            if [[ -n $tags[use] ]]; then
                load_commands+=( $(
                zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo $expanded_path/$tags[use]" \
                    2> >(__zplug::io::log::capture)
                ) )
            else
                load_fpaths+=(
                    "$expanded_path"/{_*,**/_*}(N-.:h)
                )
            fi
        fi
    done

    if (( $#load_commands == 0 )); then
        __zplug::io::log::warn \
            "no matching file or directory in $tags[dir]"
        return 1
    fi

    # Append dst to each element so that load_commands becomes:
    #
    # load_commands=(
    #   path/to/cmd1\0dst
    #   path/to/cmd2\0dst
    #   ...
    # )
    #
    # where \0 is a null character used to separate the two strings.
    #
    # In the caller function (__load__), each repo is decomposed into an
    # element in an associative array, thus, in the example above, the repo:
    #
    #   path/to/cmd1\0dst
    #
    # becomes an element where the key is "path/to/cmd" and the value is
    # "dst".
    load_commands=( ${^load_commands}"\0$dst" )

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_commands ]] && reply+=( load_commands "${(F)load_commands}" )

    return 0
}
