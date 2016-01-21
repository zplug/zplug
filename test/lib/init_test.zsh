#!/bin/zsh

: before
{
    source "$ZPLUG_ROOT/lib/init.zsh"
    source "$ZPLUG_ROOT/test/_helpers/mock.zsh"
    local -A zplugs
    local    expect actual
    local -i status_code
} &>/dev/null

after_each() {
    local i
    for i in "$@"
    do
        rm -rf $ZPLUG_ROOT/lib/${i:h}
    done
}

describe "lib/init.zsh"
    it "__import: library not found"
        __import --debug "a/b"
        assert.false $status
        after_each "a/b"
    end

    it "__import: library a/b"
        create_mock_lib "a/b"
        expect="$ZPLUG_ROOT/lib/a/b.zsh"
        actual="$(__import --debug "a/b")"
        status_code=$status
        assert.equals "$expect" "$actual"
        after_each "a/b"
    end

    it "__import: library a/b check variables"
        create_mock_lib "a/b"
        __import --debug "a/b" >/dev/null
        (( $_zplug_lib_called[(I)a/b] ))
        assert.true $status
        after_each "a/b"
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset expects actuals
    unset status_code
} &>/dev/null
