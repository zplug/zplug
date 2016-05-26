#!/usr/bin/env zsh

: before
{
    source "$ZPLUG_ROOT/init.zsh"
    source "$ZPLUG_ROOT/test/.helpers/mock.zsh"
    source "$ZPLUG_ROOT/test/.helpers/helper.zsh"

    export ZPLUG_HOME="$ZPLUG_ROOT/test/.fixtures"

    local expect actual
}

describe "__list__"
    it "Unknown option"
        expect="[zplug] --unknown: Unknown option"
        actual="$(zplug check --unknown 2>&1)"
        assert.false $status
        assert.equals "$expect" "$actual"
    end

    it ""
        zplugs=()
        zplug "foo/foo"
        expect="foo/foo  =>  nil"
        actual="$(zplug list | unansi)"
        assert.true $status
        assert.equals "$expect" "$actual"
    end

    it ""
        zplugs=()
        zplug "foo/foo"
        expect="foo/foo  =>  nil"
        actual="$(zplug list foo | unansi)"
        assert.true $status
        assert.equals "$expect" "$actual"
    end

    it ""
        zplugs=()
        zplug "foo/foo"
        expect="foo/foo  =>  nil"
        actual="$(zplug list f | unansi)"
        assert.true $status
        assert.equals "$expect" "$actual"
    end

    it ""
        zplugs=()
        zplug "foo/foo"
        expect="foo/foo  =>  nil"
        actual="$(zplug list f | unansi)"
        assert.true $status
        assert.equals "$expect" "$actual"
    end

    it ""
        zplugs=()
        zplug "foo/foo"
        expect="bar  =>  NO SUCH PACKAGE"
        actual="$(zplug list bar | unansi)"
        assert.true $status
        assert.equals "$expect" "$actual"
    end
end

: after
{
    zplugs=()
    unset expect actual
}
