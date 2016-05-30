#!/usr/bin/env zsh

__import "support/omz"

__zplug::oh-my-zsh::check() {
    local    line
    local -A zspec

    line="$1"
    __parser__ "$line"
    zspec=( "${reply[@]}" )

    [[ -d ${zspec[dir]:h} ]]
}

__zplug::oh-my-zsh::install() {
    local    line
    local -A zspec

    line="$1"
    __parser__ "$line"
    zspec=( "${reply[@]}" )

    __clone__ \
        --use    ${zspec[use]:-""} \
        --from   "github" \
        --at     ${zspec[at]:-""} \
        --depth  ${zspec[depth]:-""} \
        "$_ZPLUG_OHMYZSH"

    return $status
}

__zplug::oh-my-zsh::load_plugin() {
    local    line
    local -A zspec

    line="$1"
    __parser__ "$line"
    zspec=( "${reply[@]}" )

    local -a load_fpaths
    local -a load_patterns
    local -a themes_ext

    load_fpaths=()
    load_patterns=()
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
        if [[ $zspec[name] =~ ^lib ]]; then
            __zplug::support::omz::theme
        fi
    fi

    case $zspec[name] in
        plugins/*)
            # TODO: use tag
            load_patterns=(
                ${(@f)"$(__zplug::support::omz::depends "$zspec[name]")"}
                "$zspec[dir]"/*.plugin.zsh(N-.)
            )
            ;;
        themes/*)
            # TODO: use tag
            load_patterns=(
                ${(@f)"$(__zplug::support::omz::depends "$zspec[name]")"}
                "$zspec[dir]".${^themes_ext}(N-.)
            )
            ;;
        lib/*)
            load_patterns=(
                "$zspec[dir]"${~zspec[use]}
            )
            ;;
    esac
    load_fpaths+=(
        ${zspec[dir]}/{_*,**/_*}(N-.:h)
    )

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_patterns ]] && reply+=( load_patterns "${(F)load_patterns}" )

    return 0
}
