__zplug::job::message::running()
{
    local spinner="$1" message="$2" repo="$3"

    builtin printf " $fg[white]%s$reset_color  %s  %s\n" \
        "$spinner" \
        ${(r,20,):-"$message"} \
        "$repo"
}

__zplug::job::message::green()
{
    local key value
    local spinner repo message hook color="white"

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
    local message="$1" repo="$2"

    builtin printf " $fg[white]\U2714$reset_color  %s  %s\n" \
        ${(r,20,):-"$message"} \
        "$repo"
}

__zplug::job::message::zombie()
{
    local message="$1" repo="$2"

    printf " $fg_bold[red]\U2718$reset_color  $fg[red]%s$reset_color  %s\n" \
        ${(r,20,):-"$message"} \
        "$repo"
}

__zplug::job::message::waiting()
{
    local message="$1" repo="$2"

    printf " $fg_bold[yellow]\U279C$reset_color  $fg[yellow]%s$reset_color  %s\n" \
        ${(r,20,):-"$message"} \
        "$repo"
}

__zplug::job::message::failure_cancel()
{
    local message="$1" repo="$2"

    builtin printf " $fg_bold[red]\U2718$reset_color  $fg[red]%s$reset_color  %s" \
        ${(r,20,):-"$message"} \
        "$repo"
    builtin printf " --> hook-build: $fg[red]cancel$reset_color\n"
}

###############################################################################

__zplug::job::message::failed_to_install_with_hook()
{
    local repo="$1"

    printf " $fg_bold[red]\U2718$reset_color  $fg[red]%s$reset_color  %s --> hook-build: $fg[red]cancel$reset_color\n" \
        ${(r,20,):-"Failed to install"} \
        "$repo"
}

__zplug::job::message::installed_with_hook_spinning()
{
    local \
        spinner="$1" \
        repo="$2" \
        subspinner="$3"

    printf " $fg_bold[white]%s$reset_color  $fg[green]%s$reset_color  %s --> hook-build: %s\n" \
        "$spinner" \
        ${(r,20,):-"Installed!"} \
        "$repo" \
        "$subspinner"
}

__zplug::job::message::installed_with_hook_failure()
{
    local repo="$1"

    printf " $fg_bold[white]\U2714$reset_color  $fg[green]%s$reset_color  %s --> hook-build: $fg[red]failure$reset_color\n" \
        ${(r,20,):-"Installed!"} \
        "$repo"
}

__zplug::job::message::installed_with_hook_timeout()
{
    local repo="$1"

    printf " $fg_bold[white]\U2714$reset_color  $fg[green]%s$reset_color  %s --> hook-build: $fg[yellow]timeout$reset_color\n" \
        ${(r,20,):-"Installed!"} \
        "$repo"
}

__zplug::job::message::installed_with_hook_success()
{
    local repo="$1"

    printf " $fg_bold[white]\U2714$reset_color  $fg[green]%s$reset_color  %s --> hook-build: $fg[green]success$reset_color\n" \
        ${(r,20,):-"Installed!"} \
        "$repo"
}

__zplug::job::message::updated_with_hook_spinning()
{
    local \
        spinner="$1" \
        repo="$2" \
        subspinner="$3"

    printf " $fg_bold[white]%s$reset_color  $fg[green]%s$reset_color  %s --> hook-build: %s\n" \
        "$spinner" \
        ${(r,20,):-"Updated!"} \
        "$repo" \
        "$subspinner"
}

__zplug::job::message::updated_with_hook_failure()
{
    local repo="$1"

    printf " $fg_bold[white]\U2714$reset_color  $fg[green]%s$reset_color  %s --> hook-build: $fg[red]failure$reset_color\n" \
        ${(r,20,):-"Updated!"} \
        "$repo"
}

__zplug::job::message::updated_with_hook_timeout()
{
    local repo="$1"

    printf " $fg_bold[white]\U2714$reset_color  $fg[green]%s$reset_color  %s --> hook-build: $fg[yellow]timeout$reset_color\n" \
        ${(r,20,):-"Updated!"} \
        "$repo"
}

__zplug::job::message::updated_with_hook_success()
{
    local repo="$1"

    printf " $fg_bold[white]\U2714$reset_color  $fg[green]%s$reset_color  %s --> hook-build: $fg[green]success$reset_color\n" \
        ${(r,20,):-"Updated!"} \
        "$repo"
}
