#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/autoload/init.zsh
    source $ZPLUG_ROOT/autoload/autoload.zsh
    source $ZPLUG_ROOT/init.zsh
    export ZPLUG_HOME=$ZPLUG_ROOT/test/_fixtures
    local -A zplugs
    local    expect actual
    local -i status_code
    local    peco
} &>/dev/null

before_each() {
    mkdir -p $ZPLUG_HOME/repos
}

after_each() {
    rm -rf $ZPLUG_HOME/repos
}

describe "__clone__"
    it "unknown option"
        expect="[zplug] --unknown: Unknown option"
        actual="$(__clone__ --unknown 2>&1)"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.false $status_code
    end

    it "unknown tag"
        expect="[zplug] aaa: Unknown tag"
        actual="$(__clone__ --from "aaa" 2>&1)"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.false $status_code
    end

    it "from oh-my-zsh"
        before_each
        __git_version() { false; }
        repo=""
        expect=""
        actual="$(
        __clone__ \
            --use    "" \
            --commit "" \
            --from  "oh-my-zsh" \
            --at    "master" \
            --do    "" \
            "$repo" 2>&1
        )"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.true $status_code
        builtin cd -q "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH"
        expect="https://git::@github.com/robbyrussell/oh-my-zsh.git"
        actual="$(git remote -v)"
        assert.match "$expect" "$actual"
        after_each
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset status_code
    unset repo
}
