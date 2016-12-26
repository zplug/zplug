__zplug::log::write::error()
{
    __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::print::error "${argv[@]:-}")"
}

__zplug::log::write::info()
{
    __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::print::info "${argv[@]:-}")"
}
