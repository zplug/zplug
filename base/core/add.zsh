__zplug::core::add::to_zplugs()
{
    local    name="$1"
    local    tag key val
    local -a tags
    local -a re_tags

    # DEPRECATED: pipe
    if [[ -p /dev/stdin ]]; then
        __zplug::core::migration::pipe
        return $status
    fi

    # In the case of "from:local", it accepts multiple slashes
    if [[ ! $name =~ [~$/] ]] && [[ ! $name =~ "^[^/]+/[^/]+$" ]]; then
        __zplug::io::print::f \
            --die \
            --zplug \
            --error \
            "${(qq)name} is invalid package name\n"
        return 1
    fi

    if __zplug::base::base::is_cli; then
        # register a package to ZPLUG_LOADFILE
        __zplug::core::add::on_cli "$argv[@]"
    fi

    # Parse argv
    tags=( ${(s/, /)argv[@]:gs/,  */, } )
    name="$(__zplug::core::add::proc_at-sign "$tags[1]")"
    tags[1]=()

    # Reconstruct the tag information
    for tag in "${tags[@]}"
    do
        key=${${(s.:.)tag}[1]}
        val=${${(s.:.)tag}[2]}

        if (( $+_zplug_tags[$key] )); then
            case $key in
                "of" | "file" | "commit" | "do" | "nice")
                    # DEPRECATED: old tags
                    __zplug::core::migration::tags "$key"
                    ;;
                "from")
                    __zplug::core::sources::call "$val"
                    ;;
            esac

            re_tags+=( "$key:$val" )
        else
            __zplug::io::print::f \
                --die \
                --zplug \
                "$tag: '$key' is invalid tag name\n"
            return 1
        fi
    done

    # In case of that 'from' tag is default value
    __zplug::core::sources::use_default

    # Add to zplugs (hash array)
    # "$name" "$re_tags[@]" (<-- "key" "value")
    #   \       `-- '"as:plugin, from:github"'
    #    `-- e.g. 'enhancd'
    zplugs+=("$name" "${(j:, :)re_tags[@]:-}")
}

__zplug::core::add::proc_at-sign()
{
    local    name="$1" key
    local -i max=0

    for key in "${(k)zplugs[@]}"
    do
        if [[ $key =~ ^$name@*$ ]] && (( $max < $#key )); then
            max=$#key
            name="${key}@"
        fi
    done

    echo "$name"
}

__zplug::core::add::on_cli()
{
    local    name
    local -a tags

    tags=( ${(s/, /)argv[@]:gs/,  */, } )
    name="$tags[1]"
    tags[1]=()

    if __zplug::base::base::zpluged "$name"; then
        __zplug::io::print::f \
            --die \
            --zplug \
            "$name: already managed\n"
        return 1
    fi

    echo "zplug ${(qqq)name}${tags[@]:+", ${(j:, :)${(q)tags[@]}}"}" \
        >>|"$ZPLUG_LOADFILE"
}
