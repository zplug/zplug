__zplug::core::cache::set_file()
{
    local file="${1:?}"

    if (( ! $+_zplug_cache[$file] )); then
        return 1
    fi

    # Keep compatible with version 2.3.3 or lower
    __zplug::core::migration::cache_file_dir

    rm -f "$_zplug_cache[$file]"
    touch "$_zplug_cache[$file]"
}

__zplug::core::cache::expose()
{
    if [[ -f $_zplug_cache[interface] ]]; then
        cat "$_zplug_cache[interface]"
    fi
}

__zplug::core::cache::update()
{
    __zplug::core::interface::expose \
        >|"$_zplug_cache[interface]"
}

__zplug::core::cache::commit()
{
    local     pkg pair hook
    local -A  hook_load
    local -A  reply_hash
    local -A  load_commands
    local -aU load_plugins load_fpaths lazy_plugins \
        defer_1_plugins \
        defer_2_plugins \
        defer_3_plugins
    local -aU unclassified_plugins
    local     repo param params

    reply_hash=( "$argv[@]" )
    lazy_plugins=( ${(@f)reply_hash[lazy_plugins]} )
    load_fpaths=( ${(@f)reply_hash[load_fpaths]} )
    load_plugins=( ${(@f)reply_hash[load_plugins]} )
    load_themes=( ${(@f)reply_hash[load_themes]} )
    defer_1_plugins=( ${(@f)reply_hash[defer_1_plugins]} )
    defer_2_plugins=( ${(@f)reply_hash[defer_2_plugins]} )
    defer_3_plugins=( ${(@f)reply_hash[defer_3_plugins]} )
    unclassified_plugins=( ${(@f)reply_hash[unclassified_plugins]} )
    for pair (${(@f)reply_hash[load_commands]}) load_commands+=( ${(@s:\0:)pair} )
    for pair in ${reply_hash[hook_load]}
    do
        hook="${${(@s:\0:)pair}[2,-1]}"
    done
    repo="$reply_hash[repo]"

    # Common parameter
    param="--repo ${(qqq)repo}"
    if [[ -n $hook ]]; then
        param+=" --hook ${(qqq)hook}"
    fi

    # Record packages to cache file
    for pkg in "$load_plugins[@]"
    do
        params="$param ${(qqq)pkg}"
        __zplug::job::handle::flock "$_zplug_cache[plugin]" "__zplug::core::load::as_plugin $params"
    done
    for pkg in "$defer_1_plugins[@]"
    do
        params="$param ${(qqq)pkg}"
        __zplug::job::handle::flock "$_zplug_cache[defer_1_plugin]" "__zplug::core::load::as_plugin $params"
    done
    for pkg in "$defer_2_plugins[@]"
    do
        params="$param ${(qqq)pkg}"
        __zplug::job::handle::flock "$_zplug_cache[defer_2_plugin]" "__zplug::core::load::as_plugin $params"
    done
    for pkg in "$defer_3_plugins[@]"
    do
        params="$param ${(qqq)pkg}"
        __zplug::job::handle::flock "$_zplug_cache[defer_3_plugin]" "__zplug::core::load::as_plugin $params"
    done
    for pkg in "$lazy_plugins[@]"
    do
        params="$param ${(qqq)pkg} --lazy"
        __zplug::job::handle::flock "$_zplug_cache[lazy_plugin]" "__zplug::core::load::as_plugin $params"
    done
    for pkg in "$load_fpaths[@]"
    do
        __zplug::job::handle::flock "$_zplug_cache[fpath]" "$pkg"
    done
    for pkg in "${(k)load_commands[@]}"
    do
        params="$param --path ${(qqq)load_commands[$pkg]} ${(qqq)pkg}"
        __zplug::job::handle::flock "$_zplug_cache[command]" "__zplug::core::load::as_command $params"
    done
    for pkg in "$load_themes[@]"
    do
        params="$param ${(qqq)pkg}"
        __zplug::job::handle::flock "$_zplug_cache[theme]" "__zplug::core::load::as_theme $params"
    done
}

__zplug::core::cache::diff()
{
    local key file
    local is_verbose
    zstyle -s ':zplug:core:load' 'verbose' is_verbose

    $ZPLUG_USE_CACHE || return 2

    if [[ -d $ZPLUG_CACHE_DIR ]]; then
        2> >(__zplug::log::capture::error) >/dev/null \
            diff -b \
            <(__zplug::core::cache::expose) \
            <(__zplug::core::interface::expose)

        case $status in
            0)
                # same
                if (( $_zplug_boolean_true[(I)$is_verbose] )); then
                    __zplug::io::print::f --zplug "Loaded from cache ($ZPLUG_CACHE_DIR)\n"
                fi
                return 0
                ;;
            1)
                # differ
                ;;
            2)
                # error
                ;;
        esac
    fi

    for file in "${(k)_zplug_cache[@]}"
    do
        __zplug::core::cache::set_file "$file"
    done

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

        __zplug::core::cache::commit repo "$repo" "$reply[@]"
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

        __zplug::core::cache::commit repo "$repo" "$reply[@]"
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

        __zplug::core::cache::commit repo "$repo" "$reply[@]"
    fi

    setopt prompt_subst
}
