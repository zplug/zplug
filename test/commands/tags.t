#!/usr/bin/env zsh

source "$ZPLUG_ROOT/test/helper.zsh"

# Helper: parse tags for a repo into associative array $tags
_parse_tags() {
    __zplug::core::tags::parse "$1"
    tags=( "${reply[@]}" )
}

#
# Default values
#

T_SUB "default as is plugin" ((
    zplugs=()
    zplug "user/repo"
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[as]" "plugin" "as defaults to plugin"
))

T_SUB "default from is github" ((
    zplugs=()
    zplug "user/repo"
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[from]" "github" "from defaults to github"
))

T_SUB "default at is master" ((
    zplugs=()
    zplug "user/repo"
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[at]" "master" "at defaults to master"
))

T_SUB "default at is latest for gh-r" ((
    zplugs=()
    zplug "user/repo", from:gh-r, as:command
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[at]" "latest" "at defaults to latest for gh-r"
))

T_SUB "default use is *.zsh" ((
    zplugs=()
    zplug "user/repo"
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[use]" "*.zsh" "use defaults to *.zsh"
))

T_SUB "default frozen is no" ((
    zplugs=()
    zplug "user/repo"
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[frozen]" "no" "frozen defaults to no"
))

T_SUB "default lazy is no" ((
    zplugs=()
    zplug "user/repo"
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[lazy]" "no" "lazy defaults to no"
))

T_SUB "default defer is 0" ((
    zplugs=()
    zplug "user/repo"
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[defer]" "0" "defer defaults to 0"
))

T_SUB "default depth is 0" ((
    zplugs=()
    zplug "user/repo"
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[depth]" "0" "depth defaults to 0"
))

T_SUB "dir defaults to ZPLUG_REPOS/repo" ((
    zplugs=()
    zplug "user/repo"
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[dir]" "$ZPLUG_REPOS/user/repo" "dir defaults to repos/user/repo"
))

#
# Explicit tag values
#

T_SUB "explicit as:command is respected" ((
    zplugs=()
    zplug "user/repo", as:command
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[as]" "command" "as is command"
))

T_SUB "explicit as:theme is respected" ((
    zplugs=()
    zplug "user/repo", as:theme
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[as]" "theme" "as is theme"
))

T_SUB "explicit at:dev is respected" ((
    zplugs=()
    zplug "user/repo", at:dev
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[at]" "dev" "at is dev"
))

T_SUB "explicit frozen:yes is respected" ((
    zplugs=()
    zplug "user/repo", frozen:yes
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[frozen]" "yes" "frozen is yes"
))

T_SUB "explicit defer:2 is respected" ((
    zplugs=()
    zplug "user/repo", defer:2
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[defer]" "2" "defer is 2"
))

T_SUB "explicit depth:1 is respected" ((
    zplugs=()
    zplug "user/repo", depth:1
    local -A tags; _parse_tags "user/repo"

    t_is "$tags[depth]" "1" "depth is 1"
))
