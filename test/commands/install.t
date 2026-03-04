#!/usr/bin/env zsh

source "$ZPLUG_ROOT/test/helper.zsh"
source "$ZPLUG_ROOT/test/fixtures/setup.zsh"

# Set up fixture repos
setup_fixture_repo "test-user/test-plugin"

T_SUB "install clones plugin to ZPLUG_REPOS" ((
    zplugs=()
    zplug "test-user/test-plugin"
    _setup_fixture_url_override  # must be after zplug add

    zplug install 2>/dev/null

    t_directory "$ZPLUG_REPOS/test-user/test-plugin" \
        "plugin directory exists after install"
))

T_SUB "install creates plugin file in cloned repo" ((
    zplugs=()
    zplug "test-user/test-plugin"
    _setup_fixture_url_override

    zplug install 2>/dev/null

    t_file "$ZPLUG_REPOS/test-user/test-plugin/test-plugin.plugin.zsh" \
        "plugin file exists in cloned repo"
))

T_SUB "check returns 0 after install" ((
    zplugs=()
    zplug "test-user/test-plugin"
    _setup_fixture_url_override

    zplug install 2>/dev/null
    zplug check "test-user/test-plugin" 2>/dev/null

    t_is $status 0 "check succeeds after install"
))

T_SUB "install skips already installed plugin" ((
    zplugs=()
    zplug "test-user/test-plugin"
    _setup_fixture_url_override

    zplug install 2>/dev/null
    zplug install 2>/dev/null

    t_directory "$ZPLUG_REPOS/test-user/test-plugin" \
        "plugin directory still exists"
))

T_SUB "install skips plugin with false if condition" ((
    zplugs=()
    zplug "test-user/test-plugin", if:"false"
    _setup_fixture_url_override

    zplug install 2>/dev/null

    [[ ! -d "$ZPLUG_REPOS/test-user/test-plugin" ]]
    t_ok $? "plugin with false if-condition is not installed"
))

_cleanup_fixtures
