__zplug::log::format::with_json()
{
    local -i i=1
    local    level="${1:-"INFO"}" message
    local    is_message_json=false

    while (( $#argv > 0 ))
    do
        case "$argv[1]" in
            --message)
                message="$argv[2]"; shift
                ;;
            --level)
                level="$argv[2]"; shift
                ;;
            --message-json)
                is_message_json=true
                ;;
        esac
        shift
    done

    # Spit out to JSON
    printf '{'
    printf '"pid":%d,' "$$"
    printf '"shlvl":%d,' "$SHLVL"
    printf '"level":"%s",' "$level"
    printf '"dir":"%s",' "$PWD"
    printf '"message":'
    if $is_message_json; then
        printf "$message"
    else
        printf "$message" \
            | __zplug::utils::ansi::remove \
            | __zplug::utils::shell::json_escape \
            | tr -d '\n'
    fi
    printf ','
    printf '"trace":['
    for ((i = 1; i < $#functrace; i++))
    do
        printf '"%s",' "$functrace[$i]"
    done
    printf '"%s"' "$functrace[$#functrace]"
    printf "],"
    printf '"date":"%s"' "$(strftime "%FT%T%z" $EPOCHSECONDS)"
    printf "}\n"
}
