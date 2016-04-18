#!/bin/zsh

__zplug::local::check() {
    local    line
    local -A zspec

    line="$1"
    __parser__ "$line"
    zspec=( "${reply[@]}" )

    # Note: $zspec[dir] can be a dir name or a file name
    [[ -e ${~zspec[dir]} ]]
}

__zplug::local::load_plugin() {
    local    line
    local -A zspec

    line="$1"
    __parser__ "$line"
    zspec=( "${reply[@]}" )

    local -a load_patterns
    local -a load_fpaths

    if [[ -f ${~zspec[dir]} ]]; then
        load_patterns+=( $(zsh -c "echo ${zspec[dir]}" 2>/dev/null) )
    elif [[ -d ${~zspec[dir]} ]]; then
        if [[ -n $zspec[use] ]]; then
            load_patterns+=( $(zsh -c "echo $zspec[dir]/$zspec[use]" 2>/dev/null) )
        else
            load_fpaths+=(
                ${~zspec[dir]}/{_*,**/_*}(N-.:h)
            )
        fi
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
    local dst

    dst=${${zspec[rename-to]:+$ZPLUG_HOME/bin/$zspec[rename-to]}:-"$ZPLUG_HOME/bin"}

    if [[ -f ${~zspec[name]} ]]; then
        # Expand special characters such as ~ to $HOME
        # echo "${~foo}" with the double quotes doesn't expand for some reason
        load_commands+=( "$(zsh -c "echo ${zspec[name]}" 2>/dev/null)" )
    elif [[ -d ${~zspec[name]} ]]; then
        if [[ -n $zspec[use] ]]; then
            load_commands+=( $(zsh -c "echo $zspec[name]/$zspec[use]" 2>/dev/null) )
        fi

        load_fpaths+=( ${~zspec[name]}{_*,/**/_*}(N-.:h) )
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
