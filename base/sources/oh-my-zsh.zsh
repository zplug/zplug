#!/bin/zsh

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

    local -a load_plugins load_fpaths lazy_plugins
    local -a load_patterns
    local -a themes_ext plugins_ext
    # TODO: auxilary return value
    local loaded_omz
    loaded_omz=false

    load_patterns=()
    # Themes' extensions for Oh-My-Zsh
    themes_ext=("zsh-theme" "theme-zsh")

    # Check if omz is loaded and set some necessary settings
    load_omz() {
        if ! $loaded_omz; then
            loaded_omz=true
            export ZSH="$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH"
            # Insert to the top of load_plugins
            # load_plugins=(
            #     "$ZSH/oh-my-zsh.sh"
            #     "${load_plugins[@]}"
            # )
            if [[ $zspec[name] =~ ^lib ]]; then
                __zplug::support::omz::theme
            fi
        fi
    }

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

    if (( $#load_patterns > 0 )); then
        # nice plugin or not
        if (( $zspec[nice] > 9 )); then
            nice_plugins+=( "${load_patterns[@]}" )
        else
            load_plugins+=( "${load_patterns[@]}" )
        fi
        load_omz
    fi
    # Remove these function from current shell process
    unfunction load_omz

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_patterns ]] && reply+=( load_patterns "${(F)load_patterns}" )
    [[ -n $load_plugins ]] && reply+=( load_plugins "${(F)load_plugins}" )
    [[ -n $nice_plugins ]] && reply+=( nice_plugins "${(F)nice_plugins}" )
    [[ -n $themes_ext ]] && reply+=( themes_ext "${(F)themes_ext}" )
    [[ -n $plugins_ext ]] && reply+=( plugins_ext "${(F)plugins_ext}" )

    return 0
}
