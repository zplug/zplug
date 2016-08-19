__zplug::sources::oh-my-zsh::check()
{
    local    repo="$1"
    local -A tags

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"

    [[ -d $tags[dir]:h ]]
    return $status
}

__zplug::sources::oh-my-zsh::install()
{
    # Already cloned
    if [[ -d $_ZPLUG_OHMYZSH ]]; then
        return 0
    fi

    __zplug::utils::git::clone \
        "$_ZPLUG_OHMYZSH"
    return $status
}

__zplug::sources::oh-my-zsh::update()
{
    local    repo="$1"
    local -A tags

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    tags[dir]="${$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    ):F[2]h}"
    tags[at]="$(
    __zplug::core::core::run_interfaces \
        'at' \
        "$repo"
    )"

    __zplug::utils::git::merge \
        --dir    "$tags[dir]" \
        --branch "$tags[at]"

    return $status
}

__zplug::sources::oh-my-zsh::get_url()
{
    __zplug::sources::github::get_url "$_ZPLUG_OHMYZSH"
}

__zplug::sources::oh-my-zsh::load_plugin()
{
    local    repo="$1"
    local -A tags
    local -a load_fpaths
    local -a load_plugins
    local -a themes_ext

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    load_fpaths=()
    load_plugins=()
    # Themes' extensions for Oh-My-Zsh
    themes_ext=("zsh-theme" "theme-zsh")

    # Check if omz is loaded and set some necessary settings
    if [[ -z $ZSH ]]; then
        export ZSH="$ZPLUG_REPOS/$_ZPLUG_OHMYZSH"
        export ZSH_CACHE_DIR="$ZSH/cache/"
        # Insert to the top of load_plugins
        # load_plugins=(
        #     "$ZSH/oh-my-zsh.sh"
        #     "${load_plugins[@]}"
        # )
        if [[ $tags[name] =~ ^lib ]]; then
            __zplug::utils::omz::theme
        fi
    fi

    case $tags[name] in
        plugins/*)
            # TODO: use tag
            load_plugins=(
                ${(@f)"$(__zplug::utils::omz::depends "$tags[name]")"}
                "$tags[dir]"/*.plugin.zsh(N-.)
            )
            ;;
        themes/*)
            # TODO: use tag
            load_plugins=(
                ${(@f)"$(__zplug::utils::omz::depends "$tags[name]")"}
                "$tags[dir]".${^themes_ext}(N-.)
            )
            ;;
        lib/*)
            load_plugins=(
                "$tags[dir]"${~tags[use]}
            )
            ;;
    esac
    load_fpaths+=(
        ${tags[dir]}/{_*,**/_*}(N-.:h)
    )

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_plugins ]] && reply+=( load_plugins "${(F)load_plugins}" )

    return 0
}
