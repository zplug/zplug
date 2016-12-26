__zplug::core::migration::tags()
{
    local key="$1" new_key

    case "$key" in
        "of")
            new_key="use"
            ;;
        "file")
            new_key="rename-to"
            ;;
        "commit")
            new_key="at"
            ;;
        "do")
            new_key="hook-build"
            ;;
        "nice")
            new_key="defer"
            ;;
        *)
            # Not old tag
            __zplug::io::print::f \
                --die \
                --zplug \
                "$key: this tag is still good\n"
            return 1
    esac

    __zplug::io::print::f \
        --die \
        --zplug \
        --warn \
        "'%s' tag is deprecated. Please use '%s' tag instead (%s).\n" \
        "$fg[blue]$key$reset_color" \
        "$fg[blue]$new_key$reset_color" \
        "$fg[green]${name:gs:@::}$reset_color"

    return 1
}

__zplug::core::migration::pipe()
{
    __zplug::io::print::f \
        --die \
        --zplug \
        --warn \
        "pipe syntax is deprecated! Please use '%s' tag instead.\n" \
        "$fg[blue]on$reset_color"
    return 1
}

__zplug::core::migration::cache_file_dir()
{
    # If ZPLUG_CACHE_FILE is defined
    if [[ -f $ZPLUG_CACHE_DIR ]]; then
        rm -f "$ZPLUG_CACHE_DIR"
    fi
    mkdir -p "$ZPLUG_CACHE_DIR"
}
