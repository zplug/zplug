__zplug::core::arguments::exec()
{
    local arg="$1"
    shift

    reply=()
    __zplug::core::commands::user_defined

    # User-defined command
    if [[ -n ${(M)reply[@]:#$arg} ]]; then
        eval "$commands[zplug-$arg]" "$argv[@]"
        return $status
    fi

    # User-defined function
    if (( $+functions[zplug-$arg] )); then
        zplug-$arg "$argv[@]"
        return $status
    fi

    # Fuzzy match
    if ! __zplug::core::arguments::auto_correct "$arg"; then
        return 1
    fi

    zplug "$reply[1]" "$argv[@]"
}

__zplug::core::arguments::auto_correct()
{
    local    arg="$1"
    local -i ret=0
    local -a cmds reply_cmds

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
