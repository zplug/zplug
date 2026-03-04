#!/usr/bin/env zsh

source "$ZPLUG_ROOT/test/helper.zsh"

# All source handlers must implement these functions
local -a required_handlers=(check install update get_url)
local -a load_handlers=(load_plugin load_command load_theme)

# All known sources
local -a sources=(github bitbucket gist gh-r gitlab local oh-my-zsh prezto)

T_SUB "all source handler files exist" ((
    local src
    for src in $sources; do
        t_file "$ZPLUG_ROOT/base/sources/$src.zsh" "source file exists: $src"
    done
))

T_SUB "github implements required handlers" ((
    local handler
    for handler in $required_handlers $load_handlers; do
        (( $+functions[__zplug::sources::github::$handler] ))
        t_ok $? "github has $handler"
    done
))

T_SUB "bitbucket implements required handlers" ((
    local handler
    for handler in $required_handlers $load_handlers; do
        (( $+functions[__zplug::sources::bitbucket::$handler] ))
        t_ok $? "bitbucket has $handler"
    done
))

T_SUB "gist implements required handlers" ((
    local handler
    for handler in $required_handlers $load_handlers; do
        (( $+functions[__zplug::sources::gist::$handler] ))
        t_ok $? "gist has $handler"
    done
))

T_SUB "gh-r implements required handlers" ((
    local handler
    for handler in check install update $load_handlers; do
        (( $+functions[__zplug::sources::gh-r::$handler] ))
        t_ok $? "gh-r has $handler"
    done
))

T_SUB "gitlab implements required handlers" ((
    local handler
    for handler in $required_handlers $load_handlers; do
        (( $+functions[__zplug::sources::gitlab::$handler] ))
        t_ok $? "gitlab has $handler"
    done
))

T_SUB "local implements required handlers" ((
    local handler
    for handler in check install update $load_handlers; do
        (( $+functions[__zplug::sources::local::$handler] ))
        t_ok $? "local has $handler"
    done
))

T_SUB "oh-my-zsh implements required handlers" ((
    local handler
    for handler in $required_handlers $load_handlers; do
        (( $+functions[__zplug::sources::oh-my-zsh::$handler] ))
        t_ok $? "oh-my-zsh has $handler"
    done
))

T_SUB "prezto implements required handlers" ((
    local handler
    for handler in $required_handlers $load_handlers; do
        (( $+functions[__zplug::sources::prezto::$handler] ))
        t_ok $? "prezto has $handler"
    done
))

T_SUB "github get_url returns HTTPS URL by default" ((
    local url
    url="$(__zplug::sources::github::get_url "user/repo")"
    [[ "$url" == *github.com/user/repo* ]]
    t_ok $? "URL contains github.com/user/repo"
    [[ "$url" == https://* ]]
    t_ok $? "URL uses HTTPS protocol"
))

T_SUB "bitbucket get_url returns bitbucket URL" ((
    local url
    url="$(__zplug::sources::bitbucket::get_url "user/repo")"
    [[ "$url" == *bitbucket.org/user/repo* ]]
    t_ok $? "URL contains bitbucket.org/user/repo"
))

T_SUB "gitlab get_url returns gitlab URL" ((
    local url
    url="$(__zplug::sources::gitlab::get_url "user/repo")"
    [[ "$url" == *gitlab.com/user/repo* ]]
    t_ok $? "URL contains gitlab.com/user/repo"
))

T_SUB "gist get_url returns gist URL" ((
    local url
    url="$(__zplug::sources::gist::get_url "abc123")"
    [[ "$url" == *gist.github.com/abc123* ]]
    t_ok $? "URL contains gist.github.com"
))
