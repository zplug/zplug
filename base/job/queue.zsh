__zplug::job::queue::is_overflow()
{
    local -i queue_max=$ZPLUG_THREADS

    # Keep the number of processes to be generated concurrently
    # to the number specified by the ZPLUG_THREADS variable.
    # When there is the number of repositories exceeding the upper limit number,
    # the next process is not generated until all the generated processes are finished.
    # For example, wait for every 16 processes (the default value of ZPLUG_THREADS)
    # when processing 40 repositories.
    # In this example, the third wait captures the remaining 8 processes.
    if (( $#repos >= $queue_max )); then
        if (( $#repo_pids >= $queue_max )) || (( $#status_codes == $#repos )); then
            return 0
        fi
    fi
    return 1
}

__zplug::job::queue::is_within_range()
{
    local -i queue_max=$ZPLUG_THREADS

    # If the number of repositories is less than the upper limit number,
    # wait for all processes immediately.
    if (( $#repos < $queue_max )) && (( $#repo_pids == $#repos )); then
        return 0
    fi
    return 1
}
