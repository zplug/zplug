__zplug::sources::github::check()
{
    local    repo="$1"
    local -A tags

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"

    [[ -d $tags[dir] ]]
    return $status
}

__zplug::sources::github::install()
{
    local repo="$1"

    __zplug::utils::git::clone "$repo"
    return $status
}

__zplug::sources::github::update()
{
    local    repo="$1"
    local    rev_local rev_remote rev_base
    local -A tags

    tags[dir]="$(__zplug::core::core::run_interfaces 'dir' "$repo")"
    tags[at]="$(__zplug::core::core::run_interfaces 'at' "$repo")"

    __zplug::utils::git::merge \
        --dir    "$tags[dir]" \
        --branch "$tags[at]" \
        --repo "$repo"

    return $status
}

__zplug::sources::github::get_url()
{
    local repo="$1" url_format

    case "$ZPLUG_PROTOCOL" in
        HTTPS | https)
            # Create the format of URL used to git clone
            # When vim-plug clones a repository, it injects git::@ into the URL
            # It's a little hack to avoid username/password prompt
            # from git when the repository doesn't exist.
            # Such thing can happen when there's a typo in the argument,
            # or when the repository is removed from GitHub
            # For more information, see also vim-plug wiki.
            # https://git::@github.com/%s.git
            url_format="https://git::@github.com/${repo}.git"

            # However, Git 2.3.0 introduced $GIT_TERMINAL_PROMPT
            # which can be used to suppress user prompt
            if __zplug::base::base::git_version 2.3; then
                # (git 2.3+) https://github.com/%s.git
                export GIT_TERMINAL_PROMPT=0
                url_format="https://github.com/${repo}.git"
            fi
            ;;
        SSH | ssh)
            # git@github.com:%s.git
            url_format="git@github.com:${repo}.git"
            ;;
    esac

    echo "$url_format"
}

__zplug::sources::github::load_plugin()
{
    local    repo="${1:?}"
    local -A tags default_tags
    local -a \
        unclassified_plugins \
        load_fpaths \
        defer_1_plugins \
        defer_2_plugins \
        defer_3_plugins \
        load_plugins \
        lazy_plugins

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )
    default_tags[use]="$(__zplug::core::core::run_interfaces 'use')"
    load_fpaths=()

    # If that is an autoload plugin
    if (( $_zplug_boolean_true[(I)$tags[lazy]] )); then
        if [[ $tags[use] == $default_tags[use] ]]; then
            unclassified_plugins+=( \
                "$tags[dir]"/${repo:t}(N.) \
                "$tags[dir]/autoload"/*(N.) \
                "$tags[dir]/functions"/*(N.) \
                )
            load_fpaths+=( \
                "$tags[dir]"(N/) \
                "$tags[dir]/autoload"(N/) \
                "$tags[dir]/functions"(N/) \
                )
        else
            unclassified_plugins+=( ${(@f)"$( \
                __zplug::utils::shell::expand_glob "$tags[dir]/$tags[use]" "(N-.)"
            )"} )
            load_fpaths+=( $unclassified_plugins:h(N/) )
        fi
    else
        if [[ $tags[use] == $default_tags[use] ]]; then
            unclassified_plugins+=( "$tags[dir]"/*.plugin.zsh(N-.) )
        fi
        if (( $#unclassified_plugins == 0 )); then
            unclassified_plugins+=( ${(@f)"$( \
                __zplug::utils::shell::expand_glob "$tags[dir]/$tags[use]" "(N-.)"
            )"} )
            # If $tags[use] is a directory,
            # expect to expand to $tags[dir]/*.zsh
            if (( $#unclassified_plugins == 0 )); then
                unclassified_plugins+=( ${(@f)"$( \
                    __zplug::utils::shell::expand_glob "$tags[dir]/$tags[use]/$default_tags[use]" "(N-.)"
                )"} )
                # Add the parent directory to fpath
                load_fpaths+=( "$tags[dir]/$tags[use]"/_*(N.:h) )
            fi
        fi
        load_fpaths+=( "$tags[dir]"/_*(N.:h) )
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
    [[ -n $load_plugins ]] && reply+=( "load_plugins" "${(F)load_plugins}" )
    [[ -n $defer_1_plugins ]] && reply+=( "defer_1_plugins" "${(F)defer_1_plugins}" )
    [[ -n $defer_2_plugins ]] && reply+=( "defer_2_plugins" "${(F)defer_2_plugins}" )
    [[ -n $defer_3_plugins ]] && reply+=( "defer_3_plugins" "${(F)defer_3_plugins}" )
    [[ -n $lazy_plugins ]] && reply+=( "lazy_plugins" "${(F)lazy_plugins}" )
    [[ -n $load_fpaths ]] && reply+=( "load_fpaths" "${(F)load_fpaths}" )
    [[ -n $tags[hook-load] ]] && reply+=( "hook_load" "$tags[name]\0$tags[hook-load]")
}

__zplug::sources::github::load_command()
{
    local    repo="${1:?}"
    local -A tags default_tags
    local    src dst
    local -a sources
    local -a load_fpaths load_commands
    local -A rename_hash

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )
    default_tags[use]="$(__zplug::core::core::run_interfaces 'use')"
    tags[dir]="${tags[dir]%/}"
    load_commands=()
    load_fpaths=()

    # Append dst to each element so that load_commands becomes:
    #
    # load_commands=(
    #   path/to/cmd1\0dst
    #   path/to/cmd2\0dst
    #   ...
    # )
    #
    # where \0 is a null character used to separate the two strings.
    #
    # In the caller function (__load__), each line is decomposed into an
    # element in an associative array, thus, in the example above, the line:
    #
    #   path/to/cmd1\0dst
    #
    # becomes an element where the key is "path/to/cmd" and the value is
    # "dst".
    if [[ $tags[use] == *(*)* && $tags[rename-to] == *\$* ]]; then
        # If it's captured by `use` tag and referenced by `rename-to` tag,
        # it's expanded with `__zplug::utils::shell::zglob`
        if (( $#rename_hash == 0 )) && [[ -n $tags[rename-to] ]]; then
            rename_hash=( $(__zplug::utils::shell::zglob \
                "$tags[dir]/$tags[use]" \
                "$ZPLUG_BIN/$tags[rename-to]")
            )
        fi
    else
        if [[ $tags[use] == $default_tags[use] ]]; then
            # If no $tags[use] is given by the user,
            # automatically add repo's basename to load-path
            # if it exists as executable file
            if [[ -f $tags[dir]/${repo:t} ]]; then
                sources=( "$tags[dir]/${repo:t}"(N-.) )
            fi
        else
            if [[ $tags[use] == $default_tags[use] || $tags[from] == "gh-r" ]]; then
                tags[use]="*(N-*)"
            fi
            sources=( ${(@f)"$( \
                __zplug::utils::shell::expand_glob "$tags[dir]/$tags[use]" "(N-.)"
            )"} )
        fi
        dst=${${tags[rename-to]:+$ZPLUG_BIN/$tags[rename-to]}:-"$ZPLUG_BIN"}
        for src in "$sources[@]"
        do
            chmod 755 "$src"
            rename_hash+=("$src" "$dst")
        done
    fi
    for src in "${(k)rename_hash[@]}"
    do
        load_commands+=("$src\0$rename_hash[$src]")
    done
    if (( $#rename_hash == 0 )); then
        __zplug::log::write::info \
            "$repo: no matches found, rename_hash is empty"
    fi

    # Add parent directories to fpath if any files starting in _* exist
    load_fpaths+=("$tags[dir]"/{_*,/**/_*}(N-.:h))

    reply=()
    [[ -n $load_fpaths ]] && reply+=( "load_fpaths" "${(F)load_fpaths}" )
    [[ -n $load_commands ]] && reply+=( "load_commands" "${(F)load_commands}" )
    [[ -n $tags[hook-load] ]] && reply+=( "hook_load" "$tags[name]\0$tags[hook-load]")

    return 0
}

__zplug::sources::github::load_theme()
{
    local    repo="${1:?}"
    local -A tags default_tags
    local -a themes_ext
    local -a load_themes load_fpaths

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )
    themes_ext=("zsh-theme" "theme-zsh")
    load_themes=()
    load_fpaths=()

    if [[ -n $tags[use] ]]; then
        # e.g. zplug 'foo/bar', as:theme, use:'*.zsh'
        load_themes=( ${(@f)"$( \
            __zplug::utils::shell::expand_glob "$tags[dir]/$tags[use]" "(N-.)"
        )"} )
        if (( $#load_themes == 0 )); then
            # e.g. zplug 'foo/bar', as:theme, use:dir
            load_themes=( ${(@f)"$( \
                __zplug::utils::shell::expand_glob "$tags[dir]/$tags[use]/*.${^themes_ext}" "(N-.)"
            )"} )
        fi
    else
        # e.g. zplug 'foo/bar', as:theme
        load_themes+=( "$tags[dir]"/*.${^themes_ext}(N-.) )
    fi
    load_fpaths+=( "$tags[dir]"/_*(N.:h) )

    reply=()
    [[ -n $load_themes ]] && reply+=( "load_themes" "${(F)load_themes}" )
    [[ -n $load_fpaths ]] && reply+=( "load_fpaths" "${(F)load_fpaths}" )
    [[ -n $tags[hook-load] ]] && reply+=( "hook_load" "$tags[name]\0$tags[hook-load]")
}
