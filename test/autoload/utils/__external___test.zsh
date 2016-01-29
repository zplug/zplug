#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/autoload/init.zsh
    source $ZPLUG_ROOT/autoload/autoload.zsh
    source $ZPLUG_ROOT/init.zsh
    export ZPLUG_HOME=$ZPLUG_ROOT/test/_fixtures
    export ZPLUG_EXTERNAL=$ZPLUG_HOME/init.zsh
    local -A zplugs
    local    expect actual
    local -i status_code
} &>/dev/null

after_each() {
    rm -f "$ZPLUG_EXTERNAL"
}

describe "__external__"
    it "__external__ 1"
        __external__
        expect="ZPLUG EXTERNAL FILE"
        actual="$(cat $ZPLUG_EXTERNAL)"
        assert.match "$expect" "$actual"
        after_each
    end

    it "__external__ 2"
        __external__ 'zplug "b4b4r07/enhancd", as:plugin, of:"*.sh"'
        expect="b4b4r07/enhancd"
        actual="$(cat $ZPLUG_EXTERNAL)"
        assert.match "$expect" "$actual"
        after_each
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset status_code
}
