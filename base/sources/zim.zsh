__zplug::sources::zim::check()
{
    __zplug::sources::prezto::check "$argv[@]"
}

__zplug::sources::zim::install()
{
    local repo="$1"

    # Already cloned
    if __zplug::sources::zim::check "$repo"; then
        return 0
    fi

    __zplug::utils::git::clone \
        "$_ZPLUG_ZIM"
    return $status
}

__zplug::sources::zim::update()
{
    __zplug::sources::prezto::update "$argv[@]"
}

__zplug::sources::zim::get_url()
{
    __zplug::sources::github::get_url "$_ZPLUG_ZIM"
}

__zplug::sources::zim::load_plugin()
{
    local    repo="$1"
    local -A tags
    local -A default_tags
    local -a load_fpaths
    local -a unclassified_plugins
    local -a lazy_plugins
    local -a nice_plugins
    local    module_name

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )
    default_tags[use]="$(__zplug::core::core::run_interfaces 'use')"

    load_fpaths=()
    unclassified_plugins=()
    lazy_plugins=()
    nice_plugins=()

    module_name="${tags[name]#*/}"

    if [[ $tags[use] != $default_tags[use] ]]; then
        unclassified_plugins+=( "$tags[dir]/"${~tags[use]}(N-.) )
    elif [[ -f $tags[dir]/$tags[name]/init.zsh ]]; then
        unclassified_plugins+=( "$tags[dir]/$tags[name]/"init.zsh(N-.) )
    fi

    # modules/prompt's init.zsh must be sourced AFTER fpath is added (i.e.
    # after compinit in __load__)
    if [[ $module_name == prompt ]]; then
        nice_plugins=( $unclassified_plugins[@] )
        unclassified_plugins=()
    fi

    # Add functions directory to FPATH if it exists
    if [[ -d $tags[dir]/$tags[name]/functions ]]; then
        load_fpaths+=( "$tags[dir]/$tags[name]"/functions(N-/) )

        # autoload functions
        # Taken from zim's init.zsh
        function {
            setopt local_options extended_glob

            local function_glob='^([_.]*|prompt_*_setup|README*)(-.N:t)'
            lazy_plugins=( "$tags[dir]/$tags[name]/functions/"${~function_glob} )
        }
    fi

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $unclassified_plugins ]] && reply+=( unclassified_plugins "${(F)unclassified_plugins}" )
    [[ -n $nice_plugins ]] && reply+=( nice_plugins "${(F)nice_plugins}" )
    [[ -n $lazy_plugins ]] && reply+=( lazy_plugins "${(F)lazy_plugins}" )

    return 0
}
