__zplug::core::cache::expose()
{
    if [[ -f $ZPLUG_HOME/.cache/cache ]]; then
        cat "$ZPLUG_HOME/.cache/cache"
    fi
}

__zplug::core::cache::update()
{
    __zplug::core::interface::expose \
        >|"$ZPLUG_HOME/.cache/cache"
}

__zplug::core::cache::commit()
{
    local     pkg hook pair
    local -A  hook_load
    local -A  reply_hash
    local -A  load_commands
    local -aU load_plugins load_fpaths lazy_plugins nice_plugins
    local -aU unclassified_plugins

    reply_hash=( "$argv[@]" )
    lazy_plugins=( ${(@f)reply_hash[lazy_plugins]} )
    load_fpaths=( ${(@f)reply_hash[load_fpaths]} )
    load_plugins=( ${(@f)reply_hash[load_plugins]} )
    load_themes=( ${(@f)reply_hash[load_themes]} "$unclassified_plugins[@]" )
    nice_plugins=( ${(@f)reply_hash[nice_plugins]} )
    unclassified_plugins=( ${(@f)reply_hash[unclassified_plugins]} )
    for pair in ${(@f)reply_hash[load_commands]}
    do
        load_commands+=( ${(@s:\0:)pair} ) # Each line (pair) is null character-separated
    done
    for pair in ${(@f)reply_hash[hook_load]}
    do
        hook_load+=( ${(@s:\0:)pair} ) # Each line (pair) is null character-separated
    done

    # Record packages to cache file
    if (( $#load_plugins > 0 )); then
        for pkg in "$load_plugins[@]"
        do
            __zplug::job::state::flock "$_zplug_cache[plugin]" "source ${(qqq)pkg}"
        done
    fi
    if (( $#nice_plugins > 0 )); then
        for pkg in "$nice_plugins[@]"
        do
            __zplug::job::state::flock "$_zplug_cache[before_plugin]" "source ${(qqq)pkg}"
            __zplug::job::state::flock "$_zplug_cache[after_plugin]" "source ${(qqq)pkg}"
        done
    fi
    if (( $#lazy_plugins > 0 )); then
        for pkg in "$lazy_plugin[@]"
        do
            __zplug::job::state::flock "$_zplug_cache[lazy_plugin]" "source ${(qqq)pkg}"
        done
    fi
    if (( $#load_fpaths > 0 )); then
        for pkg in "$load_fpaths[@]"
        do
            __zplug::job::state::flock "$_zplug_cache[fpath]" "fpath+=(${(qqq)pkg})"
        done
    fi
    if (( $#hook_load > 0 )); then
        for hook in "${(k)hook_load[@]}"
        do
            __zplug::job::state::flock "$_zplug_cache[hook-load]" "$hook_load[$hook]"
        done
    fi
    if (( $#load_commands > 0 )); then
        for pkg in "${(k)load_commands[@]}"
        do
            __zplug::job::state::flock "$_zplug_cache[command]" "chmod 755 ${(qqq)pkg}"
            __zplug::job::state::flock "$_zplug_cache[command]" "ln -snf ${(qqq)pkg} ${(qqq)load_commands[$pkg]}"
        done
    fi
    if (( $#load_themes > 0 )); then
        for pkg in "$load_themes[@]"
        do
            __zplug::job::state::flock "$_zplug_cache[theme]" "source ${(qqq)pkg}"
        done
    fi
}

__zplug::core::cache::load_if_available()
{
    local key

    $ZPLUG_USE_CACHE || return 2

    if [[ -e $ZPLUG_CACHE_FILE ]]; then
        2> >(__zplug::io::log::capture) >/dev/null \
            diff -b \
            <(__zplug::core::cache::expose) \
            <(__zplug::core::interface::expose)

        case $status in
            0)
                # same
                __zplug::core::load::from_cache
                return $status
                ;;
            1)
                # differ
                ;;
            2)
                # error
                ;;
        esac
    fi

    # if cache file doesn't find,
    # returns non-zero exit code
    return 1
}

__zplug::core::cache::plugins()
{
    local repo="${1:?}"
    local -A tags

    __zplug::core::load::skip_condition "$repo" && return 0

    tags[from]="$(__zplug::core::core::run_interfaces "from" "$repo")"

    # Switch to the revision specified by its tags
    __zplug::utils::git::checkout "$repo"

    if __zplug::core::sources::is_handler_defined "load_plugin" "$tags[from]"; then
        # Custom handler for loading
        __zplug::core::sources::use_handler \
            "load_plugin" \
            "$tags[from]" \
            "$repo"

        __zplug::core::cache::commit "$reply[@]"
    fi
}

__zplug::core::cache::commands()
{
    local repo="${1:?}"
    local -A tags

    __zplug::core::load::skip_condition "$repo" && return 0

    tags[from]="$(__zplug::core::core::run_interfaces "from" "$repo")"

    # Switch to the revision specified by its tags
    __zplug::utils::git::checkout "$repo"

    if __zplug::core::sources::is_handler_defined "load_command" "$tags[from]"; then
        __zplug::core::sources::use_handler \
            "load_command" \
            "$tags[from]" \
            "$repo"

        __zplug::core::cache::commit "$reply[@]"
    fi
}

__zplug::core::cache::themes()
{
    local repo="${1:?}"
    local -A tags

    __zplug::core::load::skip_condition "$repo" && return 0

    tags[from]="$(__zplug::core::core::run_interfaces "from" "$repo")"

    # Switch to the revision specified by its tags
    __zplug::utils::git::checkout "$repo"

    if __zplug::core::sources::is_handler_defined "load_theme" "$tags[from]"; then
        # Custom handler for loading
        __zplug::core::sources::use_handler \
            "load_theme" \
            "$tags[from]" \
            "$repo"

        __zplug::core::cache::commit "$reply[@]"
    fi

    setopt prompt_subst
}
