#!/usr/bin/env zsh

__zplug::local::check() {
    local    line
    local -A zspec

    line="$1"
    __parser__ "$line"
    zspec=( "${reply[@]}" )

    local    expanded_path
    local -a expanded_paths

    # Note: $zspec[dir] can be a dir name or a file name
    expanded_paths=( $(zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo ${zspec[dir]}" 2>/dev/null) )

    # Okay if at least one expanded path exists
    for expanded_path in ${expanded_paths[@]}
    do
        if [[ -e $expanded_path ]]; then
            return 0
        fi
    done

    __zplug::print::print::die "[zplug] no matching file or directory: ${zspec[dir]}\n"
    return 1
}

__zplug::local::load_plugin() {
    local    line
    local -A zspec

    line="$1"
    __parser__ "$line"
    zspec=( "${reply[@]}" )

    local -a load_patterns
    local -a load_fpaths
    local    expanded_path
    local -a expanded_paths

    expanded_paths=( $(zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo ${zspec[dir]}" 2>/dev/null) )

    for expanded_path in ${expanded_paths[@]}
    do
        if [[ -f $expanded_path ]]; then
            load_patterns+=( $expanded_path )
        elif [[ -d $expanded_path ]]; then
            if [[ -n $zspec[use] ]]; then
                load_patterns+=( $(zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo $expanded_path/$zspec[use]" 2>/dev/null) )
            else
                load_fpaths+=(
                    $expanded_path/{_*,**/_*}(N-.:h)
                )
            fi
        fi
    done

    if (( $#load_patterns == 0 )); then
        __zplug::print::print::die "[zplug] no matching file or directory: ${zspec[dir]}\n"
        return 1
    fi

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_patterns ]] && reply+=( load_patterns "${(F)load_patterns}" )

    return 0
}

__zplug::local::load_command() {
    local    line
    local -A zspec

    line="$1"
    __parser__ "$line"
    zspec=( "${reply[@]}" )

    local -a load_fpaths
    local -a load_commands
    local    expanded_path
    local -a expanded_paths
    local dst

    expanded_paths=( $(zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo ${zspec[dir]}" 2>/dev/null) )

    dst=${${zspec[rename-to]:+$ZPLUG_HOME/bin/$zspec[rename-to]}:-"$ZPLUG_HOME/bin"}

    for expanded_path in ${expanded_paths[@]}
    do
        if [[ -f $expanded_path ]]; then
            load_commands+=( $expanded_path )
        elif [[ -d $expanded_path ]]; then
            if [[ -n $zspec[use] ]]; then
                load_commands+=( $(zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo $expanded_path/$zspec[use]" 2>/dev/null) )
            else
                load_fpaths+=(
                    $expanded_path/{_*,**/_*}(N-.:h)
                )
            fi
        fi
    done

    if (( $#load_commands == 0 )); then
        __zplug::print::print::die "[zplug] no matching file or directory: ${zspec[dir]}\n"
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
    # In the caller function (__load__), each line is decomposed into an
    # element in an associative array, thus, in the example above, the line:
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
