__zplug::io::log::with_json()
{
    # Variables for error report
    # - $funcfiletrace[@]
    # - $funcsourcetrace[@]
    # - $funcstack[@]
    # - $functrace[@]

    local -i i
    local    level="${1:-"ERROR"}"
    local    message="$(<&0)"

    if [[ -z $message ]]; then
        return 0
    fi

    # Spit out to JSON
    printf '{'
    printf '"pid": %d,' "$$"
    printf '"shlvl": %d,' "$SHLVL"
    printf '"level": "%s",' "$level"
    printf '"dir": "%s",' "$PWD"
    printf '"message": '
    printf "$message" | __zplug::utils::shell::json_escape
    printf ','
    printf '"trace": ['
    for ((i = 1; i < $#functrace; i++))
    do
        printf '"%s",' "$functrace[$i]"
    done
    printf '"%s"' "$functrace[$#functrace]"
    printf "],"
    printf '"date": "%s"' "$(strftime "%FT%T%z" $EPOCHSECONDS)"
    printf "}\n"
}

__zplug::io::log::level()
{
    local    level="${(U)1:-"INFO"}" log_level
    local -i part="${2:-2}"
    local -A syslog_code

    # https://tools.ietf.org/html/rfc5424
    syslog_code=(
    ''       '0:Emergency:system is unusable'
    ''       '1:Alert:action must be taken immediately'
    ''       '2:Critical:critical conditions'
    'ERROR'  '3:Error:error conditions'
    'WARN'   '4:Warning:warning conditions'
    ''       '5:Notice:normal but significant condition'
    'INFO'   '6:Informational:informational messages'
    'DEBUG'  '7:Debug:debug-level messages'
    )

    if (( ! $+syslog_code[$level] )); then
        level="INFO"
    fi
    if (( $part > 3 )); then
        part=0
    fi

    echo "$syslog_code[$level]" \
        | awk -F: '{print $'"$part"'}' \
        | read log_level

    echo "${(U)log_level}"
}

__zplug::io::log::new()
{
    local    key value
    local    level="WARN"
    local -a args

    __zplug::utils::shell::getopts "$argv[@]" \
        | while read key value; \
    do
        case "$key" in
            level)
                level="$value"
                ;;
            _)
                args+=( "$value" )
        esac
    done
    level="$(__zplug::io::log::level "$level")"

    echo "$args[@]" \
        | __zplug::io::log::with_json "$level" \
        | >>|"$ZPLUG_ERROR_LOG"
}

__zplug::io::log::capture()
{
    __zplug::io::log::with_json "ERROR" \
        | >>|"$ZPLUG_ERROR_LOG"
}

__zplug::io::log::capture_error()
{
    __zplug::io::log::with_json "ERROR" \
        | >>|"$_zplug_log[error]"
}

__zplug::io::log::capture_execution()
{
    __zplug::io::log::with_json "DEBUG" \
        | >>|"$_zplug_log[execution]"
}

__zplug::io::log::info()
{
    __zplug::io::log::new \
        --level="INFO" \
        -- \
        "$argv[@]"
}

__zplug::io::log::warn()
{
    __zplug::io::log::new \
        --level="WARN" \
        -- \
        "$argv[@]"
}

__zplug::io::log::error()
{
    __zplug::io::log::new \
        --level="ERROR" \
        -- \
        "$argv[@]"
}
