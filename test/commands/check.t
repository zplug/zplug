#!/usr/bin/env zsh

source "$ZPLUG_ROOT/test/helper.zsh"

T_SUB "check returns non-zero when plugin is not installed" ((
    zplugs=()
    zplug "zsh-users/zsh-syntax-highlighting"

    zplug check "zsh-users/zsh-syntax-highlighting" 2>/dev/null
    t_isnt $status 0 "uninstalled plugin returns non-zero"
))

T_SUB "check returns non-zero when no plugins installed" ((
    zplugs=()
    zplug "user/plugin-a"
    zplug "user/plugin-b"

    zplug check 2>/dev/null
    t_isnt $status 0 "check all returns non-zero when none installed"
))

T_SUB "check with --verbose produces output" ((
    zplugs=()
    zplug "zsh-users/zsh-syntax-highlighting"

    local output
    output="$(zplug check --verbose 2>&1)"
    t_present "$output" "verbose mode produces output"
))

T_SUB "check with --debug outputs repo names" ((
    zplugs=()
    zplug "zsh-users/zsh-syntax-highlighting"

    local output
    output="$(zplug check --debug 2>/dev/null)"
    t_present "$output" "debug mode outputs repo names"

    [[ "$output" == *zsh-users/zsh-syntax-highlighting* ]]
    t_ok $? "debug output contains the uninstalled repo name"
))

T_SUB "check skips plugins with false if condition" ((
    zplugs=()
    zplug "user/conditional-plugin", if:"false"

    # Plugin with if:false should be skipped, not counted as missing
    zplug check "user/conditional-plugin" 2>/dev/null
    # Skipped plugins return success (not counted as not-installed)
    t_is $status 0 "plugin with false if-condition is skipped"
))

T_SUB "check succeeds for installed plugin" ((
    zplugs=()
    local repo="fake-user/fake-plugin"
    zplug "$repo"

    # Simulate installed state by creating the directory with a git repo
    mkdir -p "$ZPLUG_REPOS/$repo"
    git -C "$ZPLUG_REPOS/$repo" init --quiet 2>/dev/null
    git -C "$ZPLUG_REPOS/$repo" commit --allow-empty -m "init" --quiet 2>/dev/null

    zplug check "$repo" 2>/dev/null
    t_is $status 0 "check returns 0 for installed plugin"
))
