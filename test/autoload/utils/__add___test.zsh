#!/usr/bin/env zsh

: before
{
    source "$ZPLUG_ROOT/init.zsh"
    source "$ZPLUG_ROOT/test/.helpers/mock.zsh"
    source "$ZPLUG_ROOT/test/.helpers/helper.zsh"

    export ZPLUG_HOME="$ZPLUG_ROOT/test/.fixtures"

    local expect actual
}

describe "__add__"
    it "Add to zplugs"
        zplugs=()
        zplug "foo/foo"
        (( $+zplugs[foo/foo] ))
        assert.true $status
    end

    it "Duplicate registration"
        zplugs=()
        zplug "foo/foo"
        zplug "foo/foo"
        zplug "foo/foo"
        (( $+zplugs[foo/foo] ))
        assert.true $status
        (( $+zplugs[foo/foo@] ))
        assert.true $status
        (( $+zplugs[foo/foo@@] ))
        assert.true $status
        expect="foo/foo  =>  nil
foo/foo  =>  nil
foo/foo  =>  nil"
        actual="$(zplug list | unansi)"
        assert.equals "$expect" "$actual"
    end
end

: after
{
    zplugs=()
    unset expect actual
}
