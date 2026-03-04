#!/usr/bin/env zsh

source "$ZPLUG_ROOT/test/helper.zsh"

T_SUB "list shows error when no plugins registered" ((
    zplugs=()

    zplug list 2>/dev/null
    t_isnt $status 0 "returns non-zero when zplugs is empty"
))

T_SUB "list succeeds when plugins are registered" ((
    zplugs=()
    zplug "user/plugin-a"
    zplug "user/plugin-b"

    local output
    output="$(zplug list 2>/dev/null)"
    t_is $status 0 "returns 0 when plugins exist"
))

T_SUB "list output contains registered plugin names" ((
    zplugs=()
    zplug "user/plugin-a"
    zplug "user/plugin-b"

    local output
    output="$(zplug list 2>&1)"

    [[ "$output" == *user/plugin-a* ]]
    t_ok $? "output contains plugin-a"

    [[ "$output" == *user/plugin-b* ]]
    t_ok $? "output contains plugin-b"
))
