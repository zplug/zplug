__zplug::sources::local::check()
{
    local    repo="$1"
    local -A tags
    local    expanded_path
    local -a expanded_paths

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

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

    __zplug::io::log::warn \
        "no matching file or directory in $tags[dir]"
    return 1
}

__zplug::sources::local::load_plugin()
{
    local    repo="$1"
    local -A tags
    local -a unclassified_plugins
    local -a load_fpaths
    local    expanded_path
    local -a expanded_paths
    local    lazy_pattern

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    # Assume unspecified USE tag is '' rather than '*.zsh'
    if [[ $tags[use] == '*.zsh' ]]; then
        lazy_pattern=''
    else
        lazy_pattern="$tags[use]"
    fi

    expanded_paths=( ${(@f)"$( \
        __zplug::utils::shell::expand_glob "${tags[dir]}${lazy_pattern:+/$lazy_pattern}"
    )"} )

    for expanded_path in "${expanded_paths[@]}"
    do
        if [[ -f $expanded_path ]]; then
            unclassified_plugins+=( "$expanded_path" )

            # Add parent directory to fpath
            if (( $_zplug_boolean_true[(I)$tags[lazy]] )); then
                load_fpaths+=( $expanded_path(N-.:h) )
            fi
        elif [[ -d $expanded_path ]]; then
            if (( $_zplug_boolean_true[(I)$tags[lazy]] )); then
                load_fpaths+=( $expanded_path(N-/) )
            else
                # Note: $tags[use] defaults to '*.zsh'
                unclassified_plugins+=( ${(@f)"$(
                    __zplug::utils::shell::expand_glob "$expanded_path/$tags[use]"
                )"} )

                load_fpaths+=(
                    "$expanded_path"/{_*,**/_*}(N-.:h)
                )
            fi
        fi
    done

    if (( $#unclassified_plugins == 0 )) && (( $#load_fpaths == 0 )); then
        __zplug::io::log::warn \
            "no matching file or directory in $tags[dir]"
        return 1
    fi

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $unclassified_plugins ]] && reply+=( unclassified_plugins "${(F)unclassified_plugins}" )

    return 0
}

__zplug::sources::local::load_command()
{
    local    repo="$1"
    local -A tags
    local -a load_fpaths
    local -a load_commands
    local    expanded_path
    local -a expanded_paths
    local    dst

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    expanded_paths=( ${(@f)"$( \
        __zplug::utils::shell::expand_glob "$tags[dir]"
    )"} )
    dst=${${tags[rename-to]:+$ZPLUG_HOME/bin/$tags[rename-to]}:-"$ZPLUG_HOME/bin"}

    for expanded_path in "${expanded_paths[@]}"
    do
        if [[ -f $expanded_path ]]; then
            load_commands+=( "$expanded_path" )
        elif [[ -d $expanded_path ]]; then
            if [[ $tags[use] != '*.zsh' ]]; then
                load_commands+=( ${(@f)"$(
                    __zplug::utils::shell::expand_glob "$expanded_path/$tags[use]"
                )"} )
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
