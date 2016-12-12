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
    local message

    # Save status code for process cache
    if [[ -z $status_codes[$repo] ]]; then
        status_codes[$repo]="$(__zplug::job::state::get "$repo" "$caller")"
    fi

    case $status_codes[$repo] in
        $_zplug_status[success])
            case "$caller" in
                install)
                    message="Installed!"
                    ;;
                update)
                    message="Updated!"
                    ;;
            esac
            __zplug::job::message::green \
                --message "$message" \
                --repo "$repo"
            ;;
        $_zplug_status[up_to_date])
            __zplug::job::message::terminated \
                --message "Up-to-date" \
                --repo "$repo"
            ;;
        $_zplug_status[skip_local])
            __zplug::job::message::yellow \
                --message "Skip local repo" \
                --repo "$repo"
            ;;
        $_zplug_status[skip_frozen])
            __zplug::job::message::yellow \
                --message "Skip frozen repo" \
                --repo "$repo"
            ;;
        $_zplug_status[skip_if])
            __zplug::job::message::yellow \
                --message "Skip due to if" \
                --repo "$repo"
            ;;
        $_zplug_status[failure])
            __zplug::job::message::red \
                --message "Failed to $caller" \
                --repo "$repo"
            ;;
        $_zplug_status[out_of_date])
            __zplug::job::message::red \
                --message "Local out of date" \
                --repo "$repo"
            ;;
        $_zplug_status[not_on_branch])
            __zplug::job::message::red \
                --message "Not on any branch" \
                --repo "$repo"
            ;;
        $_zplug_status[not_git_repo])
            __zplug::job::message::red \
                --message "Not git repo" \
                --repo "$repo"
            ;;
        $_zplug_status[repo_not_found])
            __zplug::job::message::red \
                --message "Repo not found" \
                --repo "$repo"
            ;;
        $_zplug_status[unknown] | *)
            __zplug::job::message::red \
                --message "Unknown error" \
                --repo "$repo"
            ;;
    esac
}

__zplug::job::handle::wait()
{
    local    caller="${${(M)funcstack[@]:#__*__}:gs:_:}"
    local -i queue_max=$ZPLUG_THREADS
    local -i screen_size=$(($#repo_pids + 2))
    local -i spinner_idx=1 sub_spinner_idx=1
    local -a spinners sub_spinners
    local -F latency=0.05

    spinners=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    sub_spinners=(⠁ ⠁ ⠉ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠤ ⠄ ⠄ ⠤ ⠠ ⠠ ⠤ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋ ⠉ ⠈ ⠈)

    if ( (( $#repos >= $queue_max )) && (( $#repo_pids >= $queue_max )) ) ||
        ( (( $#repos >= $queue_max )) && (( $#status_codes == $#repos )) ) ||
        ( (( $#repos < $queue_max )) && (( $#repo_pids == $#repos )) ); then
        repeat $screen_size; do printf "\n"; done
        #
        # Multiple progress bars
        #
        # Use printf command (not builtin) instead of __zplug::io::print::f function,
        # because this loop is run the processing by interval of 0.1 second
        # and there is a need to be called faster
        while __zplug::job::state::running "$repo_pids[@]" "$hook_pids[@]" || (( ${(k)#proc_states[(R)running]} > 0 ))
        do
            sleep "$latency"
            __zplug::utils::ansi::cursor_up $screen_size

            # Count up within spinners index
            if (( ( spinner_idx+=1 ) > $#spinners )); then
                spinner_idx=1
            fi
            # Count up within sub_spinners index
            if (( ( sub_spinner_idx+=1 ) > $#sub_spinners )); then
                sub_spinner_idx=1
            fi

            # Processing pids
            for repo in "${(k)repo_pids[@]}"
            do
                if __zplug::job::state::running "$repo_pids[$repo]"; then
                    __zplug::job::handle::running "$repo" "$caller"
                    proc_states[$repo]="running"
                else
                    if [[ -n $hook_build[$repo] ]]; then
                        __zplug::job::handle::hook "$repo" "$caller"
                        # If the repo has a hook-build,
                        # it can not be said that the processing has ended yet,
                        # so do not set a flag.
                        # ==> proc_states[$repo]="terminated"
                    else
                        __zplug::job::handle::state "$repo" "$caller"
                        proc_states[$repo]="terminated"
                    fi
                fi
            done

            if __zplug::job::state::running "$repo_pids[@]" "$hook_pids[@]"; then
                builtin printf "\n"
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
    local message

    case "$caller" in
        install)
            message="Installing..."
            ;;
        update)
            message="Updating..."
            ;;
        status)
            message="Fetching..."
            ;;
    esac

    __zplug::job::message::running \
        --spinner "$spinners[$spinner_idx]" \
        --message "$message" \
        --repo "$repo"
}

__zplug::job::handle::hook()
{
    local    repo="$argv[1]" caller="$argv[2]"
    local -i timeout=60
    local    message

    case "$caller" in
        install)
            message="Installed!"
            ;;
        update)
            message="Updated!"
            ;;
    esac

    # Save status code for process cache
    if [[ -z $status_codes[$repo] ]]; then
        status_codes[$repo]="$(__zplug::job::state::get "$repo" "$caller")"
    fi

    # If the installation or updating fails in the first place,
    # exits the loop here to stop the hook-build
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
            if __zplug::job::state::running "$hook_pids[$repo]" && ! __zplug::job::state::running "$repo_pids[@]"; then
                __zplug::job::state::kill "$hook_pids[$repo]"
                printf "$repo\n" >>|"$_zplug_config[build_timeout]"
                printf "$repo\n" >>|"$_zplug_config[build_rollback]"
            fi
        } &
    fi

    __zplug::utils::ansi::erace_current_line
    if __zplug::job::state::running "$hook_pids[$repo]"; then
        __zplug::job::message::green \
            --spinner "$spinners[$spinner_idx]" \
            --message "$message" \
            --repo "$repo" \
            --hook "$sub_spinners[$sub_spinner_idx]"
    else
        if __zplug::job::hook::build_failure "$repo"; then
            __zplug::job::message::green \
                --message "$message" \
                --repo "$repo" \
                --hook=failure
        elif __zplug::job::hook::build_timeout "$repo"; then
            __zplug::job::message::green \
                --message "$message" \
                --repo "$repo" \
                --hook=timeout
        else
            __zplug::job::message::green \
                --message "$message" \
                --repo "$repo" \
                --hook=success
        fi
        proc_states[$repo]="terminated"
    fi
}

__zplug::job::handle::elapsed_time()
{
    local -F elapsed_time="$1"

    __zplug::utils::ansi::erace_current_line
    printf "\n"
    __zplug::io::print::f \
        --zplug \
        "Elapsed time: %.4f sec.\n" \
        $elapsed_time
}
