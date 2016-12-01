__zplug::core::load::prepare()
{
    unsetopt monitor
    zstyle ':zplug:core:load' 'verbose' no
}

__zplug::core::load::from_cache()
{
    local is_verbose
    zstyle -s ':zplug:core:load' 'verbose' is_verbose

    # Default
    setopt monitor

    # Load the cache in order
    {
        source "$_zplug_cache[fpath]"
        source "$_zplug_cache[plugin]"
        source "$_zplug_cache[lazy_plugin]"
        source "$_zplug_cache[theme]"
        source "$_zplug_cache[command]"
        compinit -C -d /Users/b4b4r07/.zplug/zcompdump
        if (( $_zplug_boolean_true[(I)$is_verbose] )); then
            __zplug::io::print::f \
                --zplug "$fg[yellow]Run compinit$reset_color\n"
        fi
        source "$_zplug_cache[defer_1_plugin]"
        source "$_zplug_cache[defer_2_plugin]"
        source "$_zplug_cache[defer_3_plugin]"
    }

    # Cache in background
    {
        __zplug::core::cache::update
    } &!
}

__zplug::core::load::as_plugin()
{
    local    key value repo load_path hook
    local    is_verbose
    local -i status_code=0
    zstyle -s ':zplug:core:load' 'verbose' is_verbose

    __zplug::utils::shell::getopts "$argv[@]" \
        | while read key value; \
    do
        case "$key" in
            _)
                load_path="$value"
                ;;
            repo)
                repo="$value"
                ;;
            hook)
                hook="$value"
                ;;
        esac
    done

    source "$load_path" &>/dev/null
    status_code=$status

    if (( $_zplug_boolean_true[(I)$is_verbose] )); then
        if (( $status_code == 0 )); then
            print -nP -- " %F{148}Load %F{15}${(qqq)load_path/$HOME/~}%f ($repo)\n"
        else
            print -nP -- " %F{5}Failed to load %F{15}${(qqq)load_path/$HOME/~}%f ($repo)\n"
        fi
    fi
    if (( $status_code == 0 )) && [[ -n $hook ]]; then
        ${=hook}
    fi
}

__zplug::core::load::as_command()
{
    local    key value repo load_path _path hook
    local    is_verbose
    local -i status_code=0
    zstyle -s ':zplug:core:load' 'verbose' is_verbose

    __zplug::utils::shell::getopts "$argv[@]" \
        | while read key value; \
    do
        case "$key" in
            _)
                load_path="$value"
                ;;
            repo)
                repo="$value"
                ;;
            path)
                _path="$value"
                ;;
            hook)
                hook="$value"
                ;;
        esac
    done

    {
        chmod 755 "$load_path"
        ln -snf "$load_path" "$_path"
    } &>/dev/null
    status_code=$status

    if (( $_zplug_boolean_true[(I)$is_verbose] )); then
        if (( $status_code == 0 )); then
            print -nP -- " %F{148}Link %F{15}${(qqq)load_path/$HOME/~}%f ($repo)\n"
        else
            print -nP -- " %F{5}Failed to link %F{15}${(qqq)load_path/$HOME/~}%f ($repo)\n"
        fi
    fi
    if (( $status_code == 0 )) && [[ -n $hook ]]; then
        ${=hook}
    fi
}

__zplug::core::load::as_theme()
{
    __zplug::core::load::as_plugin "$argv[@]"
    if [[ ! -o prompt_subst ]]; then
        setopt prompt_subst
    fi
}

__zplug::core::load::skip_condition()
{
    # Returns true if there are conditions to skip,
    # returns false otherwise

    local repo="${1:?}"
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
