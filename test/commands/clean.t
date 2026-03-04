#!/usr/bin/env zsh

source "$ZPLUG_ROOT/test/helper.zsh"

T_SUB "clean --force removes unmanaged repo directory" ((
    zplugs=()

    # Create an unmanaged repo directory (not in zplugs)
    local orphan_dir="$ZPLUG_REPOS/orphan-user/orphan-plugin"
    mkdir -p "$orphan_dir"

    zplug clean --force 2>/dev/null

    [[ ! -d "$orphan_dir" ]]
    t_ok $? "unmanaged directory is removed"
))

T_SUB "clean --force does not remove managed repo" ((
    zplugs=()
    local repo="user/managed-plugin"
    zplug "$repo"

    # Create the managed repo directory
    mkdir -p "$ZPLUG_REPOS/$repo"

    zplug clean --force 2>/dev/null

    t_directory "$ZPLUG_REPOS/$repo" "managed directory is preserved"
))

T_SUB "clean --force removes specified repo" ((
    zplugs=()
    local repo="user/to-remove"
    zplug "$repo"

    # Create the repo directory
    mkdir -p "$ZPLUG_REPOS/$repo"

    zplug clean --force "$repo" 2>/dev/null

    [[ ! -d "$ZPLUG_REPOS/$repo" ]]
    t_ok $? "specified directory is removed"
))
