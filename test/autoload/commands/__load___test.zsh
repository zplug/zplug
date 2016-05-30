#!/usr/bin/env zsh

: before
{
    source "$ZPLUG_ROOT/init.zsh"
    source "$ZPLUG_ROOT/test/.helpers/mock.zsh"

    export ZPLUG_HOME="$ZPLUG_ROOT/test/.fixtures"
    unset ZPLUG_LOADFILE

    local expect actual
}

describe "__load__"
    it "Unknown option"
        expect="[zplug] --unknown: Unknown option"
        actual="$(zplug check --unknown 2>&1)"
        assert.false $status
        assert.equals "$expect" "$actual"
    end

    it ""
        mock_as_command "foo/foo"
        zplug load
        [[ -x $ZPLUG_HOME/bin/foo ]]
        assert.true $status
    end

    it ""
        mock_as_plugin "bar/bar"
        expect="  Loaded bar/bar/bar.zsh"
        actual="$(zplug load --verbose | unansi)"
        assert.equals "$expect" "$actual"
    end

    it "loads from cache at a custom location"
        ZPLUG_USE_CACHE=true
        ZPLUG_CACHE_FILE=$ZPLUG_HOME/foo/cache

        mock_as_plugin "foo/bar"
        zplug load

        sleep 1

        [[ -f $ZPLUG_CACHE_FILE ]]
        assert.true $status
    end
end

: after
{
    zplugs=()
    unset expect actual
    rm -rf $ZPLUG_HOME
}
