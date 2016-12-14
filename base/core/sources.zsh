__zplug::core::sources::is_exists()
{
    local source_name="$1"

    [[ -f $ZPLUG_ROOT/base/sources/$source_name.zsh ]]
    return $status
}

__zplug::core::sources::is_handler_defined()
{
    local subcommand="$1" source_name="$2" handler_name
    handler_name="__zplug::sources::$source_name::$subcommand"

    if ! __zplug::core::sources::is_exists "$source_name"; then
        return $_zplug_status[failure]
    fi

    (( $+functions[$handler_name] ))
    return $status
}

# Call the handler of the external source if defined
__zplug::core::sources::use_handler()
{
    local \
        subcommand="$1" \
        source_name="$2" \
        repo="$3"
    local handler_name="__zplug::sources::$source_name::$subcommand"

    if ! __zplug::core::sources::is_handler_defined "$subcommand" "$source_name"; then
        # Callback function is undefined
        return $_zplug_status[failure]
    fi

    eval "$handler_name '$repo'"
    return $status
}

__zplug::core::sources::call()
{
    local val="$1"

    if __zplug::core::sources::is_exists "$val"; then
        {
            # Directory '/base/sources' needs to be included in FPATH
            autoload -Uz "$val.zsh"
            eval "$val.zsh"
            unfunction "$val.zsh"
        } \
            2> >(__zplug::log::capture::error) >/dev/null

    fi
}

__zplug::core::sources::use_default()
{
    local val

    # Get the default value
    val="$(__zplug::core::core::run_interfaces 'from')"

    __zplug::core::sources::call "$val"
}
