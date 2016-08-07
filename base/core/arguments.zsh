__zplug::core::arguments::exec()
{
    local arg="$1"

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    reply=()
    __zplug::core::commands::user_defined

    # User-defined command
    if [[ -n ${(M)reply[@]:#$arg} ]]; then
        eval "$commands[zplug-$arg]"
        return $status
    fi

    # Fuzzy match
    if ! __zplug::core::arguments::auto_correct "$arg"; then
        return 1
    fi

    zplug "$reply[1]" ${2:+"$argv[2,-1]"}
}

__zplug::core::arguments::auto_correct()
{
    local    arg="$1"
    local -i ret=0
    local -a cmds reply_cmds

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    reply_cmds=()

    # Add user-defined commands
    __zplug::core::commands::user_defined
    reply_cmds+=( "${reply[@]}" )

    # Add zplug subcommands
    __zplug::core::commands::get --key
    reply_cmds+=( "${reply[@]}" )

    cmds=(
    ${(@f)"$(awk \
        -f "$_ZPLUG_AWKPATH/fuzzy.awk" \
        -v search_string="$arg" \
        <<<"${(F)reply_cmds:gs:_:}"
    )":-}
    )

    case $#cmds in
        0)
            __zplug::io::print::f \
                --die \
                --zplug \
                "$arg: no such command\n"
            ret=1
            ;;
        1)
            __zplug::io::print::f \
                --die \
                --zplug \
                --warn \
                "You called a zplug command named '%s', which does not exist.\n" \
                "Continuing under the assumption that you meant '%s'.\n" \
                -- \
                "$arg" \
                "$fg[green]$cmds[1]$reset_color"

            reply=( "$cmds[1]" )
            ;;
        *)
            __zplug::io::print::f \
                --die \
                --zplug \
                --warn \
                "'%s' is not a zplug command. see 'zplug --help'.\n" \
                "Did you mean one of these?\n" \
                -- \
                "$arg"
            __zplug::io::print::die \
                "$fg[yellow]\t- $reset_color%s\n" \
                "${cmds[@]}"

            ret=1
            ;;
    esac

    return $ret
}

__zplug::core::arguments::none()
{
    # TODO
    :
}
