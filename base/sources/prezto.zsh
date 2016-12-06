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

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

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
    local -a load_fpaths
    local -a unclassified_plugins
    local -a lazy_plugins
    local -a defer_1_plugins defer_2_plugins defer_3_plugins
    local    module_name
    local    dependency

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )
    default_tags[use]="$(__zplug::core::core::run_interfaces 'use')"

    load_fpaths=()
    unclassified_plugins=()
    lazy_plugins=()
    defer_1_plugins=()
    defer_2_plugins=()
    defer_3_plugins=()

    module_name="${tags[name]#*/}"

    if [[ ! -d $tags[dir] ]]; then
        zstyle ":prezto:module:$module_name" loaded "no"
        return 1
    fi

    if (( ! $+functions[pmodload] )) {
        pmodload() {
            # Do nothing
        }
    }

    for dependency in ${(@f)"$( __zplug::utils::prezto::depends "$module_name" )"}
    do
        unclassified_plugins+=( "$tags[dir]/modules/$dependency"/init.zsh(N-.) )
    done

    if [[ $tags[use] != $default_tags[use] ]]; then
        unclassified_plugins+=( "$tags[dir]"/${~tags[use]}(N-.) )
    elif [[ -f $tags[dir]/$tags[name]/init.zsh ]]; then
        unclassified_plugins+=( "$tags[dir]/$tags[name]"/init.zsh(N-.) )
    fi

    # modules/prompt's init.zsh must be sourced AFTER fpath is added (i.e.
    # after compinit in __load__)
    if [[ $tags[name] == modules/prompt ]]; then
        defer_1_plugins=( $unclassified_plugins[@] )
        unclassified_plugins=()
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

    reply=()
    #[[ -n $unclassified_plugins ]] && reply+=( "unclassified_plugins" "${(F)unclassified_plugins}" )
    [[ -n $load_fpaths ]] && reply+=( "load_fpaths" "${(F)load_fpaths}" )
    [[ -n $load_plugins ]] && reply+=( "load_plugins" "${(F)unclassified_plugins}" ) # TODO
    [[ -n $lazy_plugins ]] && reply+=( "lazy_plugins" "${(F)lazy_plugins}" )
    [[ -n $defer_1_plugins ]] && reply+=( "defer_1_plugins" "${(F)defer_1_plugins}" )
    [[ -n $defer_2_plugins ]] && reply+=( "defer_2_plugins" "${(F)defer_2_plugins}" )
    [[ -n $defer_3_plugins ]] && reply+=( "defer_3_plugins" "${(F)defer_3_plugins}" )
    [[ -n $tags[hook-load] ]] && reply+=( "hook_load" "$tags[name]\0$tags[hook-load]")

    return 0
}
