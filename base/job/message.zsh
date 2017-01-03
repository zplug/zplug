__zplug::job::message::spinning()
{
    local repo="$1" message="$2" spinner="$3"
    builtin printf " $fg[white]%s$reset_color  %s  %s\n" \
        "$spinner" \
        ${(r,20,):-"$message"} \
        "$repo"
}

__zplug::job::message::green()
{
    local repo="$1" message="$2" spinner="$3" hook="$4"
    local color=white

    case "$hook" in
        success) color=green  ;;
        failure) color=red    ;;
        timeout) color=yellow ;;
        cancel)  color=red    ;;
    esac

    builtin printf " $fg_bold[white]${spinner:-\U2714}$reset_color  $fg[green]%s$reset_color  %s" \
        ${(r,20,):-"$message"} \
        "$repo"

    if [[ -n $hook ]]; then
        builtin printf " --> hook-build: $fg[$color]%s$reset_color\n" "$hook"
    else
        builtin printf "\n"
    fi
}

__zplug::job::message::white()
{
    local repo="$1" message="$2"
    builtin printf " $fg[white]\U2714$reset_color  %s  %s\n" \
        ${(r,20,):-"$message"} \
        "$repo"
}

__zplug::job::message::red()
{
    local repo="$1" message="$2"
    builtin printf " $fg_bold[red]\U2718$reset_color  $fg[red]%s$reset_color  %s\n" \
        ${(r,20,):-"$message"} \
        "$repo"
}

__zplug::job::message::yellow()
{
    local repo="$1" message="$2"
    builtin printf " $fg_bold[yellow]\U279C$reset_color  $fg[yellow]%s$reset_color  %s\n" \
        ${(r,20,):-"$message"} \
        "$repo"
}
