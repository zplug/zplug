#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/autoload/init.zsh
    source $ZPLUG_ROOT/autoload/autoload.zsh
    source $ZPLUG_ROOT/zplug.zsh
    local -A zplugs
    local    expect actual
    local -i status_code
} &>/dev/null

describe "__version__"
    it "version"
        expect="$(cat $ZPLUG_ROOT/doc/VERSION)"
        actual="$(zplug version)"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.true $status_code
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset expects actuals
    unset status_code
} &>/dev/null
