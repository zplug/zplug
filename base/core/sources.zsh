__zplug::core::sources::is_exists()
{
    local source_name="$1"

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    [[ -f $ZPLUG_ROOT/base/sources/$source_name.zsh ]]
    return $status
}

__zplug::core::sources::is_handler_defined()
{
    local subcommand="$1" source_name="$2" handler_name
    handler_name="__zplug::sources::$source_name::$subcommand"

    if (( $# < 2 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    if ! __zplug::core::sources::is_exists "$source_name"; then
        return $_ZPLUG_STATUS_FALSE
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

    if (( $# < 3 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    case "$repo" in
        "zplug/zplug")
            # Search the handler that has a name including 'self' word
            handler_name="__zplug::core::self::$subcommand"
            (( $+functions[$handler_name] )) ||
                handler_name="__zplug::sources::github::$subcommand"
            # If it isn't found, search another handler
            # Nevertheless, callback is undefined
            (( $+functions[$handler_name] )) ||
                return $_ZPLUG_STATUS_FAILURE
            ;;
        *)
            if ! __zplug::core::sources::is_handler_defined "$subcommand" "$source_name"; then
                # Callback function is undefined
                return $_ZPLUG_STATUS_FAILURE
            fi
            ;;
    esac

    eval "$handler_name '$repo'"
    return $status
}

__zplug::core::sources::call()
{
    local val="$1"

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    if __zplug::core::sources::is_exists "$val"; then
        {
            # Directory '/base/sources' needs to be included in FPATH
            autoload -Uz "$val.zsh"
            eval "$val.zsh"
            unfunction "$val.zsh"
        } \
            2> >(__zplug::io::log::capture) >/dev/null

    fi
}

__zplug::core::sources::use_default()
{
    local val

    # Get the default value
    val="$(__zplug::core::core::run_interfaces 'from')"

    __zplug::core::sources::call "$val"
}
