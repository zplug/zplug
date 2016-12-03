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
