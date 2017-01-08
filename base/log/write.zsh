__zplug::log::write::error()
{
    __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::format::with_json "ERROR" "$argv[@]")"
}

__zplug::log::write::debug()
{
    __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::format::with_json "DEBUG" "$argv[@]")"
}

__zplug::log::write::info()
{
    __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::format::with_json "INFO" "$argv[@]")"
}
