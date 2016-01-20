#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/autoload/init.zsh
    source $ZPLUG_ROOT/autoload/autoload.zsh
    source $ZPLUG_ROOT/zplug.zsh
    export ZPLUG_HOME=$ZPLUG_ROOT/test/_fixtures
    local -A zplugs
    local    expect actual
    local -i status_code
    myfzf() { head -n 1; }
    __is_cli() { true; }
} &>/dev/null

before_each() {
    source $ZPLUG_ROOT/test/_helpers/create_mock_repos.zsh
    source $ZPLUG_ROOT/test/_helpers/init_mock_repos.zsh
    create_mock_plugin "foo/bar"
    init_mock_repos "foo/bar"
}
after_each() {
    rm -rf "$ZPLUG_HOME"/repos/**/.git(N-/)
    rm -rf "$ZPLUG_HOME/error.log"
}

describe "__add__"
    it "already managed"
        zplugs=("username/reponame" "")
        expect="username/reponame: already managed"
        actual="$(__add__ "username/reponame" 2>&1)"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.false $status_code
    end

    it "pipe"
        zplugs=()
        expect="1/1: cannot install (2 or less pipelines)"
        __add__ --debug "1/1" | __add__ --debug "2/2" | __add__ --debug "3/3"
        actual="$(cat "$ZPLUG_HOME/error.log")"
        assert.equals "$expect" "$actual"
        after_each
    end

    it "invalid tag"
        zplugs=()
        expect="invalid tag"
        actual="$(__add__ "username/reponame, tag:value" 2>&1)"
        status_code=$status
        assert.match "$expect" "$actual"
        assert.false $status_code
    end
end

: after
{
    rm -f "$ZPLUG_EXTERNAL"
    unset zplugs
    unset expect actual
    unset status_code
}
