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
} &>/dev/null

before_each() {
    source "$ZPLUG_ROOT/test/_helpers/mock.zsh"
    create_mock_plugin "foo/bar"
    init_mock_repos "foo/bar"
}

after_each() {
    rm -rf $ZPLUG_HOME/repos/**/.git(N-/)
}

describe "__check__"
    it "unknown option"
        expect="--unknown: Unknown option"
        actual="$(__check__ --unknown 2>&1)"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.false $status_code
    end

    it "check returns true"
        before_each
        __add__ "foo/bar"
        __check__ "foo/bar"
        status_code=$status
        assert.true $status_code
        after_each
    end

    it "check returns false"
        zplugs=()
        __check__ "foo/bar" &>/dev/null
        status_code=$status
        assert.false $status_code
    end

    it "check returns false with verbose message"
        zplugs=()
        expect="- foo/bar: not installed"
        actual="$(__check__ --verbose "foo/bar" 2>&1)"
        status_code=$status
        assert.equals "$expect" "$(perl -pe 's/\x1b\[[0-9;]*m//g' <<<"$actual")"
        assert.false $status_code
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset expects actuals
    unset status_code
} &>/dev/null
