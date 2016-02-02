#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/lib/job/spinner.zsh
    source $ZPLUG_ROOT/lib/print/print.zsh
    source $ZPLUG_ROOT/autoload/init.zsh
    local -A zplugs
    local    expect actual
    local -i status_code
} &>/dev/null

describe "lib/job/spinner.zsh"
    it "__is_spin returns true"
        __is_spin
        touch "$spin_file"
        assert.true $status
    end

    it "__is_spin returns false"
        rm -f "$spin_file"
        __is_spin
        assert.false $status
    end

    it "__spin_lock"
        __spin_lock
        __is_spin
        assert.true $status
    end

    it "__spin_unlock"
        __spin_unlock
        __is_spin
        assert.false $status
    end

    it "__spinner"
    end

    it "__spinner_echo returns true"
        __spin_lock
        expect="spin"
        actual="$(__spinner_echo "spin")"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.true $status_code
    end

    it "__spinner_echo returns false"
        __spin_unlock
        expect=""
        actual="$(__spinner_echo "spin")"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.false $status_code
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset expects actuals
    unset status_code
} &>/dev/null
