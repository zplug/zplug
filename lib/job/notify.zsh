#!/bin/zsh

__import "core/core"
__import "print/print"

__notifier_for_linux() {
    return 1
}

__notifier_for_osx() {
    local text title sound

    text="${1:?}"
    title="${2:-zplug}"
    sound="${3:-default}"

    if (( $+commands[osascript] )) && __osx_version 10.9; then
        osascript -e \
            "display notification "${(qqq)text}" with title "${(qqq)title}" sound name \"$sound\""
    elif (( $+commands[terminal-notifier] )); then
        terminal-notifier \
            -title "$title" \
            -message "$text" \
            -sound "$sound"
    else
        __die "[zplug] A notifier is not available on this system.\n"
        __die "        Please install terminal-notifier or upgrade your OS X.\n"
        return 1
    fi
}

__notifier() {
    if __is_osx; then
        __notifier_for_osx "$@"
        return $status
    elif __is_linux; then
        __notifier_for_linux "$@"
        return $status
    fi
}

__check_zplug_update() (
    local -i cnt
    local    msg rev state commit

    builtin cd -q "$ZPLUG_HOME/repos/b4b4r07/zplug" || return 1

    # Fetch from remote
    git fetch &>/dev/null

    # Get the revision hash and commit message
    git -c pager.log=false \
        log --oneline -1 \
        origin/HEAD \
        | read rev msg

    git status --branch --short \
        | head -1 \
        | perl -pe 's/^.*?\[(.*?)\].*$/$1/' \
        | read state cnt

    case $cnt in
        1)
            commit="commit"
            ;&
        *)
            __notifier \
                "[$rev] \"$msg\" ($state $cnt ${commit:-commits})" \
                'Update "b4b4r07/zplug"'
            ;;
    esac
)
