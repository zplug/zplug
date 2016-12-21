__zplug::log::write::error()
{
    __zplug::job::handle::flock --escape \
        "$_zplug_log[trace]" \
        "$(__zplug::log::print::error "${argv[@]:-}")"
}
