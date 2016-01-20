#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/autoload/init.zsh
    source $ZPLUG_ROOT/autoload/autoload.zsh
    source $ZPLUG_ROOT/zplug.zsh
    export ZPLUG_HOME=$ZPLUG_ROOT/test/_fixtures
    local -A zplugs
    local    expect actual
    local -i status_code
    myfzf() { head -n 1; }
} &>/dev/null

before_each() {
    source $ZPLUG_ROOT/test/_helpers/create_mock_repos.zsh
    source $ZPLUG_ROOT/test/_helpers/init_mock_repos.zsh
    create_mock_plugin "foo/bar"
    init_mock_repos "foo/bar"
}

after_each() {
    rm -rf $ZPLUG_HOME/repos/**/.git(N-/)
}

describe "__clean__"
    it "unknown option"
        expect="--unknown: Unknown option"
        actual="$(zplug clean --unknown 2>&1)"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.false $status_code
    end

    it "--select option"
        before_each
        __add__ "foo/bar"
        ZPLUG_FILTER="myfzf"
        expect=""
        actual="$(zplug clean --select 2>&1)"
        zplug clean --select 2>&1
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.true $status_code
        after_each
    end

    it "--force option"
        before_each
        __add__ "foo/bar"
        expect="Removed"
        actual="$(zplug clean --force "foo/bar" 2>&1)"
        status_code=$status
        assert.match "$expect" "$actual"
        assert.true $status_code
        after_each
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset expects actuals
    unset status_code
} &>/dev/null
