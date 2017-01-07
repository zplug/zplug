__zplug::job::rollback::build()
{
    local    repo
    local -a failed

    if [[ ! -f $_zplug_build_log[rollback] ]] || [[ ! -s $_zplug_build_log[rollback] ]]; then
        __zplug::io::print::f \
            --die \
            --zplug \
            "There is no package which have to be rollbacked.\n"
        return 1
    fi

    tput civis
    while read repo
    do
        if [[ -z $repo ]]; then
            continue
        fi

        printf "$fg_bold[default]%s$reset_color %s\n" \
            ${(r,20,):-"Building..."} \
            "$repo"

        __zplug::utils::ansi::cursor_up 1
        __zplug::job::hook::build "$repo"

        if (( $status > 0 )); then
            failed+=( "$repo" )
            printf "$fg[red]%s$reset_color %s\n" \
                ${(r,20,):-"Failed to build!"} \
                "$repo"
        else
            printf "$fg[green]%s$reset_color %s\n" \
                ${(r,20,):-"Built successfully!"} \
                "$repo"
        fi
    done <"$_zplug_build_log[rollback]"
    tput cnorm

    # Overwrite
    if (( $#failed == 0 )); then
        rm -f "$_zplug_build_log[rollback]"
        return 0
    fi

    printf "%s\n" "$failed[@]" >|"$_zplug_build_log[rollback]"
    printf "Run '$fg_bold[default]zplug --log$reset_color' if you find cause of the failure of these build\n"
}

__zplug::job::rollback::message()
{
    if [[ -s $_zplug_build_log[rollback] ]]; then
        if [[ -f $_zplug_build_log[failure] ]] || [[ -f $_zplug_build_log[timeout] ]]; then
            __zplug::io::print::f \
                --zplug \
                "$fg_bold[red]These hook-build were failed to run:$reset_color\n"
            # Listing the packages that have failed to build
            {
                sed 's/^/ - /g' "$_zplug_build_log[failure]"
                sed 's/^/ - /g' "$_zplug_build_log[timeout]"
            } 2>/dev/null
            __zplug::io::print::f \
                --zplug \
                "To retry these hook-build, please run '$fg_bold[default]%s$reset_color'.\n" \
                "zplug --rollback=build"
        fi
    fi
}
