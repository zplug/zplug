__zplug::core::tags::get()
{
    __zplug::core::core::get_interfaces \
        "tags" \
        "$argv[@]"
}

__zplug::core::tags::parse()
{
    local    arg="$1" tag val
    local -A tags
    local -a pairs

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::core::tags::get
    tags=( "${reply[@]}" )

    pairs=("name" "$arg")

    for tag in "${(k)tags[@]}"
    do
        val="$(
        __zplug::core::core::run_interfaces \
            "$tag" \
            "$arg"
        )"
        pairs+=("$tag" "$val")
    done

    reply=( "$pairs[@]" )
}
