#!/bin/zsh

__import "core/core"

__osx_version() {
    (( $+commands[sw_vers] )) || return 1
    __version_requirement ${${(M)${(@f)"$(sw_vers)"}:#ProductVersion*}[2]} "${@:?}"
    return $status
}

__notify_with_system() {
    (( $+commands[osascript] )) && __osx_version 10.9
}

__notify_with_tools() {
    (( $+commands[terminal-notifier] ))
}

__notifier() {
    local title text sound

    title="$1"
    text="$2"
    sound="${3:-default}"

    if __notify_with_system; then
        osascript -e "display notification \"$text\" with title \"$title\" sound name \"$sound\""
    elif __notify_with_tools; then
        terminal-notifier -title "$title" -message "$text" -sound "$sound"
    else
        __die "notification: not available on this system\n"
        return 1
    fi
}
