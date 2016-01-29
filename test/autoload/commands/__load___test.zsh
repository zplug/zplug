#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/autoload/init.zsh
    source $ZPLUG_ROOT/autoload/autoload.zsh
    source $ZPLUG_ROOT/init.zsh
    export ZPLUG_HOME=$ZPLUG_ROOT/test/_fixtures
    export _ZPLUG_CACHE_FILE=$ZPLUG_HOME/.cache
    local -A zplugs
    local    expect actual
    local -i status_code
    local -a repos
} &>/dev/null

before_each() {
    rm -f "$_ZPLUG_CACHE_FILE"
}

after_each() {
    rm -rf "$ZPLUG_HOME/repos"
    rm -rf "$ZPLUG_HOME/bin"
}

describe "__load__"
    it "unknown option"
        expect="--unknown: Unknown option"
        actual="$(__load__ --unknown 2>&1)"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.false $status_code
    end

    it "cache"
        touch "$_ZPLUG_CACHE_FILE"
        expect="$_ZPLUG_CACHE_FILE"
        actual="$(ZPLUG_USE_CACHE=true __load__ --debug 2>&1)"
        status_code=$status
        assert.equals "$expect" "$actual"
        assert.true $status_code
    end

    it "plugin"
        it ""
            before_each
            __add__ "foo/bar, as:plugin"
            create_mock_plugin "foo/bar"
            expect="$ZPLUG_HOME/repos/foo/bar/foobar.zsh"
            actual="$(__load__ --debug 2>/dev/null)"
            status_code=$status
            assert.equals "$expect" "$actual"
            assert.true $status_code
            after_each
        end

        it ""
            before_each
            __add__ "foo1/bar, as:plugin"
            __add__ "foo2/bar, as:plugin"
            __add__ "foo3/bar, as:plugin"
            create_mock_plugin "foo1/bar"
            create_mock_plugin "foo2/bar"
            create_mock_plugin "foo3/bar"
            repos=(
            "$ZPLUG_HOME/repos/foo1/bar/foo1bar.zsh"
            "$ZPLUG_HOME/repos/foo2/bar/foo2bar.zsh"
            "$ZPLUG_HOME/repos/foo3/bar/foo3bar.zsh"
            )
            expect="$(print -l $repos)"
            actual="$(__load__ --debug 2>/dev/null)"
            status_code=$status
            assert.equals "$expect" "$actual"
            assert.true $status_code
            # Do not run after_each
            # after_each
        end

        it ""
            before_each
            __add__ "foo4/bar, as:plugin, nice:-1"
            create_mock_plugin "foo4/bar"
            repos=(
            "$ZPLUG_HOME/repos/foo4/bar/foo4bar.zsh"
            "$ZPLUG_HOME/repos/foo1/bar/foo1bar.zsh"
            "$ZPLUG_HOME/repos/foo2/bar/foo2bar.zsh"
            "$ZPLUG_HOME/repos/foo3/bar/foo3bar.zsh"
            )
            expect="$(print -l $repos)"
            actual="$(__load__ --debug 2>/dev/null)"
            status_code=$status
            assert.equals "$expect" "$actual"
            assert.true $status_code
            # Do not run after_each
            # after_each
        end

        it "omz"
            create_mock_omz

            it "plugins/git"
                before_each
                __add__ "plugins/git, from:oh-my-zsh"
                repos=(
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/oh-my-zsh.sh"
                "$ZPLUG_HOME/repos/foo4/bar/foo4bar.zsh"
                "$ZPLUG_HOME/repos/foo1/bar/foo1bar.zsh"
                "$ZPLUG_HOME/repos/foo2/bar/foo2bar.zsh"
                "$ZPLUG_HOME/repos/foo3/bar/foo3bar.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/git/git.plugin.zsh"
                )
                expect="$(print -l $repos)"
                actual="$(__load__ --debug 2>/dev/null)"
                status_code=$status
                assert.equals "$expect" "$actual"
                assert.true $status_code
            end

            it "plugins/mix"
                before_each
                __add__ "plugins/mix, from:oh-my-zsh"
                repos=(
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/oh-my-zsh.sh"
                "$ZPLUG_HOME/repos/foo4/bar/foo4bar.zsh"
                "$ZPLUG_HOME/repos/foo1/bar/foo1bar.zsh"
                "$ZPLUG_HOME/repos/foo2/bar/foo2bar.zsh"
                "$ZPLUG_HOME/repos/foo3/bar/foo3bar.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/git/git.plugin.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/mix"
                )
                expect="$(print -l $repos)"
                actual="$(__load__ --debug 2>/dev/null)"
                status_code=$status
                assert.equals "$expect" "$actual"
                assert.true $status_code
            end

            it "plugins/brew"
                before_each
                __add__ "plugins/brew, from:oh-my-zsh"
                repos=(
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/oh-my-zsh.sh"
                "$ZPLUG_HOME/repos/foo4/bar/foo4bar.zsh"
                "$ZPLUG_HOME/repos/foo1/bar/foo1bar.zsh"
                "$ZPLUG_HOME/repos/foo2/bar/foo2bar.zsh"
                "$ZPLUG_HOME/repos/foo3/bar/foo3bar.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/brew/brew.plugin.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/git/git.plugin.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/brew"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/mix"
                )
                expect="$(print -l $repos)"
                actual="$(__load__ --debug 2>/dev/null)"
                status_code=$status
                assert.equals "$expect" "$actual"
                assert.true $status_code
            end

            it "themes/3den"
                before_each
                __add__ "themes/3den, from:oh-my-zsh"
                repos=(
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/oh-my-zsh.sh"
                "$ZPLUG_HOME/repos/foo4/bar/foo4bar.zsh"
                "$ZPLUG_HOME/repos/foo1/bar/foo1bar.zsh"
                "$ZPLUG_HOME/repos/foo2/bar/foo2bar.zsh"
                "$ZPLUG_HOME/repos/foo3/bar/foo3bar.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/brew/brew.plugin.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/git/git.plugin.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/themes/3den.zsh-theme"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/brew"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/mix"
                )
                expect="$(print -l $repos)"
                actual="$(__load__ --debug 2>/dev/null)"
                status_code=$status
                assert.equals "$expect" "$actual"
                assert.true $status_code
            end

            it "themes/zhann"
                before_each
                __add__ "themes/zhann, from:oh-my-zsh"
                repos=(
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/oh-my-zsh.sh"
                "$ZPLUG_HOME/repos/foo4/bar/foo4bar.zsh"
                "$ZPLUG_HOME/repos/foo1/bar/foo1bar.zsh"
                "$ZPLUG_HOME/repos/foo2/bar/foo2bar.zsh"
                "$ZPLUG_HOME/repos/foo3/bar/foo3bar.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/brew/brew.plugin.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/git/git.plugin.zsh"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/themes/3den.zsh-theme"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/themes/zhann.zsh-theme"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/brew"
                "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH/plugins/mix"
                )
                expect="$(print -l $repos)"
                actual="$(__load__ --debug 2>/dev/null)"
                status_code=$status
                assert.equals "$expect" "$actual"
                assert.true $status_code
            end

            after_each
        end
    end

    it "command"

        it ""
            before_each
            __add__ "baz1/qux, as:command"
            create_mock_command "baz1/qux"
            __load__ --debug &>/dev/null
            assert.true $status
            [[ -x $ZPLUG_HOME/bin/qux ]]
            assert.true $status
            after_each
        end

    end
end

: after
{
    after_each
    unset zplugs
    unset expect actual
    unset expects actuals
    unset status_code
    unset repos
} &>/dev/null
