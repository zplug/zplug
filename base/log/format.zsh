__zplug::log::format::with_json()
{
    local -i i=1
    local    level="${1:-"INFO"}" message="$2"
    local    is_message_json=false

    # Spit out to JSON
    builtin printf '{'
    builtin printf '"pid":%d,' "$$"
    builtin printf '"shlvl":%d,' "$SHLVL"
    builtin printf '"level":"%s",' "$level"
    builtin printf '"dir":"%s",' "$PWD"
    builtin printf '"message":'
    if $is_message_json; then
        builtin printf "$message"
    else
        builtin printf "$message" \
            | __zplug::utils::ansi::remove \
            | __zplug::utils::shell::json_escape \
            | tr -d '\n'
    fi
    builtin printf ','
    builtin printf '"trace":['
    for ((i = 1; i < $#functrace; i++))
    do
        builtin printf '"%s",' "$functrace[$i]"
    done
    builtin printf '"%s"' "$functrace[$#functrace]"
    builtin printf "],"
    builtin printf '"date":"%s"' "$(strftime "%FT%T%z" $EPOCHSECONDS)"
    builtin printf "}\n"
}
