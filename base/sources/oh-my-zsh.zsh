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
        --branch "$tags[at]" \
        --repo "$repo"

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
    local -A default_tags
    local -a load_fpaths
    local -a unclassified_plugins

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

    # Check if omz is loaded and set some necessary settings
    if [[ -z $ZSH ]]; then
        export ZSH="$ZPLUG_REPOS/$_ZPLUG_OHMYZSH"
        export ZSH_CACHE_DIR="$ZSH/cache/"
    fi

    case $tags[name] in
        plugins/*)
            unclassified_plugins=(
                ${(@f)"$(__zplug::utils::omz::depends "$tags[name]")"}
            )
            # No USE tag specified
            if [[ $tags[use] == $default_tags[use] ]]; then
                unclassified_plugins+=( ${(@f)"$( \
                    __zplug::utils::shell::expand_glob "$tags[dir]/${tags[name]}/*.plugin.zsh" "(N-.)"
                )"} )
            else
                unclassified_plugins+=( ${(@f)"$( \
                    __zplug::utils::shell::expand_glob "$tags[dir]/${tags[name]}/${tags[use]}" "(N-.)"
                )"} )
            fi
            ;;
        themes/*)
            unclassified_plugins=(
                ${(@f)"$(__zplug::utils::omz::depends "$tags[name]")"}
                ${(@f)"$( \
                    __zplug::utils::shell::expand_glob "$tags[dir]/${tags[name]}.${^themes_ext}" "(N-.)"
                )"}
            )
            ;;
        lib/*)
            unclassified_plugins+=( ${(@f)"$( \
                __zplug::utils::shell::expand_glob "$tags[dir]/${tags[name]}.zsh" "(N-.)"
            )"} )
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

__zplug::sources::oh-my-zsh::load_theme()
{
    local    repo="$1"
    local -A tags
    local -A default_tags
    local -a load_themes
    local -a themes_ext

    themes_ext=("zsh-theme" "theme-zsh")

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::core::tags::parse "$repo"
    tags[dir]="${$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )}"

    # Check if omz is loaded and set some necessary settings
    if [[ -z $ZSH ]]; then
        export ZSH="$ZPLUG_REPOS/$_ZPLUG_OHMYZSH"
        export ZSH_CACHE_DIR="$ZSH/cache/"
    fi

    case "$repo" in
        themes/*)
            load_themes=(
                ${(@f)"$(__zplug::utils::omz::depends "$repo")"}
                ${(@f)"$( \
                    __zplug::utils::shell::expand_glob "$tags[dir]/${repo}.${^themes_ext}" "(N-.)"
                )"}
            )
            ;;
    esac

    reply=()
    [[ -n $load_themes ]] && reply+=( load_themes "${(F)load_themes}" )

    return 0
}
