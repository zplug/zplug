typeset -a _zplug_job_queue

__zplug::job::queue::enqueue()
{
    local q

    for q in "$@"
    do
        _zplug_job_queue+=("$q")
    done
}

__zplug::job::queue::dequeue()
{
    :
}

__zplug::job::queue::clear()
{
    _zplug_job_queue=()
}

__zplug::job::queue::wait()
{
    local -i queue_max=$ZPLUG_THREADS

    if (( $#_zplug_job_queue % queue_max == 0 )); then
        wait "${_zplug_job_queue[@]}"
        __zplug::job::queue::clear
    fi 2> >(__zplug::io::log::capture) >/dev/null
}

__zplug::job::queue::wait_all()
{
    local -i queue_max=$ZPLUG_THREADS

    if (( $#_zplug_job_queue > 0 )); then
        wait "${_zplug_job_queue[@]}"
    fi 2> >(__zplug::io::log::capture) >/dev/null

    __zplug::job::queue::clear
}
