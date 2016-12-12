__zplug::job::message::parser()
{
    __zplug::utils::shell::getopts "$argv[@]" \
        | while read key value; \
    do
        case "$key" in
            _)
                ;;
            spinner)
                spinner="$value"
                ;;
            repo)
                repo="$value"
                ;;
            message)
                message="$value"
                ;;
            hook)
                hook="$value"
                case "$hook" in
                    failure)
                        color="red"
                        ;;
                    success)
                        color="green"
                        ;;
                    timeout)
                        color="yellow"
                        ;;
                    cancel)
                        color="red"
                        ;;
                esac
                ;;
        esac
    done
}

__zplug::job::message::running()
{
    local key value
    local spinner repo message hook color="white"
    __zplug::job::message::parser "$argv[@]"

    builtin printf " $fg[white]%s$reset_color  %s  %s\n" \
        "$spinner" \
        ${(r,20,):-"$message"} \
        "$repo"
}

__zplug::job::message::green()
{
    local key value
    local spinner repo message hook color="white"
    __zplug::job::message::parser "$argv[@]"

    builtin printf " $fg_bold[white]${spinner:-\U2714}$reset_color  $fg[green]%s$reset_color  %s" \
        ${(r,20,):-"$message"} \
        "$repo"

    if [[ -n $hook ]]; then
        builtin printf " --> hook-build: $fg[$color]%s$reset_color\n" "$hook"
    else
        builtin printf "\n"
    fi
}

__zplug::job::message::terminated()
{
    local key value
    local spinner repo message hook color="white"
    __zplug::job::message::parser "$argv[@]"

    builtin printf " $fg[white]\U2714$reset_color  %s  %s\n" \
        ${(r,20,):-"$message"} \
        "$repo"
}

__zplug::job::message::red()
{
    local key value
    local spinner repo message hook color="white"
    __zplug::job::message::parser "$argv[@]"

    printf " $fg_bold[red]\U2718$reset_color  $fg[red]%s$reset_color  %s\n" \
        ${(r,20,):-"$message"} \
        "$repo"
}

__zplug::job::message::yellow()
{
    local key value
    local spinner repo message hook color="white"
    __zplug::job::message::parser "$argv[@]"

    printf " $fg_bold[yellow]\U279C$reset_color  $fg[yellow]%s$reset_color  %s\n" \
        ${(r,20,):-"$message"} \
        "$repo"
}
