#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/lib/print/logger.zsh
    local -A zplugs
    local    expect actual
    local -i status_code
} &>/dev/null

describe "lib/print/logger.zsh"
    it ""
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset expects actuals
    unset status_code
} &>/dev/null
