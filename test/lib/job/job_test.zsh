#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/lib/job/job.zsh
    local -A zplugs
    local    expect actual
    local -i status_code
} &>/dev/null

describe "lib/job/job.zsh"
    it "__polling"
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset expects actuals
    unset status_code
} &>/dev/null
