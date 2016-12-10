__zplug::core::share::init_parallel()
{
    local    is_install_command=false
    local    repo is_parallel=false is_select=false
    local -a repos
    local    filter

    while (( $#argv > 0 ))
    do
        case "$argv[1]" in
            --install)
                rm -f \
                    "$_zplug_config[build_success]" \
                    "$_zplug_config[build_failure]" \
                    "$_zplug_config[build_timeout]" \
                    "$_zplug_config[install_status]"
                touch "$_zplug_config[install_status]"
                is_install_command=true
                ;;
            --update)
                zstyle -s ':zplug:core:update' 'select' is_select
                zstyle ':zplug:core:update' 'select' no
                rm -f \
                    "$_zplug_config[build_success]" \
                    "$_zplug_config[build_failure]" \
                    "$_zplug_config[build_timeout]" \
                    "$_zplug_config[update_status]"
                touch "$_zplug_config[update_status]"
                ;;
            --status)
                zstyle -s ':zplug:core:status' 'select' is_select
                zstyle ':zplug:core:status' 'select' no
                rm -f "$_zplug_config[status_status]"
                touch "$_zplug_config[status_status]"
                ;;
            *)
                repos+=( "$argv[1]" )
                ;;
        esac
        shift
    done

    if $is_install_command; then
        # If no argument is given,
        # use non-installed plugins as an installation target
        if (( $#repos == 0 )); then
            repos=( $(__zplug::core::core::run_interfaces 'check' '--debug') )
            if (( $#repos == 0 )); then
                __zplug::io::print::f \
                    --zplug --die \
                    "no packages to install\n"
                return 1
            fi
        fi
    fi

    if (( $_zplug_boolean_true[(I)$is_select] )); then
        filter="$(
        __zplug::utils::shell::search_commands \
            "$ZPLUG_FILTER"
        )"
        if [[ -z $filter ]]; then
            __zplug::io::print::f \
                --die \
                --zplug \
                --error \
                --func \
                "There is no available filter in ZPLUG_FILTER\n"
            return 1
        fi
        repos+=( ${(@f)"$(echo "${(Fk)zplugs[@]}" | eval "$filter")"} )

        # Cace of type Ctrl-C
        if (( $#repos == 0 )); then
            return 1
        fi
    fi

    if (( $#repos == 0 )); then
        repos=( "${(k)zplugs[@]:gs:@::}" )
    fi

    # Check the number of arguments
    if (( $#repos > 1 )); then
        is_parallel=true
    fi

    for repo in "${repos[@]}"
    do
        if ! __zplug::base::base::zpluged "$repo"; then
            __zplug::io::print::f \
                --die \
                --zplug \
                "$repo: no such package\n"
            return 1
        fi
    done

    # Suppress outputs
    setopt nonotify nomonitor
    tput civis

    __zplug::io::print::f \
        --zplug \
        "Start to get remote status %d plugin${is_parallel:+"s"} %s\n\n" \
        $#repos \
        "${is_parallel:+"in parallel"}"

    reply=("$repos[@]")
}

__zplug::core::share::elapsed_time()
{
    local -F elapsed_time="$1"

    tput cnorm
    __zplug::utils::ansi::erace_current_line
    printf "\n"
    __zplug::io::print::f \
        --zplug \
        "Elapsed time: %.4f sec.\n" \
        $elapsed_time
}
