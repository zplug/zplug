__zplug::job::handle::flock()
{
    local -i retry=0 max=15 cant_lock
    local    is_escape=false
    local -a args

    local file contents

    while (( $#argv > 0 ))
    do
        case "$argv[1]" in
            --escape)
                is_escape=true
                ;;
            -*|--*)
                ;;
            *)
                args+=( "$argv[1]" )
                ;;
        esac
        shift
    done

    if (( $#args < 2 )); then
        return 1
    fi

    file="$args[1]"
    contents="$args[2]"

    # TODO: Temporary fix to solve #334
    if [[ ! -f $file ]]; then
        __zplug::log::write::info \
            "create $file because it does not exist"
        touch "$file"
    fi

    (
    until zsystem flock -t 3 "$file"
    do
        cant_lock=$status
        if (( (++retry) > max )); then
            if (( cant_lock > 0 )); then
                {
                    printf "Can't acquire lock for ${file}."
                    if (( cant_lock == 2 )); then
                        printf " timeout."
                    fi
                    printf "\n"
                } #1> >(__zplug::log::capture::error)
                return 1
            fi
            return 1
        fi
    done

    # Save the status code with LTSV
    if $is_escape; then
        print -r "$contents" >>|"$file"
    else
        print    "$contents" >>|"$file"
    fi >>|"$file"
    )
}

__zplug::job::handle::state()
{
    local repo="$argv[1]" caller="$argv[2]"
    local message

    # Save status code for process cache
    if [[ -z $status_codes[$repo] ]]; then
        status_codes[$repo]="$(__zplug::job::process::get_status_code "$repo" "$caller")"
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
            __zplug::job::message::green "$repo" "$message"
            ;;
        $_zplug_status[up_to_date])
            __zplug::job::message::white "$repo" "Up-to-date"
            ;;
        $_zplug_status[skip_local])
            __zplug::job::message::yellow "$repo" "Skip local repo"
            ;;
        $_zplug_status[skip_frozen])
            __zplug::job::message::yellow "$repo" "Skip frozen repo"
            ;;
        $_zplug_status[skip_if])
            __zplug::job::message::yellow "$repo" "Skip due to if"
            ;;
        $_zplug_status[revision_lock])
            __zplug::job::message::yellow "$repo" "Revision locked"
            ;;
        $_zplug_status[failure])
            __zplug::job::message::red "$repo" "Failed to $caller"
            ;;
        $_zplug_status[out_of_date])
            __zplug::job::message::red "$repo" "Local out of date"
            ;;
        $_zplug_status[not_on_branch])
            __zplug::job::message::red "$repo" "Not on any branch"
            ;;
        $_zplug_status[not_git_repo])
            __zplug::job::message::red "$repo" "Not git repo"
            ;;
        $_zplug_status[repo_not_found])
            __zplug::job::message::red "$repo" "Repo not found"
            ;;
        $_zplug_status[unknown] | *)
            __zplug::job::message::red "$repo" "Unknown error"
            ;;
    esac
}

__zplug::job::handle::wait()
{
    local    caller="${${(M)funcstack[@]:#__*__}:gs:_:}"
    local -i screen_size=$(($#repo_pids + 2))
    local -i spinner_idx=1 sub_spinner_idx=1
    local -a spinners sub_spinners
    local -F latency=0.1

    spinners=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    sub_spinners=(⠁ ⠁ ⠉ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠤ ⠄ ⠄ ⠤ ⠠ ⠠ ⠤ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋ ⠉ ⠈ ⠈)

    if __zplug::job::queue::is_overflow || __zplug::job::queue::is_within_range; then
        repeat $screen_size; do builtin printf "\n"; done
        #
        # Multiple progress bars
        #
        # Use printf command (not builtin) instead of __zplug::io::print::f function,
        # because this loop is run the processing by interval of 0.1 second
        # and there is a need to be called faster
        while __zplug::job::process::is_running "$repo_pids[@]" "$hook_pids[@]" || (( ${(k)#proc_states[(R)running]} > 0 ))
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
                if __zplug::job::process::is_running "$repo_pids[$repo]"; then
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

            __zplug::utils::ansi::erace_current_line
            if __zplug::job::process::is_running "$repo_pids[@]" "$hook_pids[@]"; then
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

     __zplug::job::message::spinning "$repo" "$message" "$spinners[$spinner_idx]"
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
        status_codes[$repo]="$(__zplug::job::process::get_status_code "$repo" "$caller")"
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
                builtin printf "$repo\n" >>|"$_zplug_build_log[failure]"
                builtin printf "$repo\n" >>|"$_zplug_build_log[rollback]"
            else
                builtin printf "$repo\n" >>|"$_zplug_build_log[success]"
            fi
        } & hook_pids[$repo]=$!
        # Run the timeout process in background
        {
            touch "$_zplug_lock[job]"
            # kill the process for hook-build after sleeping
            # during the number of seconds that has been set as a timeout
            sleep "$timeout"

            # Check if $repo_pids don't run
            # and check if the process ($hook_pids[$repo]) that has should be killed
            if __zplug::job::process::is_running "$hook_pids[$repo]" && ! __zplug::job::process::is_running "$repo_pids[@]"; then
                __zplug::job::process::kill "$hook_pids[$repo]"
                builtin printf "$repo\n" >>|"$_zplug_build_log[timeout]"
                builtin printf "$repo\n" >>|"$_zplug_build_log[rollback]"
            fi
            rm -f "$_zplug_lock[job]"
        } &
    fi

    __zplug::utils::ansi::erace_current_line
    if __zplug::job::process::is_running "$hook_pids[$repo]"; then
        __zplug::job::message::green \
            "$repo" "$message" "$spinners[$spinner_idx]" "$sub_spinners[$sub_spinner_idx]"
    else
        if __zplug::job::hook::build_failure "$repo"; then
            __zplug::job::message::green \
                "$repo" "$message" "" "failure"
        elif __zplug::job::hook::build_timeout "$repo"; then
            __zplug::job::message::green \
                "$repo" "$message" "" "timeout"
        else
            __zplug::job::message::green \
                "$repo" "$message" "" "success"
        fi
        proc_states[$repo]="terminated"
    fi
}

__zplug::job::handle::elapsed_time()
{
    local -F elapsed_time="$1"

    __zplug::utils::ansi::erace_current_line
    builtin printf "\n"
    LC_ALL=POSIX __zplug::io::print::f \
        --zplug \
        "Elapsed time: %.4f sec.\n" \
        $elapsed_time
}
