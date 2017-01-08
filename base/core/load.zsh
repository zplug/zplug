__zplug::core::load::prepare()
{
    setopt nomonitor
    zstyle ':zplug:core:load' 'verbose' no

    __zplug::io::file::rm_touch "$_zplug_load_log[success]"
    __zplug::io::file::rm_touch "$_zplug_load_log[failure]"
}

__zplug::core::load::from_cache()
{
    local is_verbose
    zstyle -s ':zplug:core:load' 'verbose' is_verbose

    # Default
    # setopt monitor

    __zplug::core::cache::update

    # Load the cache in order
    {
        fpath=(
        ${(@f)"$(<$_zplug_cache[fpath])"}
        "$fpath[@]"
        )

        source "$_zplug_cache[plugin]"
        source "$_zplug_cache[lazy_plugin]"
        source "$_zplug_cache[theme]"
        source "$_zplug_cache[command]"

        # Plugins with defer-level set
        source "$_zplug_cache[defer_1_plugin]"
        compinit -d "$ZPLUG_HOME/zcompdump"
        if (( $_zplug_boolean_true[(I)$is_verbose] )); then
            __zplug::io::print::f \
                --zplug "$fg[yellow]Run compinit$reset_color\n"
        fi
        source "$_zplug_cache[defer_2_plugin]"
        source "$_zplug_cache[defer_3_plugin]"
    }

    if [[ -s $_zplug_load_log[failure] ]]; then
        # If there are repos that failed to load,
        # show those repos and return false
        __zplug::io::print::f \
            --zplug \
            "These repos have failed to load:\n$fg_bold[red]"
        print -l -- "- $fg[red]"${^${(u@f)"$(<"$_zplug_load_log[failure]")":gs:@:}}"$reset_color"
        __zplug::io::print::f "$reset_color"
        return 1
    fi
}

__zplug::core::load::as_plugin()
{
    local    key value repo load_path hook is_lazy=false
    local    is_verbose msg
    local -i status_code=0
    zstyle -s ':zplug:core:load' 'verbose' is_verbose

    while (( $#argv > 0 ))
    do
        case "$argv[1]" in
            --repo)
                repo="$argv[2]"
                shift
                ;;
            --hook)
                hook="$argv[2]"
                shift
                ;;
            --lazy)
                is_lazy=true
                ;;
            *)
                load_path="$argv[1]"
                ;;
        esac
        shift
    done

    # Special measure
    if [[ $repo == 'zplug/zplug' ]]; then
        # In the case of zplug, don't load it exceptionally
        return 0
    fi

    if [[ $load_path =~ $_ZPLUG_OHMYZSH ]]; then
        # Check if omz is loaded and set some necessary settings
        if [[ -z $ZSH ]]; then
            export ZSH="$ZPLUG_REPOS/$_ZPLUG_OHMYZSH"
            export ZSH_CACHE_DIR="$ZSH/cache/"
        fi
    fi

    if $is_lazy; then
        msg="Lazy"
        autoload -Uz "${load_path:t}"
        status_code=$status
    else
        msg="Load"
        source "$load_path" 2> >(__zplug::log::capture::error)
        status_code=$status
    fi

    if (( $_zplug_boolean_true[(I)$is_verbose] )); then
        if (( $status_code == 0 )); then
            __zplug::io::print::f " $msg ${(qqq)load_path/$HOME/~} ($repo)\n"
        else
            __zplug::io::print::f --warn " Failed to load ${(qqq)load_path/$HOME/~} ($repo)\n"
        fi
    fi

    if (( $status_code == 0 )); then
        if [[ -n $hook ]]; then
            eval ${=hook}
        fi
        __zplug::job::handle::flock "$_zplug_load_log[success]" "$repo"
    else
        __zplug::job::handle::flock "$_zplug_load_log[failure]" "$repo"
    fi

    return $status_code
}

__zplug::core::load::as_command()
{
    local    key value repo load_path _path hook
    local    is_verbose
    local -i status_code=0
    zstyle -s ':zplug:core:load' 'verbose' is_verbose

    while (( $#argv > 0 ))
    do
        case "$argv[1]" in
            --repo)
                repo="$argv[2]"
                shift
                ;;
            --hook)
                hook="$argv[2]"
                shift
                ;;
            --path)
                _path="$argv[2]"
                shift
                ;;
            *)
                load_path="$argv[1]"
                ;;
        esac
        shift
    done

    {
        chmod 755 "$load_path"
        ln -snf "$load_path" "$_path"
    } &>/dev/null
    status_code=$status

    if (( $_zplug_boolean_true[(I)$is_verbose] )); then
        if (( $status_code == 0 )); then
            __zplug::io::print::f " Link ${(qqq)load_path/$HOME/~} ($repo)\n"
        else
            __zplug::io::print::f --warn " Failed to link ${(qqq)load_path/$HOME/~} ($repo)\n"
        fi
    fi

    if (( $status_code == 0 )); then
        if [[ -n $hook ]]; then
            eval ${=hook}
        fi
        __zplug::job::handle::flock "$_zplug_load_log[success]" "$repo"
    else
        __zplug::job::handle::flock "$_zplug_load_log[failure]" "$repo"
    fi

    return $status_code
}

__zplug::core::load::as_theme()
{
    local -i ret=0

    __zplug::core::load::as_plugin "$argv[@]"
    ret=$status

    if [[ ! -o prompt_subst ]]; then
        setopt prompt_subst
    fi

    return $ret
}

__zplug::core::load::skip_condition()
{
    # Returns true if there are conditions to skip,
    # returns false otherwise

    local    repo="${1:?}" is_verbose
    local -A tags

    zstyle -s ':zplug:core:load' 'verbose' is_verbose

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
        if ! eval "$tags[if]" 2> >(__zplug::log::capture::error) >/dev/null; then
            if (( $_zplug_boolean_true[(I)$is_verbose] )); then
                __zplug::io::print::die "$tags[name]: (not loaded)\n"
            fi
            return 0
        fi
    fi

    if [[ -n $tags[on] ]]; then
        __zplug::core::core::run_interfaces \
            'check' \
            ${~tags[on]}
        if (( $status != 0 )); then
            if (( $_zplug_boolean_true[(I)$is_verbose] )); then
                __zplug::io::print::die "$tags[name]: (not loaded)\n"
            fi
            return 0
        fi
    fi

    return 1
}
