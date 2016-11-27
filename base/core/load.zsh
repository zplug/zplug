__zplug::core::load::prepare()
{
    unsetopt monitor

    if [[ -f $ZPLUG_CACHE_FILE ]]; then
        rm -rf "$ZPLUG_CACHE_FILE"
    fi

    mkdir -p "$ZPLUG_CACHE_FILE"

    local file
    for file in "${(k)_zplug_cache[@]}"
    do
        rm -f "$_zplug_cache[$file]"
        touch "$_zplug_cache[$file]"
    done
}

__zplug::core::load::from_cache()
{
    local is_verbose=false

    zstyle -s ':zplug:core:load' verbose is_verbose

    if (( $_zplug_boolean_true[(I)$is_verbose] )); then
        __zplug::io::print::f \
            --zplug \
            "$fg[yellow]Load from cache$reset_color\n"
    fi

    # Default
    setopt monitor

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
    } &>/dev/null

    # Cache in background
    {
        __zplug::core::cache::update
    } &!
}

__zplug::core::load::as_plugin()
{
    :
}

__zplug::core::load::as_command()
{
    :
}

__zplug::core::load::as_theme()
{
    :
}
