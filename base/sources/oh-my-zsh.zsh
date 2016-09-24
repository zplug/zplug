__zplug::sources::oh-my-zsh::check()
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

__zplug::sources::oh-my-zsh::install()
{
    local repo="$1"

    # Already cloned
    if __zplug::sources::oh-my-zsh::check "$repo"; then
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
    )}"
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
    local -a unclassified_plugins
    local -a themes_ext

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    load_fpaths=()
    unclassified_plugins=()
    # Themes' extensions for Oh-My-Zsh
    themes_ext=("zsh-theme" "theme-zsh")

    # Check if omz is loaded and set some necessary settings
    if [[ -z $ZSH ]]; then
        export ZSH="$ZPLUG_REPOS/$_ZPLUG_OHMYZSH"
        export ZSH_CACHE_DIR="$ZSH/cache/"
        # Insert to the top of unclassified_plugins
        # unclassified_plugins=(
        #     "$ZSH/oh-my-zsh.sh"
        #     "${unclassified_plugins[@]}"
        # )
    fi

    if [[ $tags[name] =~ ^themes ]]; then
        __zplug::utils::omz::theme
    fi

    case $tags[name] in
        plugins/*)
            # TODO: use tag
            unclassified_plugins=(
                ${(@f)"$(__zplug::utils::omz::depends "$tags[name]")"}
            )
            # No USE tag specified
            if [[ $tags[use] == '*.zsh' ]]; then
                unclassified_plugins+=(
                    "$tags[dir]/${tags[name]}/"*.plugin.zsh(N-.)
                )
            else
                unclassified_plugins+=(
                    "$tags[dir]/${tags[name]}/"${~tags[use]}(N-.)
                )
            fi
            ;;
        themes/*)
            # TODO: use tag
            unclassified_plugins=(
                ${(@f)"$(__zplug::utils::omz::depends "$tags[name]")"}
                "$tags[dir]/${tags[name]}."${^themes_ext}(N-.)
            )
            ;;
        lib/*)
            unclassified_plugins=(
                "$tags[dir]"${~tags[use]}
            )
            ;;
    esac
    load_fpaths+=(
        ${tags[dir]}/${tags[name]}/{_*,**/_*}(N-.:h)
    )

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $unclassified_plugins ]] && reply+=( unclassified_plugins "${(F)unclassified_plugins}" )

    return 0
}
