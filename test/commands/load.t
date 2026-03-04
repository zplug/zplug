#!/usr/bin/env zsh

source "$ZPLUG_ROOT/test/helper.zsh"
source "$ZPLUG_ROOT/test/fixtures/setup.zsh"

# Create fixture with a plugin that defines a function
setup_fixture_repo "test-user/test-plugin"
_setup_fixture_url_override

# Pre-install: create the repo content manually for load tests
# (to avoid depending on install working correctly)
_setup_installed_plugin() {
    local repo="$1" plugin_file="$2"
    local dir="$ZPLUG_REPOS/$repo"
    mkdir -p "$dir"
    git -C "$dir" init --quiet 2>/dev/null
    echo "$plugin_file" > "$dir/${repo:t}.plugin.zsh"
    git -C "$dir" add -A 2>/dev/null
    git -C "$dir" commit -m "init" --quiet 2>/dev/null
}

T_SUB "load sources plugin file" ((
    zplugs=()
    _setup_installed_plugin "test-user/load-test" \
        '_zplug_test_loaded=1'

    zplug "test-user/load-test"
    zplug load 2>/dev/null

    t_is "${_zplug_test_loaded:-0}" "1" "plugin file was sourced"
))

T_SUB "load makes function available" ((
    zplugs=()
    _setup_installed_plugin "test-user/func-test" \
        'zplug_test_func() { echo "hello from test"; }'

    zplug "test-user/func-test"
    zplug load 2>/dev/null

    (( $+functions[zplug_test_func] ))
    t_ok $? "function defined by plugin is available"
))

T_SUB "load creates command symlink for as:command" ((
    zplugs=()
    local dir="$ZPLUG_REPOS/test-user/cmd-test"
    mkdir -p "$dir"
    git -C "$dir" init --quiet 2>/dev/null
    echo '#!/bin/sh' > "$dir/cmd-test"
    echo 'echo cmd-test' >> "$dir/cmd-test"
    chmod +x "$dir/cmd-test"
    git -C "$dir" add -A 2>/dev/null
    git -C "$dir" commit -m "init" --quiet 2>/dev/null

    zplug "test-user/cmd-test", as:command
    zplug load 2>/dev/null

    # Check that a symlink or file exists in ZPLUG_BIN
    [[ -e "$ZPLUG_BIN/cmd-test" ]]
    t_ok $? "command symlink exists in ZPLUG_BIN"
))

T_SUB "load adds fpath for plugin with completions" ((
    zplugs=()
    local dir="$ZPLUG_REPOS/test-user/comp-test"
    mkdir -p "$dir"
    git -C "$dir" init --quiet 2>/dev/null
    echo '# plugin' > "$dir/comp-test.plugin.zsh"
    echo '#compdef comp-test' > "$dir/_comp-test"
    git -C "$dir" add -A 2>/dev/null
    git -C "$dir" commit -m "init" --quiet 2>/dev/null

    zplug "test-user/comp-test"
    zplug load 2>/dev/null

    [[ "${fpath[(r)$dir]}" == "$dir" ]]
    t_ok $? "plugin directory added to fpath"
))

_cleanup_fixtures
