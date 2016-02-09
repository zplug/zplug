#!/bin/zsh

__import "core/git"
__import "print/print"

__get_latest_releases() {
    local repo curl
    local url_format

    repo="${1:?}"

    url_format="https://github.com/$repo/releases/latest"
    if (( $+commands[curl] )); then
        curl="curl -fsSL"
    elif (( $+commands[wget] )); then
        curl="wget -qO -"
    fi

    eval "$curl $url_format" 2>/dev/null \
        | grep -o '/'"$repo"'/releases/download/[^"]*' \
        | awk -F/ '{print $6}' \
        | sort \
        | uniq
}

__get_state_releases() {
    local state
    local name="${1:?}"
    local dir="${2:?}"
    local url="https://github.com/$name/releases"

    if [[ "$(__get_latest_releases "$name")" == "$(cat "$dir/INDEX")" ]]; then
        state="up to date"
    else
        state="local out of date"
    fi

    case "$state" in
        "local out of date")
            state="${fg[red]}${state}${reset_color}"
            ;;
        "up to date")
            state="${fg[green]}${state}${reset_color}"
            ;;
    esac
    __put "($state) '${url:-?}'\n"
}
