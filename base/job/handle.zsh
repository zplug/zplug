__zplug::job::handle::flock()
{
    local file="${1:?}" contents="${2:?}"

    (
    zsystem flock -t 30 "$file"
    cant_lock=$status
    if (( cant_lock > 0 )); then
        {
            printf "Can't acquire lock for ${file}."
            if (( cant_lock == 2 )); then
                printf " timeout."
            fi
            printf "\n"
        } 1> >(__zplug::io::log::capture)
        return 1
    fi

    # Save the status code with LTSV
    __zplug::io::print::f "$contents\n" >>|"$file"
    )
}

__zplug::job::handle::state()
{
    local repo="$argv[1]" caller="$argv[2]"

    # Save status code for process cache
    if [[ -z $status_codes[$repo] ]]; then
        status_codes[$repo]="$(__zplug::job::state::get "$repo" "$caller")"
    fi

    case $status_codes[$repo] in
        $_zplug_status[success])
            case "$caller" in
                install)
                    __zplug::job::message::green "Installed!" "$repo" ;;
                update)
                    __zplug::job::message::green "Updated!" "$repo" ;;
                status)
                    __zplug::job::message::terminated "Up-to-date" "$repo" ;;
            esac
            ;;
        $_zplug_status[failure])
            __zplug::job::message::zombie "Failed to $caller" "$repo"
            ;;
        $_zplug_status[up_to_date])
            __zplug::job::message::terminated "Up-to-date" "$repo"
            ;;
        $_zplug_status[skip_local])
            __zplug::job::message::waiting "Skip local repo" "$repo"
            ;;
        $_zplug_status[skip_frozen])
            __zplug::job::message::waiting "Skip frozen repo" "$repo"
            ;;
        $_zplug_status[skip_if])
            __zplug::job::message::waiting "Skip due to if" "$repo"
            ;;
        $_zplug_status[out_of_date])
            __zplug::job::message::zombie "Local out of date" "$repo"
            ;;
        $_zplug_status[not_on_branch])
            __zplug::job::message::zombie "Not on any branch" "$repo"
            ;;
        $_zplug_status[not_git_repo])
            __zplug::job::message::zombie "Not git repo" "$repo"
            ;;
        $_zplug_status[repo_not_found])
            __zplug::job::message::zombie "Repo not found" "$repo"
            ;;
        $_zplug_status[unknown] | *)
            __zplug::job::message::zombie "Unknown repo" "$repo"
            ;;
    esac
}

__zplug::job::handle::wait()
{
    local caller="${${(M)funcstack[@]:#__*__}:gs:_:}"

    if ( (( $#repos >= $queue_max )) && (( $#repo_pids >= $queue_max )) ) ||
        ( (( $#repos >= $queue_max )) && (( $#status_codes == $#repos )) ) ||
        ( (( $#repos < $queue_max )) && (( $#repo_pids == $#repos )) ); then
        repeat $(($#repo_pids + 2)); do printf "\n"; done
        #
        # Multiple progress bars
        #
        # Use printf command (not builtin) instead of __zplug::io::print::f function,
        # because this loop is run the processing by interval of 0.1 second
        # and there is a need to be called faster
        while __zplug::job::state::running "$repo_pids[@]" "$hook_pids[@]" || (( ${(k)#proc_states[(R)running]} > 0 ))
        do
            sleep 0.1
            __zplug::utils::ansi::cursor_up $(($#repo_pids + 2))

            # Count up within _zplug_spinners index
            if (( ( spinner_idx+=1 ) > $#_zplug_spinners )); then
                spinner_idx=1
            fi
            # Count up within _zplug_sub_spinners index
            if (( ( subspinner_idx+=1 ) > $#_zplug_sub_spinners )); then
                subspinner_idx=1
            fi

            # Processing pids
            for repo in "${(k)repo_pids[@]}"
            do
                if __zplug::job::state::running "$repo_pids[$repo]"; then
                    __zplug::job::handle::running "$repo" "$caller"
                    proc_states[$repo]="running"
                else
                    # If $repo has build-hook tag
                    if [[ -n $hook_build[$repo] ]]; then
                        __zplug::job::handle::hook "$repo" "$caller"
                    else
                        __zplug::job::handle::state "$repo" "$caller"
                    fi
                    proc_states[$repo]="terminated"
                fi
            done

            if __zplug::job::state::running "$repo_pids[@]" "$hook_pids[@]"; then
                printf "\n"
                __zplug::io::print::f \
                    --zplug \
                    "Finished: %d/%d plugins\n" \
                    ${(k)#proc_states[(R)terminated]} \
                    $#repos
            else
                repo_pids=()
            fi
        done
    fi
}

__zplug::job::handle::running()
{
    local repo="$argv[1]" caller="$argv[2]"

    case "$caller" in
        install)
            __zplug::job::message::running \
                "$_zplug_spinners[$spinner_idx]" \
                "Installing..." "$repo"
            ;;
        update)
            __zplug::job::message::running \
                "$_zplug_spinners[$spinner_idx]" \
                "Updating..." "$repo"
            ;;
        status)
            __zplug::job::message::running \
                "$_zplug_spinners[$spinner_idx]" \
                "Fetching..." "$repo"
            ;;
    esac
}

__zplug::job::handle::hook()
{
    local repo="$argv[1]" caller="$argv[2]"

    # Save status code for process cache
    if [[ -z $status_codes[$repo] ]]; then
        status_codes[$repo]="$(__zplug::job::state::get "$repo" "$caller")"
    fi
    if [[ $status_codes[$repo] != 0 ]]; then
        __zplug::job::handle::state "$repo" "$caller"
        proc_states[$repo]="terminated"
        continue
    fi

    if ! $hook_finished[$repo]; then
        hook_finished[$repo]=true
        # Run the hook-build in background
        {
            __zplug::job::hook::build "$repo"
            if (( $status > 0 )); then
                printf "$repo\n" >>|"$_zplug_config[build_failure]"
                printf "$repo\n" >>|"$_zplug_config[build_rollback]"
            else
                printf "$repo\n" >>|"$_zplug_config[build_success]"
            fi
        } & hook_pids[$repo]=$!
        # Run the timeout process in background
        {
            # kill the process for hook-build after sleeping
            # during the number of seconds that has been set as a timeout
            sleep "$timeout"

            # Check if $repo_pids don't run
            # and check if the process ($hook_pids[$repo]) that has should be killed
            if __zplug::job::state::running $hook_pids[$repo] && ! __zplug::job::state::running "$repo_pids[@]"; then
                __zplug::job::state::kill $hook_pids[$repo]
                printf "$repo\n" >>|"$_zplug_config[build_timeout]"
                printf "$repo\n" >>|"$_zplug_config[build_rollback]"
            fi
        } &
    fi

    if __zplug::job::state::running "$hook_pids[$repo]"; then
        # running build-hook
        __zplug::utils::ansi::erace_current_line
        case "$caller" in
            install)
                __zplug::job::message::installed_with_hook_spinning \
                    "$_zplug_spinners[$spinner_idx]" \
                    "$repo" \
                    "$_zplug_sub_spinners[$subspinner_idx]"
                ;;
            update)
                __zplug::job::message::updated_with_hook_spinning \
                    "$_zplug_spinners[$spinner_idx]" \
                    "$repo" \
                    "$_zplug_sub_spinners[$subspinner_idx]"
                ;;
        esac
    else
        # finished build-hook
        __zplug::utils::ansi::erace_current_line
        case "$caller" in
            install)
                if __zplug::job::hook::build_failure "$repo"; then
                    __zplug::job::message::installed_with_hook_failure "$repo"
                elif __zplug::job::hook::build_timeout "$repo"; then
                    __zplug::job::message::installed_with_hook_timeout "$repo"
                else
                    __zplug::job::message::installed_with_hook_success "$repo"
                fi
                ;;
            update)
                if __zplug::job::hook::build_failure "$repo"; then
                    __zplug::job::message::updated_with_hook_failure "$repo"
                elif __zplug::job::hook::build_timeout "$repo"; then
                    __zplug::job::message::updated_with_hook_timeout "$repo"
                else
                    __zplug::job::message::updated_with_hook_success "$repo"
                fi
                ;;
        esac
    fi
}
