__zplug::log::write::error()
{
    $ZPLUG_LOG_TRACE && __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::format::with_json "ERROR" "$argv[@]")"
}

__zplug::log::write::debug()
{
    $ZPLUG_LOG_TRACE && __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::format::with_json "DEBUG" "$argv[@]")"
}

__zplug::log::write::info()
{
    $ZPLUG_LOG_TRACE && __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::format::with_json "INFO" "$argv[@]")"
}
