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
    touch $ZPLUG_HOME/zcompdump
} &>/dev/null

describe "__clear__"
    it "--force option"
        expect="Removed"
        actual="$(zplug clear --force 2>&1)"
        status_code=$status
        assert.match "$expect" "$actual"
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
