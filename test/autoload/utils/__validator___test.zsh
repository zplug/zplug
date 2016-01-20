#!/bin/zsh

: before
{
    source $ZPLUG_ROOT/autoload/autoload.zsh
    source $ZPLUG_ROOT/zplug.zsh
    export ZPLUG_HOME=$ZPLUG_ROOT/test/_fixtures
    local -A zplugs
    local    expect actual
    local -i status_code
} &>/dev/null

describe "__validator__"
    it ""
    end
end

: after
{
    unset zplugs
    unset expect actual
    unset status_code
}
