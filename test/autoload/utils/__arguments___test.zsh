#!/usr/bin/env zsh

: before
{
    source "$ZPLUG_ROOT/init.zsh"
    source "$ZPLUG_ROOT/test/.helpers/mock.zsh"
    source "$ZPLUG_ROOT/test/.helpers/helper.zsh"

    export ZPLUG_HOME="$ZPLUG_ROOT/test/.fixtures"

    local expect actual
}

describe "__arguments__"
    it ""
        expect="[zplug] foobarbaz: no such command"
        actual="$(zplug foobarbaz 2>&1)"
        assert.false $status
        assert.equals "$expect" "$actual"
    end

    it ""
        zplugs=()
        expect="[zplug] WARNING: You called a zplug command named 'lisa', which does not exist.
        Continuing under the assumption that you meant 'list'.
[zplug] no package managed by zplug"
        actual="$(zplug lisa 2>&1 | unansi)"
        assert.equals "$expect" "$actual"
    end

    it ""
        zplugs=()
        expect="[zplug] 'lost' is not a zplug command. See 'zplug help'.
        Did you mean one of these?
               list
               load"
        actual="$(zplug lost 2>&1)"
        assert.false $status
        assert.equals "$expect" "$actual"
    end
end

: after
{
    zplugs=()
    unset expect actual
}
