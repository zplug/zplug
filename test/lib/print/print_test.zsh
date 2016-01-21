#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/lib/print/print.zsh
    local -A zplugs
    local    expect actual
    local -i status_code
} &>/dev/null

describe "lib/init.zsh"
    it "_ZPLUG_LIB_CALLED"
        (( $+_ZPLUG_LIB_CALLED ))
        assert.true $status
    end

    it "__import"
        expect="die"
        actual="$(__die "die\n" 2>&1)"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.true $status_code
    end

    it "__put"
        expect="put"
        actual="$(__put "put\n")"
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
