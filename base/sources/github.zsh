__zplug::sources::github::check()
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

    [[ -d $tags[dir] ]]
    return $status
}

__zplug::sources::github::install()
{
    local repo="$1"

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::utils::git::clone "$repo"
    return $status
}

__zplug::sources::github::update()
{
    local    repo="$1"
    local    rev_local rev_remote rev_base
    local -A tags

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    tags[dir]="$(__zplug::core::core::run_interfaces 'dir' "$repo")"
    tags[at]="$(__zplug::core::core::run_interfaces 'at' "$repo")"

    __zplug::utils::git::merge \
        --dir    "$tags[dir]" \
        --branch "$tags[at]"

    return $status
}

__zplug::sources::github::get_url()
{
    local repo="$1" url_format

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

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
    local    repo="$1"
    local -A tags default_tags
    local -a plugins_ext themes_ext
    local -a unclassified_plugins
    local    ext

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )
    default_tags[use]="$(__zplug::core::core::run_interfaces 'use' "$repo")"

    # If that is an autoload plugin
    if (( $_zplug_boolean_true[(I)$tags[lazy]] )); then
        if [[ $tags[use] != '*.zsh' ]]; then
            unclassified_plugins+=( ${(@f)"$( \
                __zplug::utils::shell::expand_glob "$tags[dir]/$tags[use]" "(N-.)"
            )"} )
            load_fpaths+=( $unclassified_plugins:h(N/) )
        else
            unclassified_plugins+=( \
                "$tags[dir]/autoload"/*(N.) \
                "$tags[dir]/functions"/*(N.) \
            )
            load_fpaths+=( \
                "$tags[dir]/autoload"(N/) \
                "$tags[dir]/functions"(N/) \
            )
        fi
    else
    # Default load behavior for plugins
    plugins_ext=("plugin.zsh" "zsh-theme" "theme-zsh")
    themes_ext=("zsh-theme" "theme-zsh")

    # In order to find main file of the plugin,
    # narrow down the candidates in three stages
    # 1. use $plugins_ext[@] ==> foo.plugin.zsh
    # 2. use $tags[use] as a file like "*.zsh" ==> bar.zsh
    # 3. use in combination
    #    - tags[use] as a directory like "bin"
    #    - and *.zsh files ==> bar.zsh
    for ext in "${plugins_ext[@]}"
    do
        if [[ $tags[use] == $default_tags[use] ]]; then
            # NOTE: step 1
            unclassified_plugins+=( "$tags[dir]"/*.$ext(N-.) )
        fi

        if (( $#unclassified_plugins == 0 )); then
            # NOTE: step 2
            # If $tags[use] is a regular file,
            # expect to expand to $tags[dir]/*.zsh
            unclassified_plugins+=( ${(@f)"$( \
                __zplug::utils::shell::expand_glob "$tags[dir]/$tags[use]" "(N-.)"
            )"} )
            # Add the parent directory to fpath
            load_fpaths+=( $tags[dir]/_*(N.:h) )

            # NOTE: step 3
            # If $tags[use] is a directory,
            # expect to expand to $tags[dir]/*.zsh
            if (( $#unclassified_plugins == 0 )); then
                unclassified_plugins+=( ${(@f)"$( \
                    __zplug::utils::shell::expand_glob "$tags[dir]/$tags[use]/$default_tags[use]" "(N-.)"
                )"} )
                # Add the parent directory to fpath
                load_fpaths+=( $tags[dir]/$tags[use]/_*(N.:h) )
            fi
        fi
    done
    fi

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $unclassified_plugins ]] && reply+=( unclassified_plugins "${(F)unclassified_plugins}" )
}

__zplug::sources::github::load_command()
{
    local    repo="$1"
    local -A tags
    local    dst basename
    local -a sources
    local -a load_fpaths load_commands

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    basename="${repo:t}"
    tags[dir]="${tags[dir]%/}"
    dst=${${tags[rename-to]:+$ZPLUG_HOME/bin/$tags[rename-to]}:-"$ZPLUG_HOME/bin"}

    # Add parent directories to fpath if any files starting in _* exist
    load_fpaths+=(${tags[dir]}/{_*,/**/_*}(N-.:h))

    # If no USE is specified, link all executables in $tags[dir] to $dst
    if [[ $tags[use] == '*.zsh' ]]; then
        tags[use]="*(N-*)"
    fi

    sources=( ${(@f)"$( \
        __zplug::utils::shell::expand_glob "$tags[dir]/${tags[use]}" "(N-)"
    )"} )

    # Try again assuming executable file name is the same as repo name
    if (( $#sources == 0 )); then
        sources=( $tags[dir]/$basename )
    fi

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
    for src in "${sources[@]}"
    do
        load_commands+=("$src\0$dst")
    done

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_commands ]] && reply+=( load_commands "${(F)load_commands}" )

    return 0
}
