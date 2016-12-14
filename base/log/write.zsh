__zplug::log::write::error()
{
    __zplug::log::print::error "$argv[@]" \
        >>|"$_zplug_log[trace]"
}
