__zplug::log::capture::error()
{
    local message="$(<&0)"

    if [[ -z $message ]]; then
        return 0
    fi

    __zplug::log::format::with_json \
        --level "ERROR" --message "$message" "$argv[@]" \
        >>|"$_zplug_log[trace]"
}

__zplug::log::capture::debug()
{
    local message="$(<&0)"

    if [[ -z $message ]]; then
        return 0
    fi

    __zplug::log::format::with_json \
        --level "DEBUG" --message "$message" "$argv[@]" \
        >>|"$_zplug_log[trace]"
}
