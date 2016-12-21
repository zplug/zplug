__zplug::sources::prezto::check()
{
    local    repo="$1"
    local -A tags

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"

    [[ -n $tags[dir] ]] && [[ -d $tags[dir] ]]
    return $status
}

__zplug::sources::prezto::install()
{
    local repo="$1"

    # Already cloned
    if __zplug::sources::prezto::check "$repo"; then
        return 0
    fi

    __zplug::utils::git::clone \
        "$_ZPLUG_PREZTO"
    return $status
}

__zplug::sources::prezto::update()
{
    local    repo="$1"
    local -A tags

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"
    tags[at]="$(
    __zplug::core::core::run_interfaces \
        'at' \
        "$repo"
    )"

    __zplug::utils::git::merge \
        --dir    "$tags[dir]" \
        --branch "$tags[at]" \
        --repo   "$repo"

    return $status
}

__zplug::sources::prezto::get_url()
{
    __zplug::sources::github::get_url "$_ZPLUG_PREZTO"
}

__zplug::sources::prezto::load_plugin()
{
    local    repo="${1:?}"
    local -A tags
    local -A default_tags
    local    module_name
    local    dependency
    local -a \
        unclassified_plugins \
        load_fpaths \
        load_plugins \
        lazy_plugins \
        defer_1_plugins \
        defer_2_plugins \
        defer_3_plugins

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )
    default_tags[use]="$(__zplug::core::core::run_interfaces 'use')"
    unclassified_plugins=()
    load_fpaths=()
    load_plugins=()
    lazy_plugins=()
    defer_1_plugins=()
    defer_2_plugins=()
    defer_3_plugins=()

    if [[ ! -d $tags[dir] ]]; then
        zstyle ":prezto:module:$module_name" loaded "no"
        return 1
    fi

    if (( ! $+functions[pmodload] )) {
        pmodload() {
            # Do nothing
        }
    }

    # module/command-not-found -> command-not-found
    module_name="${tags[name]#*/}"

    for dependency in ${(@f)"$(__zplug::utils::prezto::depends "$module_name")"}
    do
        unclassified_plugins+=( "$tags[dir]/modules/$dependency"/init.zsh(N-.) )
    done

    # modules/prompt's init.zsh must be sourced AFTER fpath is added (i.e.
    # after compinit in __load__)
    if [[ $tags[name] == modules/prompt ]]; then
        defer_2_plugins+=( "$tags[dir]/$tags[name]"/init.zsh(N-.) )
    else
        # Default modules
        if [[ $tags[use] != $default_tags[use] ]]; then
            unclassified_plugins+=( "$tags[dir]"/${~tags[use]}(N-.) )
        elif [[ -f $tags[dir]/$tags[name]/init.zsh ]]; then
            unclassified_plugins+=( "$tags[dir]/$tags[name]"/init.zsh(N-.) )
        fi
    fi

    # Add functions directory to FPATH if it exists
    if [[ -d $tags[dir]/$tags[name]/functions ]]; then
        load_fpaths+=( "$tags[dir]/$tags[name]"/functions(N-/) )

        # autoload functions
        # Taken from prezto's init.zsh
        function {
            setopt local_options extended_glob

            local pfunction_glob='^([_.]*|prompt_*_setup|README*)(-.N:t)'
            lazy_plugins=( "$tags[dir]/$tags[name]/functions"/${~pfunction_glob} )
        }
    fi

    zstyle ":prezto:module:$module_name" loaded "yes"

    if [[ $TERM == dumb ]]; then
        zstyle ":prezto:*:*" color "no"
        zstyle ":prezto:module:prompt" theme "off"
    fi

    # unclassified_plugins -> {defer_N_plugins,lazy_plugins,load_plugins}
    # the order of loading of plugin files
    case "$tags[defer]" in
        0)
            if (( $_zplug_boolean_true[(I)$tags[lazy]] )); then
                lazy_plugins+=( "${unclassified_plugins[@]}" )
            else
                load_plugins+=( "${unclassified_plugins[@]}" )
            fi
            ;;
        1)
            defer_1_plugins+=( "${unclassified_plugins[@]}" )
            ;;
        2)
            defer_2_plugins+=( "${unclassified_plugins[@]}" )
            ;;
        3)
            defer_3_plugins+=( "${unclassified_plugins[@]}" )
            ;;
        *)
            : # Error
            ;;
    esac
    unclassified_plugins=()

    if [[ -n $tags[ignore] ]]; then
        ignore_patterns=( $(
        zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo ${tags[dir]}/${~tags[ignore]}" \
            2> >(__zplug::log::capture::error)
        )(N) )
        for ignore in "${ignore_patterns[@]}"
        do
            # Commands
            if [[ -n $load_commands[(i)$ignore] ]]; then
                unset "load_commands[$ignore]"
            fi
            # Plugins
            load_plugins=( "${(R)load_plugins[@]:#$ignore}" )
            defer_1_plugins=( "${(R)defer_1_plugins[@]:#$ignore}" )
            defer_2_plugins=( "${(R)defer_2_plugins[@]:#$ignore}" )
            defer_3_plugins=( "${(R)defer_3_plugins[@]:#$ignore}" )
            lazy_plugins=( "${(R)lazy_plugins[@]:#$ignore}" )
            # fpath
            load_fpaths=( "${(R)load_fpaths[@]:#$ignore}" )
        done
    fi

    reply=()
    [[ -n $load_fpaths ]] && reply+=( "load_fpaths" "${(F)load_fpaths}" )
    [[ -n $load_plugins ]] && reply+=( "load_plugins" "${(F)load_plugins}" )
    [[ -n $lazy_plugins ]] && reply+=( "lazy_plugins" "${(F)lazy_plugins}" )
    [[ -n $defer_1_plugins ]] && reply+=( "defer_1_plugins" "${(F)defer_1_plugins}" )
    [[ -n $defer_2_plugins ]] && reply+=( "defer_2_plugins" "${(F)defer_2_plugins}" )
    [[ -n $defer_3_plugins ]] && reply+=( "defer_3_plugins" "${(F)defer_3_plugins}" )
    [[ -n $tags[hook-load] ]] && reply+=( "hook_load" "$tags[name]\0$tags[hook-load]")

    return 0
}
