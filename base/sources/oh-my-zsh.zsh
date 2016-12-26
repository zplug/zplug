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
        --repo "$repo"

    return $status
}

__zplug::sources::oh-my-zsh::get_url()
{
    __zplug::sources::github::get_url "$_ZPLUG_OHMYZSH"
}

__zplug::sources::oh-my-zsh::load_plugin()
{
    local    repo="${1:?}"
    local -A tags default_tags
    local -a \
        unclassified_plugins \
        load_fpaths \
        load_plugins \
        lazy_plugins \
        defer_1_plugins \
        defer_2_plugins \
        defer_3_plugins \
        load_themes
    local -a themes_ext

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
    load_themes=()
    themes_ext=("zsh-theme" "theme-zsh")

    case "$repo" in
        plugins/*)
            unclassified_plugins=(
                ${(@f)"$(__zplug::utils::omz::depends "$tags[name]")"}
            )
            # No USE tag specified
            if [[ $tags[use] == $default_tags[use] ]]; then
                unclassified_plugins+=( ${(@f)"$( \
                    __zplug::utils::shell::expand_glob "$tags[dir]/$tags[name]/*.plugin.zsh" "(N-.)"
                )"} )
            else
                unclassified_plugins+=( ${(@f)"$( \
                    __zplug::utils::shell::expand_glob "$tags[dir]/$tags[name]/$tags[use]" "(N-.)"
                )"} )
            fi
            ;;
        themes/*)
            unclassified_plugins=( ${(@f)"$(__zplug::utils::omz::depends "$tags[name]")"} )
            load_themes=(
                ${(@f)"$( \
                    __zplug::utils::shell::expand_glob "$tags[dir]/$tags[name].${^themes_ext}" "(N-.)"
                )"}
            )
            ;;
        lib/*)
            unclassified_plugins+=( ${(@f)"$( \
                __zplug::utils::shell::expand_glob "$tags[dir]/$tags[name].zsh" "(N-.)"
            )"} )
            ;;
    esac
    load_fpaths+=(
        "$tags[dir]/$tags[name]"/{_*,**/_*}(N-.:h)
    )

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
    [[ -n $load_themes ]] && reply+=( "load_themes" "${(F)load_themes}" )

    return 0
}

__zplug::sources::oh-my-zsh::load_theme()
{
    local    repo="$1"
    local -A tags default_tags
    local -a load_themes load_fpaths
    local -a themes_ext

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"
    themes_ext=("zsh-theme" "theme-zsh")
    load_fpaths=()
    load_themes=()

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
    [[ -n $load_themes ]] && reply+=( "load_themes" "${(F)load_themes}" )
    [[ -n $load_fpaths ]] && reply+=( "load_fpaths" "${(F)load_fpaths}" )
    [[ -n $tags[hook-load] ]] && reply+=( "hook_load" "$tags[name]\0$tags[hook-load]")

    return 0
}
