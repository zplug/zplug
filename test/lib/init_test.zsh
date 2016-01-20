#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/lib/init.zsh
    local -A zplugs
    local    expect actual
    local -i status_code
} &>/dev/null

describe "lib/init.zsh"
    it "__import 1"
        expect=""
        actual="$(__import --debug "a")"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.false $status_code
    end

    it "__import 2"
        expect="$ZPLUG_ROOT/lib/a/b.zsh"
        actual="$(__import --debug "a/b")"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.true $status_code
    end

    it "__import 2"
        __import --debug "a/b" >/dev/null
        (( $ZPLUG_LIBS[(I)$ZPLUG_ROOT/lib/a/b.zsh] ))
        assert.true $status
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset expects actuals
    unset status_code
} &>/dev/null
