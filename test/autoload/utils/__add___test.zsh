#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/autoload/init.zsh
    source $ZPLUG_ROOT/autoload/autoload.zsh
    source $ZPLUG_ROOT/init.zsh
    export ZPLUG_HOME=$ZPLUG_ROOT/test/_fixtures
    local -A zplugs
    local    expect actual
    local -i status_code
    myfzf() { head -n 1; }
    __is_cli() { true; }
} &>/dev/null

before_each() {
    source "$ZPLUG_ROOT/test/_helpers/mock.zsh"
    create_mock_plugin "foo/bar"
    init_mock_repos "foo/bar"
}

after_each() {
    rm -rf "$ZPLUG_HOME"/repos/**/.git(N-/)
    rm -rf "$ZPLUG_HOME/error.log"
}

describe "__add__"
end

: after
{
    unset zplugs
    unset expect actual
    unset status_code
}
