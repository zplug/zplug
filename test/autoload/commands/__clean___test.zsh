#!/usr/bin/env zsh

: before
{
    source "$ZPLUG_ROOT/init.zsh"
    source "$ZPLUG_ROOT/test/.helpers/mock.zsh"

    export ZPLUG_HOME="$ZPLUG_ROOT/test/.fixtures"

    local expect actual
}

describe "__clean__"
    it "Unknown option"
        expect="[zplug] --unknown: Unknown option"
        actual="$(zplug check --unknown 2>&1)"
        assert.false $status
        assert.equals "$expect" "$actual"
    end

    it "exist but clean"
        mock_as_plugin "foo/foo"
        expect="Removed '$ZPLUG_REPOS/foo/foo' "
        actual="$(zplug clean --force "foo/foo")"
        assert.true $status
        assert.equals "$expect" "$actual"
    end

    it "non-existing plugin"
        mock_as_plugin "bar/bar"
        zplugs=()
        expect="Removed '$ZPLUG_REPOS/bar/bar' "
        actual="$(zplug clean --force)"
        assert.true $status
        assert.equals "$expect" "$actual"
   end

    it "non-registerd plugin"
        expect="[zplug] bar/bar: no such package"
        actual="$(zplug clean --force "bar/bar" 2>&1)"
        assert.false $status
        assert.equals "$expect" "$actual"
   end
end

: after
{
    zplugs=()
    unset expect actual
}
