#!/usr/bin/env zsh

: before
{
    source "$ZPLUG_ROOT/init.zsh"
    source "$ZPLUG_ROOT/test/.helpers/mock.zsh"

    export ZPLUG_HOME="$ZPLUG_ROOT/test/.fixtures"
    unset ZPLUG_LOADFILE

    local expect actual
}

describe "__check__"
    it "Unknown option"
        expect="[zplug] --unknown: Unknown option"
        actual="$(zplug check --unknown 2>&1)"
        assert.false $status
        assert.equals "$expect" "$actual"
    end

    it "check command returns true"
        mock_as_plugin "foo/foo"
        zplug check "foo/foo"
        assert.true $status
    end

    it "check command returns true (no args)"
        zplug check
        assert.true $status
    end

    # Remove foo
    mock_remove "foo/foo"

    it "check command returns false"
        zplug check "foo/foo"
        assert.false $status
    end

    it "check command returns false (no args)"
        zplug check
        assert.false $status
    end
end

: after
{
    zplugs=()
    unset expect actual
}
