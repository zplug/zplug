#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/lib/core/core.zsh
    local -A zplugs
    local    expect actual
    local -i status_code
} &>/dev/null

describe "lib/core/core.zsh"
    it "__is_cli"
    end

    it "__zpluged"
        zplugs=("user/repo" "")
        __zpluged "user/repo"
        assert.true $status
    end

    it "__get_autoload_dirs"
        __get_autoload_dirs
        expect=2
        actual=$#reply
        assert.equals "$expect" "$actual"
    end

    it "__get_autoload_paths"
        __get_autoload_paths
        expect=18
        actual=$#reply
        assert.equals "$expect" "$actual"
    end

    it "__get_autoload_files"
        __get_autoload_files
        expect=18
        actual=$#reply
        expects=(
        __check__
        __clean__
        __clear__
        __help__
        __install__
        __list__
        __load__
        __status__
        __update__
        __version__
        __add__
        __arguments__
        __clone__
        __external__
        __parser__
        __releases__
        __self__
        __validator__
        )
        actuals=( "${reply[@]}" )
        assert.equals "$expect" "$actual"
        assert.array_equals expects actuals
    end

    it "__in_array"
        arr=(a b c)
        __in_array "a" $arr
        assert.true $status
    end

    it "__in_array 2"
        arr=(a b c)
        __in_array "d" $arr
        assert.false $status
    end

    it "__get_filter"
        expect="$(__get_filter "ls:non_existing")"
        actual="ls"
        assert.equals "$expect" "$actual"
    end

    it "__get_filter 2"
        expect="$(__get_filter "ls -l:non_existing")"
        actual="ls"
        assert.equals "$expect" "$actual"
    end

    it "__get_filter 3"
        expect="$(__get_filter "non_existing:ls -l")"
        actual="ls"
        assert.equals "$expect" "$actual"
    end

    it "__get_filter 4"
        expect="$(__get_filter "ls -l")"
        actual="ls"
        assert.equals "$expect" "$actual"
    end

    it "__get_filter 5"
        expect="$(__get_filter)"
        status_code=$status
        actual=""
        assert.equals "$expect" "$actual"
        assert.false $status
    end

    it "__version_requirement 1"
        __version_requirement 1.2.3 1.2.2
        assert.true $status
    end

    it "__version_requirement 2"
        __version_requirement 1.2.3 1.2.4
        assert.false $status
    end

    it "__version_requirement 3"
        __version_requirement 1.2.3 1
        assert.true $status
    end

    it "__version_requirement 4"
        __version_requirement 1.2.3 2
        assert.false $status
    end

    it "__version_requirement 5"
        __version_requirement 1 1
        assert.true $status
    end

    it "__git_version 9999.9999"
        __git_version 9999.9999
        assert.false $status
    end

    it "__git_version 0.0"
        __git_version 0.0
        assert.true $status
    end

    it "__zsh_version"
    end

    it "__get_os 1"
        OSTYPE="Linux"
        expect="$(__get_os $OSTYPE)"
        actual="linux"
        assert.equals "$expect" "$actual"
    end

    it "__get_os 2"
        OSTYPE="DARWIN"
        expect="$(__get_os $OSTYPE)"
        actual="darwin"
        assert.equals "$expect" "$actual"
    end

    it "__get_os 3"
        OSTYPE="windows"
        expect="$(__get_os $OSTYPE)"
        actual="unknown"
        assert.equals "$expect" "$actual"
    end

    it "__glob2regexp 1"
        expect="$(__glob2regexp "*abc*")"
        actual="^.*abc.*$"
        assert.equals "$expect" "$actual"
    end

    it "__glob2regexp 2"
        expect="$(__glob2regexp "file{A,B}")"
        actual="^file(A|B)$"
        assert.equals "$expect" "$actual"
    end

    it "__glob2regexp 3"
        expect="$(__glob2regexp "a??b")"
        actual="^a..b$"
        assert.equals "$expect" "$actual"
    end

    it "__remove_deadlinks"
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset expects actuals
    unset status_code
} &>/dev/null
