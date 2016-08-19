__zplug::core::commands::get()
{
    __zplug::core::core::get_interfaces \
        "commands" \
        "$argv[@]"
}

__zplug::core::commands::user_defined()
{
    local -a user_cmds

    # reset
    reply=()

    user_cmds=( ${^path[@]}/zplug-*(N-.:t:gs:zplug-:) )
    if (( $#user_cmds > 0 )); then
        # Be unique
        reply+=( "${(u)user_cmds[@]}" )
        return 0
    fi

    return 1
}
