__zplug::job::rollback::build()
{
    local    repo
    local -a failed

    if [[ ! -f $_zplug_config[build_rollback] ]] || [[ ! -s $_zplug_config[build_rollback] ]]; then
        __zplug::io::print::f \
            --die \
            --zplug \
            "There is no package which have to be rollbacked.\n"
        return 1
    fi

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
    done <"$_zplug_config[build_rollback]"

    # Overwrite
    if (( $#failed == 0 )); then
        rm -f "$_zplug_config[build_rollback]"
        return 0
    fi

    printf "%s\n" "$failed[@]" >|"$_zplug_config[build_rollback]"
    printf "Run '$fg_bold[default]zplug --log$reset_color' if you find cause of the failure of these build\n"
}
