#!/bin/zsh

[[ -z $ZPLUG_ROOT ]] && return 1

init_mock_repos() {
    local name
    for name in "$@"
    do
        name="$ZPLUG_ROOT/test/_fixtures/repos/$name"
        git -C "$name" init --quiet
        git -C "$name" config user.email "git@zplug"
        git -C "$name" config user.name "zplug"
        git -C "$name" add -A >/dev/null
        git -C "$name" commit -m "$name" >/dev/null
    done
}
