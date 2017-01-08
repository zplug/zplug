__zplug::log::capture::error()
{
    local message="$(<&0)"

    if [[ -z $message ]]; then
        return 0
    fi

    __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::format::with_json "ERROR" "$message")"
}

__zplug::log::capture::debug()
{
    local message="$(<&0)"

    if [[ -z $message ]]; then
        return 0
    fi

    __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::format::with_json "DEBUG" "$message")"
}

__zplug::log::capture::info()
{
    local message="$(<&0)"

    if [[ -z $message ]]; then
        return 0
    fi

    __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::format::with_json "INFO" "$message")"
}
