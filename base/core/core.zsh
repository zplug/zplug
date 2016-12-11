__zplug::core::core::get_interfaces()
{
    local    arg name desc
    local    target
    local -a targets
    local    interface
    local -A interfaces
    local    is_key=false is_prefix=false

    while (( $# > 0 ))
    do
        arg="$1"
        case "$arg" in
            --key)
                is_key=true
                ;;
            --prefix)
                is_prefix=true
                ;;
            -* | --*)
                ;;
            "")
                ;;
            *)
                targets+=( "$arg" )
                ;;
        esac
        shift
    done

    # Initialize
    reply=()

    for target in "${targets[@]}"
    do
        interfaces=()
        for interface in "$ZPLUG_ROOT/autoload/$target"/__*__(N-.)
        do
            # TODO: /^.*desc(ription)?: ?/
            name="${interface:t:gs:_:}"
            if $is_prefix; then
                name="__${name}__"
            fi

            desc=""
            while IFS= read -r line
            do
                if [[ "$line" =~ "# Description:" ]]; then
                    IFS= read -r desc
                    regexp-replace desc "^# *" ""
                    break
                fi
            done < "$interface"

            interfaces[$name]="$desc"
        done

        if $is_key; then
            reply+=( "${(k)interfaces[@]}" )
        else
            reply+=( "${(kv)interfaces[@]}" )
        fi
    done
}

__zplug::core::core::run_interfaces()
{
    local    arg="$1"; shift
    local    interface
    local -i ret=0

    if [[ -z $arg ]]; then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    interface="__${arg:gs:_:}__"

    # Do autoload if not exists in $functions
    if (( ! $+functions[$interface] )); then
        autoload -Uz "$interface"
    fi

    # Execute
    ${=interface} "$argv[@]"
    ret=$status

    # It may be discarded
    unfunction "$interface" &>/dev/null

    return $ret
}

__zplug::core::core::prepare()
{
    # Unique array
    typeset -gx -U path
    typeset -gx -U fpath

    # Add to the PATH
    path=(
    ${ZPLUG_ROOT:+"$ZPLUG_ROOT/bin"}
    ${ZPLUG_HOME:+"$ZPLUG_HOME/bin"}
    "$path[@]"
    )

    # Add to the FPATH
    fpath=(
    "$ZPLUG_ROOT"/misc/completions(N-/)
    "$ZPLUG_ROOT/base/sources"
    "$fpath[@]"
    )

    # Check whether you meet the requirements for using zplug
    # 1. zsh 4.3.9 or more
    # 2. git
    # 3. nawk or gawk
    {
        if ! __zplug::base::base::zsh_version 4.3.9; then
            __zplug::io::print::f \
                --die \
                --zplug \
                --error \
                "zplug does not work this version of zsh $ZSH_VERSION.\n" \
                "You must use zsh 4.3.9 or later.\n"
            return 1
        fi

        if ! __zplug::base::base::git_version 1.7; then
            __zplug::io::print::f \
                --die \
                --zplug \
                --error \
                "git command not found in \$PATH\n" \
                "zplug depends on git 1.7 or later.\n"
            return 1
        fi

        if ! __zplug::utils::awk::available; then
            __zplug::io::print::f \
                --die \
                --zplug \
                --error \
                'No available AWK variant in your $PATH\n'
            return 1
        fi
    }

    # Release zplug variables and export
    __zplug::core::core::variable || return 1

    mkdir -p "$ZPLUG_REPOS"
    mkdir -p "$ZPLUG_HOME/bin"

    # Setup manage directory
    mkdir -p "$ZPLUG_MANAGE"/{var,tmp}/log

    # Run compinit if zplug comp file hasn't load
    if (( ! $+functions[_zplug] )); then
        compinit -C -d "$ZPLUG_HOME/zcompdump"
    fi
}

__zplug::core::core::variable()
{
    # for 'autoload -Uz zplug' in another subshell
    export FPATH="$ZPLUG_ROOT/autoload:$FPATH"

    typeset -gx    ZPLUG_HOME=${ZPLUG_HOME:-~/.zplug}
    typeset -gx -i ZPLUG_THREADS=${ZPLUG_THREADS:-16}
    typeset -gx    ZPLUG_PROTOCOL=${ZPLUG_PROTOCOL:-HTTPS}
    typeset -gx    ZPLUG_FILTER=${ZPLUG_FILTER:-"fzf-tmux:fzf:peco:percol:fzy:zaw"}
    typeset -gx    ZPLUG_LOADFILE=${ZPLUG_LOADFILE:-$ZPLUG_HOME/packages.zsh}
    typeset -gx    ZPLUG_USE_CACHE=${ZPLUG_USE_CACHE:-true}
    typeset -gx    ZPLUG_CACHE_DIR=${ZPLUG_CACHE_DIR:-$ZPLUG_HOME/.cache}
    typeset -gx    ZPLUG_REPOS=${ZPLUG_REPOS:-$ZPLUG_HOME/repos}
    typeset -gx    ZPLUG_SUDO_PASSWORD
    typeset -gx    ZPLUG_ERROR_LOG=${ZPLUG_ERROR_LOG:-$ZPLUG_HOME/.error_log}

    typeset -gx    _ZPLUG_VERSION="2.3.4"
    typeset -gx    _ZPLUG_URL="https://github.com/zplug/zplug"
    typeset -gx    _ZPLUG_OHMYZSH="robbyrussell/oh-my-zsh"
    typeset -gx    _ZPLUG_PREZTO="sorin-ionescu/prezto"
    typeset -gx    _ZPLUG_AWKPATH="$ZPLUG_ROOT/misc/contrib"

    typeset -gx -i _ZPLUG_STATUS_SUCCESS=0
    typeset -gx -i _ZPLUG_STATUS_FAILURE=1
    typeset -gx -i _ZPLUG_STATUS_TRUE=0
    typeset -gx -i _ZPLUG_STATUS_FALSE=1
    typeset -gx -i _ZPLUG_STATUS_REPO_NOT_FOUND=2
    typeset -gx -i _ZPLUG_STATUS_REPO_FROZEN=3
    typeset -gx -i _ZPLUG_STATUS_REPO_UP_TO_DATE=4
    typeset -gx -i _ZPLUG_STATUS_REPO_LOCAL=5
    typeset -gx -i _ZPLUG_STATUS_INVALID_ARGUMENT=6
    typeset -gx -i _ZPLUG_STATUS_INVALID_OPTION=7
    typeset -gx -i _ZPLUG_STATUS_ERROR_PARSE=8
    typeset -gx -i _ZPLUG_STATUS_ZPLUG_IS_LATEST=101
    typeset -gx -i _ZPLUG_STATUS_=255

    typeset -gx     ZPLUG_MANAGE="$ZPLUG_HOME/.zplug"

    typeset -gx -a _zplug__zplug_spinners _zplug__zplug_sub_spinners
    _zplug_spinners=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    _zplug_sub_spinners=(⠁ ⠁ ⠉ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠤ ⠄ ⠄ ⠤ ⠠ ⠠ ⠤ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋ ⠉ ⠈ ⠈)

    # user-defined exit code 64..113
    typeset -gx -A _zplug_status
    _zplug_status=(
    # compatible
    "success"            0
    "failure"            1
    "true"               0
    "false"              1
    "repo_not_found"     2
    "repo_frozen"        3
    "repo_up_to_date"    4
    "repo_local"         5
    "invalid_argument"   6
    "invalid_option"     7
    "parse_error"        8
    "latest_version"     101
    # installation
    "install_success"    0
    "install_failure"    1
    "install_already"    2
    "install_skip_if"    3
    "install_unknown"    4
    # update
    "update_success"         0
    "update_failure"         1
    "update_already"         2
    "update_skip_if"         5
    "update_up_to_date"      4
    "update_skip_frozen"     3
    "update_local_repo"      7
    "update_repo_not_found"  9
    "update_unknown"         8
    # status
    "status_up_to_date"         0
    "status_local_out_of_date"  1
    "status_not_on_any_branch"  2 # TODO
    "status_not_git_repo"       3 # TODO
    "status_unknown"            4
    "status_repo_not_found"     5 # TODO
    "status_skip_local_repo"    6 # TODO
    # based on bash scripting
    # - http://tldp.org/LDP/abs/html/exitcodes.html
    "error"                  1
    "builtin_error"          2
    "diff_binary"            2
    "command_not_executable" 126
    "command_not_found"      127
    "exit_syntax_error"      128
    "error_signal_hup"       129
    "error_signal_int"       130
    "error_signal_kill"      137
    # TODO: add others
    )

    typeset -gx -A _zplug_config
    _zplug_config=(
    "install_status" "$ZPLUG_MANAGE/tmp/installed"
    "update_status"  "$ZPLUG_MANAGE/tmp/updated"
    "status_status"  "$ZPLUG_MANAGE/tmp/status_status"

    "build_success"  "$ZPLUG_MANAGE/tmp/build_success"
    "build_failure"  "$ZPLUG_MANAGE/tmp/build_failure"
    "build_timeout"  "$ZPLUG_MANAGE/tmp/build_timeout"
    "build_rollback" "$ZPLUG_MANAGE/tmp/build_rollback"

    "error_log"      "$ZPLUG_MANAGE/var/log/error_log"
    "execution_log"  "$ZPLUG_MANAGE/var/log/execution_log"
    )

    typeset -gx -A _zplug_cache
    _zplug_cache=(
    "interface"      "$ZPLUG_CACHE_DIR/interface"
    "failed_repos"   "$ZPLUG_CACHE_DIR/failed_repos"
    "plugin"         "$ZPLUG_CACHE_DIR/plugin.zsh"
    "lazy_plugin"    "$ZPLUG_CACHE_DIR/lazy_plugin.zsh"
    "theme"          "$ZPLUG_CACHE_DIR/theme.zsh"
    "command"        "$ZPLUG_CACHE_DIR/command.zsh"
    "fpath"          "$ZPLUG_CACHE_DIR/fpath.zsh"
    "defer_1_plugin" "$ZPLUG_CACHE_DIR/defer_1_plugin.zsh"
    "defer_2_plugin" "$ZPLUG_CACHE_DIR/defer_2_plugin.zsh"
    "defer_3_plugin" "$ZPLUG_CACHE_DIR/defer_3_plugin.zsh"
    )

    if (( $+ZPLUG_SHALLOW )); then
        __zplug::io::print::f \
            --die \
            --zplug \
            --warn \
            "ZPLUG_SHALLOW is deprecated." \
            "Please use 'zstyle :zplug:tag depth 1' instead.\n"
    fi

    if (( $+ZPLUG_CACHE_FILE )); then
        __zplug::io::print::f \
            --die \
            --zplug \
            --warn \
            "ZPLUG_CACHE_FILE is deprecated." \
            "Please use 'ZPLUG_CACHE_DIR' instead.\n"
    fi

    if (( $+ZPLUG_CLONE_DEPTH )); then
        __zplug::io::print::f \
            --die \
            --zplug \
            --warn \
            "ZPLUG_CLONE_DEPTH is deprecated." \
            "Please use 'zstyle :zplug:tag depth $ZPLUG_CLONE_DEPTH' instead.\n"
    fi


    # zplug core variables
    {
        typeset -gx -A -U \
            _zplug_options \
            _zplug_commands \
            _zplug_tags

        __zplug::core::options::get; _zplug_options=( "${reply[@]}" )
        __zplug::core::commands::get; _zplug_commands=( "${reply[@]}" )
        __zplug::core::tags::get; _zplug_tags=( "${reply[@]}" )
    }

    # boolean
    {
        typeset -gx -a \
            _zplug_boolean_true \
            _zplug_boolean_false

        _zplug_boolean_true=("true" "yes" "on" 1)
        _zplug_boolean_false=("false" "no" "off" 0)
    }

    # context ":zplug:config:setopt"
    {
        local -a only_subshell
        typeset -gx _ZPLUG_CONFIG_SUBSHELL=":"

        zstyle -a ":zplug:config:setopt" \
            only_subshell \
            only_subshell
        zstyle -t ":zplug:config:setopt" \
            same_curshell

        if (( $_zplug_boolean_true[(I)$same_curshell] )); then
            only_subshell=(
            "${only_subshell[@]:gs:_:}"
            $(setopt)
            )
        fi

        if (( $#only_subshell > 0 )); then
            _ZPLUG_CONFIG_SUBSHELL="setopt ${(u)only_subshell[@]}"
        fi
    }

    zmodload zsh/terminfo
    typeset -gx -A em
    em[under]="$terminfo[smul]"
    em[bold]="$terminfo[bold]"
}
