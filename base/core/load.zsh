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

__zplug::core::load::load()
{
    # Suppress verbose message
    zstyle ':zplug:core:load' verbose no
    # Load from cache
    __zplug::core::load::from_cache
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

__zplug::core::load::profile()
{
    if [[ ! -f $_zplug_cache[profile] ]] || [[ -z $argv[1] ]]; then
        return 1
    fi

    __zplug::job::state::flock \
        "$_zplug_cache[profile]" \
        "$argv[@]"
}

__zplug::core::load::skip_condition()
{
    # Returns true if there are conditions to skip,
    # returns false otherwise

    local    repo="${1:?}"
    local -A tags

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    if __zplug::core::sources::is_handler_defined check "$tags[from]"; then
        if ! __zplug::core::sources::use_handler check "$tags[from]" "$repo"; then
            return 0
        fi
    else
        if [[ ! -d $tags[dir] ]]; then
            return 0
        fi
    fi

    if [[ -n $tags[if] ]]; then
        if ! eval "$tags[if]" 2> >(__zplug::io::log::capture) >/dev/null; then
            $is_verbose && __zplug::io::print::die "$tags[name]: (not loaded)\n"
            return 0
        fi
    fi

    if [[ -n $tags[on] ]]; then
        __zplug::core::core::run_interfaces \
            'check' \
            ${~tags[on]}
        if (( $status != 0 )); then
            $is_verbose && __zplug::io::print::die "$tags[name]: (not loaded)\n"
            return 0
        fi
    fi

    return 1
}
