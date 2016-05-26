#!/usr/bin/env zsh

: before
{
    source "$ZPLUG_ROOT/init.zsh"
    source "$ZPLUG_ROOT/test/.helpers/mock.zsh"

    export ZPLUG_HOME="$ZPLUG_ROOT/test/.fixtures"

    local expect actual
}

describe "__status__"
    it "Unknown option"
        expect="[zplug] --unknown: Unknown option"
        actual="$(zplug check --unknown 2>&1)"
        assert.false $status
        assert.equals "$expect" "$actual"
    end
end

: after
{
    zplugs=()
    unset expect actual
}
