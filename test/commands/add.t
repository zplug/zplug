#!/usr/bin/env zsh

source "$ZPLUG_ROOT/test/helper.zsh"

T_SUB "add registers plugin in zplugs" ((
    zplugs=()
    zplug "zsh-users/zsh-syntax-highlighting"

    (( $+zplugs[zsh-users/zsh-syntax-highlighting] ))
    t_ok $? "plugin is registered in zplugs"
))

T_SUB "add with tags stores tag values" ((
    zplugs=()
    zplug "zsh-users/zsh-syntax-highlighting", as:plugin, from:github

    local entry="${zplugs[zsh-users/zsh-syntax-highlighting]}"
    t_present "$entry" "plugin entry exists with tags"

    [[ "$entry" == *as:plugin* ]]
    t_ok $? "as:plugin is stored"

    [[ "$entry" == *from:github* ]]
    t_ok $? "from:github is stored"
))

T_SUB "add rejects invalid package name" ((
    zplugs=()
    zplug "invalid-name-no-slash" 2>/dev/null
    t_isnt $status 0 "returns non-zero for invalid name"

    (( ! $+zplugs[invalid-name-no-slash] ))
    t_ok $? "invalid name is not added to zplugs"
))

T_SUB "add rejects invalid tag name" ((
    zplugs=()
    zplug "user/repo", nonexistent:value 2>/dev/null
    t_isnt $status 0 "returns non-zero for invalid tag"
))

T_SUB "add handles duplicate names with at-sign suffix" ((
    zplugs=()
    zplug "plugins/git", from:oh-my-zsh
    zplug "plugins/git", from:prezto

    local -i count=0
    local key
    for key in "${(k)zplugs[@]}"; do
        [[ "$key" == plugins/git* ]] && (( count++ ))
    done
    t_ge $count 2 "both entries exist (possibly with @ suffix)"
))

T_SUB "add multiple plugins independently" ((
    zplugs=()
    zplug "user/plugin-a"
    zplug "user/plugin-b"
    zplug "user/plugin-c"

    (( $+zplugs[user/plugin-a] ))
    t_ok $? "plugin-a registered"

    (( $+zplugs[user/plugin-b] ))
    t_ok $? "plugin-b registered"

    (( $+zplugs[user/plugin-c] ))
    t_ok $? "plugin-c registered"
))
