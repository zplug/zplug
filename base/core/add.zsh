__zplug::core::add::to_zplugs()
{
    local    name
    local    tag key val
    local -a tags
    local -a re_tags

    tags=( ${(s/, /)@:gs/,  */, } )
    name="$tags[1]"
    tags[1]=()

    # DEPRECATED: pipe
    if [[ -p /dev/stdin ]]; then
        __zplug::core::v1::pipe
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
        if __zplug::base::base::zpluged "$name"; then
            __zplug::io::print::f \
                --die \
                --zplug \
                "$name: already managed\n"
            return 1
        else
            # Add to the external file
            __zplug::io::file::append \
                "zplug ${(qqq)name}${tags[@]:+", ${(j:, :)${(q)tags[@]}}"}"
        fi
    fi

    name="$(__zplug::core::add::proc_at-sign "$name")"

    # Automatically add "as:itself" to tag array
    # if $name is zplug repository
    if [[ $name == "zplug/zplug" ]]; then
        re_tags="as:itself"
    fi

    # Reconstruct the tag information
    for tag in "${tags[@]}"
    do
        key=${${(s.:.)tag}[1]}
        val=${${(s.:.)tag}[2]}

        if (( $+_zplug_tags[$key] )); then
            case $key in
                "of" | "file" | "commit" | "do")
                    # DEPRECATED: old tags
                    __zplug::core::v1::tags "$key"
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

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    for key in "${(k)zplugs[@]}"
    do
        if [[ $key =~ ^$name@*$ ]] && (( $max < $#key )); then
            max=$#key
            name="${key}@"
        fi
    done

    echo "$name"
}
