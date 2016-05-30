#!/usr/bin/env zsh

: before
{
    source "$ZPLUG_ROOT/init.zsh"
    source "$ZPLUG_ROOT/test/.helpers/mock.zsh"

    export ZPLUG_HOME="$ZPLUG_ROOT/test/.fixtures"

    local expect actual
}

describe "__help__"
    it ""
        expect="$_ZPLUG_VERSION"
        actual="$(zplug --version)"
        assert.true $status
        assert.equals "$expect" "$actual"
    end
end

: after
{
    zplugs=()
    unset expect actual
}
