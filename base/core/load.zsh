__zplug::core::load::cache()
{
    # Load the cache in order
    {
        source "$_zplug_cache[fpath]"
        source "$_zplug_cache[plugin]"
        source "$_zplug_cache[lazy_plugin]"
        source "$_zplug_cache[theme]"
        source "$_zplug_cache[command]"
        source "$_zplug_cache[hook-load]"
        compinit -C -d /Users/b4b4r07/.zplug/zcompdump
        source "$_zplug_cache[before_plugin]"
        source "$_zplug_cache[after_plugin]"
    } #&>/dev/null
}

__zplug::core::load::plugins()
{
    :
}

__zplug::core::load::commands()
{
    :
}

__zplug::core::load::themes()
{
    :
}
