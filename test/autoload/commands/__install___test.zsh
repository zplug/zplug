#!/usr/bin/env zsh

: before
{
    source "$ZPLUG_ROOT/init.zsh"
    source "$ZPLUG_ROOT/test/.helpers/mock.zsh"

    export ZPLUG_HOME="$ZPLUG_ROOT/test/.fixtures"

    local expect actual
}

describe "__install__"
    it "Unknown option"
        expect="[zplug] --unknown: Unknown option"
        actual="$(zplug check --unknown 2>&1)"
        assert.false $status
        assert.equals "$expect" "$actual"
    end

    it ""
        expect="[zplug] no package managed by zplug"
        actual="$(zplug install 2>&1)"
        assert.false $status
        assert.equals "$expect" "$actual"
    end

    it "Returns true"
        zplug install "b4b4r07/enhancd" &>/dev/null
        assert.true $status
    end

    it "Returns false"
        zplug install "$$/$$" &>/dev/null
        assert.false $status
    end

    it "Returns true 2"
        zplug "b4b4r07/zsh-gomi"
        zplug install &>/dev/null
        assert.true $status
    end
end

: after
{
    zplugs=()
    unset expect actual
    rm -rf "$ZPLUG_REPOS"
}
