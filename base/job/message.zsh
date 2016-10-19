__zplug::job::message::installing()
{
    local \
        spinner="$1" \
        repo="$2"

    printf " $fg[white]%s$reset_color  %s  %s\n" \
        "$spinner" \
        ${(r,20,):-"Installing..."} \
        "$repo"
}

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

__zplug::job::message::installed()
{
    local repo="$1"

    printf " $fg_bold[white]\U2714$reset_color  $fg[green]%s$reset_color  %s\n" \
        ${(r,20,):-"Installed!"} \
        "$repo"
}

__zplug::job::message::failed_to_install()
{
    local repo="$1"

    printf " $fg_bold[red]\U2718$reset_color  $fg[red]%s$reset_color  %s\n" \
        ${(r,20,):-"Failed to install"} \
        "$repo"
}

__zplug::job::message::already_installed()
{
    local repo="$1"

    printf " $fg[yellow]\U2714  %s$reset_color  %s\n" \
        ${(r,20,):-"Already installed"} \
        "$repo"
}

__zplug::job::message::skipped_due_to_frozen_tag()
{
    local repo="$1"

    printf " $fg[blue]\U279C  %s$reset_color  %s\n" \
        ${(r,20,):-"Frozen repo"} \
        "$repo"
}

__zplug::job::message::skipped_due_to_if_tag()
{
    local repo="$1"

    printf " $fg[yellow]\U279C  %s$reset_color  %s\n" \
        ${(r,20,):-"Skipped due to if"} \
        "$repo"
}

__zplug::job::message::unknown()
{
    local repo="$1"

    printf " $fg_bold[red]\U2718$reset_color  $fg[red]%s$reset_color  %s\n" \
        ${(r,20,):-"Unknown"} \
        "$repo"
}

__zplug::job::message::fetching()
{
    local \
        spinner="$1" \
        repo="$2"

    printf " $fg[white]%s$reset_color  %s  %s\n" \
        "$spinner" \
        ${(r,20,):-"Fetching..."} \
        "$repo"
}

__zplug::job::message::local_out_of_date()
{
    local repo="$1"

    printf " $fg_bold[red]\U2718$reset_color  $fg[red]%s$reset_color  %s\n" \
        ${(r,20,):-"Local out of date"} \
        "$repo"
}

__zplug::job::message::not_on_any_branch()
{
    local repo="$1"

    printf " $fg_bold[red]\U2718$reset_color  $fg[white]%s$reset_color  %s\n" \
        ${(r,20,):-"Not on any branch"} \
        "$repo"
}

__zplug::job::message::not_git_repo()
{
    local repo="$1"

    printf " $fg_bold[red]\U2718$reset_color  $fg[white]%s$reset_color  %s\n" \
        ${(r,20,):-"Not git repo"} \
        "$repo"
}

__zplug::job::message::repo_not_found()
{
    local repo="$1"

    printf " $fg_bold[red]\U2718$reset_color  $fg[red]%s$reset_color  %s\n" \
        ${(r,20,):-"Not found"} \
        "$repo"
}
__zplug::job::message::skip_local_repo()
{
    local repo="$1"

    printf " $fg_bold[yellow]\U279C$reset_color  $fg[yellow]%s$reset_color  %s\n" \
        ${(r,20,):-"Skip local repo"} \
        "$repo"
}

__zplug::job::message::updating()
{
    local \
        spinner="$1" \
        repo="$2"

    printf " $fg[white]%s$reset_color  %s  %s\n" \
        "$spinner" \
        ${(r,20,):-"Updating..."} \
        "$repo"
}

__zplug::job::message::failed_to_update_with_hook()
{
    local repo="$1"

    printf " $fg_bold[red]\U2718$reset_color  $fg[red]%s$reset_color  %s --> hook-build: $fg[red]cancel$reset_color\n" \
        ${(r,20,):-"Failed to update"} \
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

__zplug::job::message::updated()
{
    local repo="$1"

    printf " $fg_bold[white]\U2714$reset_color  $fg[green]%s$reset_color  %s\n" \
        ${(r,20,):-"Updated!"} \
        "$repo"
}

__zplug::job::message::failed_to_update()
{
    local repo="$1"

    printf " $fg_bold[red]\U2718$reset_color  $fg[red]%s$reset_color  %s\n" \
        ${(r,20,):-"Failed to update"} \
        "$repo"
}

__zplug::job::message::up_to_date()
{
    local repo="$1"

    printf " $fg[white]\U2714$reset_color  %s  %s\n" \
        ${(r,20,):-"Up-to-date"} \
        "$repo"
}

__zplug::job::message::local_repo()
{
    local repo="$1"

    printf " $fg[yellow]\U279C$reset_color  $fg[yellow]%s$reset_color  %s\n" \
        ${(r,20,):-"Local repository"} \
        "$repo"
}
