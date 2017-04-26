__zplug::io::print::put()
{
    LC_ALL=POSIX command printf -- "$@"
}

__zplug::io::print::die()
{
    LC_ALL=POSIX command printf -- "$@" >&2
}

__zplug::io::print::f()
{
    local -i lines=0
    local    w pre_format post_format format func
    local -a pre_formats post_formats
    local -a formats texts
    local    arg text
    local -i fd=1
    local \
        is_end=false \
        is_multi=false
    local \
        is_end_specified=false \
        is_per_specified=false
    local \
        is_log=false
    local i

    if (( $argv[(I)--] )); then
        is_end_specified=true
    fi
    if (( $argv[(I)*%*] )); then
        is_per_specified=true
    fi

    while (( $# > 0 ))
    do
        arg="$1"
        case "$arg" in
            --put | -1)
                fd=1
                ;;
            --die | -2)
                is_log=true
                fd=2
                ;;
            --func)
                func="$funcstack[2]"
                if [[ -n $func ]]; then
                    # if $func is commands or tags
                    # trim underscores
                    if [[ $func =~ __$ ]]; then
                        func="${func:gs:_:}"
                    fi
                    pre_formats+=( "|$em[bold]$func$reset_color|" )
                fi
                ;;
            --multi)
                is_multi=true
                ;;
            --zplug)
                pre_formats+=( "[zplug]" )
                ;;
            --warn)
                pre_formats+=( "$fg[red]$em[under]WARNING$reset_color:" )
                ;;
            --error)
                pre_formats+=( "$fg[red]ERROR$reset_color:" )
                ;;
            --)
                is_end=true
                ;;
            "")
                ;;
            *)
                # Check if the double hyphens exist in args
                if $is_end_specified; then
                    # Divide
                    if $is_end; then
                        texts+=( "$arg" )
                    else
                        post_formats+=( "$arg" )
                    fi
                else
                    texts+=( "$arg" )
                fi
                ;;
        esac
        shift
    done

    # Change the output destination by the value of $fd
    {
        echo "${pre_formats[*]}" \
            | __zplug::utils::ansi::remove \
            | read pre_format
        repeat $#pre_format; do w="$w "; done

        if $is_end_specified; then
            printf "${post_formats[*]}" \
                | grep -c "" \
                | read lines
            for (( i = 1; i <= $#post_formats; i++ ))
            do
                if (( $lines == $#post_formats )); then
                    if ! $is_multi && (( $i > 1 )); then
                        pre_formats=( "$w" )
                    fi
                else
                    if (( $i > 1 )); then
                        pre_formats=()
                    fi
                fi
                formats[$i]="${pre_formats[*]} $post_formats[$i]"
            done
            command printf -- "${(j::)formats[@]}" "${texts[@]}"
        elif $is_per_specified; then
            command printf -- "${pre_formats[*]:+${pre_formats[*]} }${texts[@]}"
        else
            format="${pre_formats[*]}"
            printf "${texts[*]}" \
                | grep -c "" \
                | read lines
            for (( i = 1; i <= $#texts; i++ ))
            do
                if (( $lines == $#texts )); then
                    if ! $is_multi && (( $i > 1 )); then
                        format="$w"
                    fi
                else
                    if (( $i > 1 )); then
                        format=
                    fi
                fi
                formats[$i]="${format:+$format }$post_formats[$i]"
                command printf -- "$formats[$i]$texts[$i]"
            done
        fi
    } >&$fd

    if $is_log; then
        __zplug::log::write::error \
            "$texts[@]"
    fi
}
