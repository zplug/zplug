#!/bin/zsh

: before
{
    export ZPLUG_HOME=$ZPLUG_ROOT/test/_fixtures
    source $ZPLUG_ROOT/lib/cli/getopts.zsh
    source $ZPLUG_ROOT/init.zsh
    local -A zplugs
    local    expect actual
    local -a expects actuals
    local -i status_code
} &>/dev/null

describe "lib/cli/getopts.zsh"
    it "only bare"
        expect="_ beer"
        actual="$(__getopts beer)"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.true $status_code
    end

    it "bare and bare"
        expects=( "_ bar" "_ beer" )
        actuals=( "${(@f)"$(__getopts bar beer)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "bare first"
        expects=( "_ beer" "foo" )
        actuals=( "${(@f)"$(__getopts beer --foo)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "bare sequence"
        expects=( "_ foo" "_ bar" "_ baz" "_ quux" )
        actuals=( "${(@f)"$(__getopts foo bar baz quux)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "bare does not end opts"
        expects=( "a" "b 42" "_ beer" "foo" "bar" )
        actuals=( "${(@f)"$(__getopts beer -ab42 beer --foo --bar)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "only single"
        expects=( "f" "o" "o 42" )
        actuals=( "${(@f)"$(__getopts -foo42)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "single and single"
        expects=( "a" "b" "c" "x" "y" "z" )
        actuals=( "${(@f)"$(__getopts -abc -xyz)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "single and bare"
        expects=( "a" "b" "c bar" )
        actuals=( "${(@f)"$(__getopts -abc bar)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "single and value"
        expects=( "a bar" )
        actuals=( "${(@f)"$(__getopts -a bar)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "single w/ value and bare"
        expects=( "a" "b" "c ./" "_ bar" )
        actuals=( "${(@f)"$(__getopts -abc./ bar)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "single and double"
        expects=( "a" "b" "c" "foo" )
        actuals=( "${(@f)"$(__getopts -abc --foo)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "double"
        expects=( "foo" )
        actuals=( "${(@f)"$(__getopts --foo)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "double w/ value"
        expects=( "foo bar" )
        actuals=( "${(@f)"$(__getopts --foo=bar)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "double w/ nagated value"
        expects=( "foo bar !" )
        actuals=( "${(@f)"$(__getopts --foo!=bar)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "double w/ value group"
        expects=( "foo bar" "bar foo" )
        actuals=( "${(@f)"$(__getopts --foo=bar --bar=foo)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "double w/ value and bare"
        expects=( "foo bar" "_ beer" )
        actuals=( "${(@f)"$(__getopts --foo=bar beer)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "double double"
        expects=( "foo" "bar" )
        actuals=( "${(@f)"$(__getopts --foo --bar)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "double w/ inner dashes"
        expects=( "foo-bar-baz" )
        actuals=( "${(@f)"$(__getopts --foo-bar-baz)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "double and single"
        expects=( "foo" "a" "b" "c" )
        actuals=( "${(@f)"$(__getopts --foo -abc)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "multiple double sequence"
        expects=( "foo" "bar" "secstatus_code 42" "_ baz" )
        actuals=( "${(@f)"$(__getopts --foo --bar --secstatus_code=42 baz)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "single double single w/ remaining bares"
        expects=( "f" "o" "bar" "b" "a" "r norf" "_ baz" "_ quux" )
        actuals=( "${(@f)"$(__getopts -foo --bar -bar norf baz quux)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "double dash"
        expects=( "_ --foo" "_ bar" )
        actuals=( "${(@f)"$(__getopts -- --foo bar)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "single double dash"
        expects=( "a" "_ --foo" "_ bar" )
        actuals=( "${(@f)"$(__getopts -a -- --foo bar)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "bare and double dash"
        expects=( "foo bar" "_ baz" "_ foo" "_ --foo" )
        actuals=( "${(@f)"$(__getopts --foo=bar baz -- foo --foo)"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "long string as a value"
        expects=( "f Fee fi fo fum" )
        actuals=( "${(@f)"$(__getopts -f "Fee fi fo fum")"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "single and empty string"
        expects=( "f" )
        actuals=( "${(@f)"$(__getopts -f "")"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "double and empty string"
        expects=( "foo" )
        actuals=( "${(@f)"$(__getopts --foo "")"}" )
        status_code=$status
        assert.array_equals expects actuals
        assert.true $status_code
    end

    it "ignore repeated options"
        expects=( "x" )
        actuals=( "${(@f)"$(__getopts -xxx | xargs)"}" )
        status_code=$status
        assert.array_equals expects actuals
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
