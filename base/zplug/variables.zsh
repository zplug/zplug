#!/usr/bin/env zsh

__import "print/print"
__import "core/core"

typeset -gx -A zplugs

typeset -gx ZPLUG_HOME=${ZPLUG_HOME:-~/.zplug}
typeset -gx ZPLUG_THREADS=${ZPLUG_THREADS:-16}
typeset -gx ZPLUG_CLONE_DEPTH=${ZPLUG_CLONE_DEPTH:-0}
typeset -gx ZPLUG_PROTOCOL=${ZPLUG_PROTOCOL:-HTTPS}
typeset -gx ZPLUG_FILTER=${ZPLUG_FILTER:-"fzf-tmux:fzf:peco:percol:zaw"}
typeset -gx ZPLUG_LOADFILE=${ZPLUG_LOADFILE:-$ZPLUG_HOME/packages.zsh}
typeset -gx ZPLUG_USE_CACHE=${ZPLUG_USE_CACHE:-true}
typeset -gx ZPLUG_CACHE_FILE=${ZPLUG_CACHE_FILE:-$ZPLUG_HOME/.cache}
typeset -gx ZPLUG_REPOS=${ZPLUG_REPOS:-$ZPLUG_HOME/repos}

typeset -gx -r _ZPLUG_VERSION="2.1.0"
typeset -gx -r _ZPLUG_URL="https://github.com/zplug/zplug"
typeset -gx -r _ZPLUG_HELP="usage: zplug [COMMANDS] [OPTIONS]
  zplug is a next-generation plugin manager for zsh 

OPTIONS:
  --help     Display the help message
  --version  Display the version of zplug

COMMANDS:
  install    Install packages in parallel
  load       Source installed plugins and add installed commands to \$PATH
  list       List installed packages (more specifically, view the associative array \$zplugs)
  update     Update installed packages in parallel
  check      Return true if all packages are installed, false otherwise
  status     Check if the remote repositories are up to date
  clean      Remove repositories which are no longer managed
  clear      Remove the cache file
  info       Show the information such as the source URL and tag values for the given package

For more information, see also ${(%):-"%U"}$_ZPLUG_URL${(%):-"%u"}."

typeset -g -r _ZPLUG_OHMYZSH="robbyrussell/oh-my-zsh"

__zplug::core::core::get_tags
typeset -ga _zplug_tag_pattern
_zplug_tag_pattern=( "${reply[@]}" )

if (( $+ZPLUG_SHALLOW )); then
    __zplug::print::print::die "[zplug] $fg[red]${(%):-"%U"}WARNING${(%):-"%u"}$reset_color: ZPLUG_SHALLOW is deprecated. "
    __zplug::print::print::die "Please use 'export ZPLUG_CLONE_DEPTH=1' instead.\n"
fi

typeset -ga _zplug_boolean_true
_zplug_boolean_true=("true" "yes" "on" 1)
typeset -ga _zplug_boolean_false
_zplug_boolean_false=("false" "no" "off" 0)

# context ":zplug:config:setopt"
local -a only_subshell
typeset -gx _ZPLUG_CONFIG_SUBSHELL=":"
zstyle -a ":zplug:config:setopt" \
    only_subshell \
    only_subshell
zstyle -t ":zplug:config:setopt" \
    same_curshell
if (( $_zplug_boolean_true[(I)$same_curshell] )); then
    only_subshell=(
        "${only_subshell[@]:gs:_:}"
        $(setopt)
    )
fi
if (( $#only_subshell > 0 )); then
    _ZPLUG_CONFIG_SUBSHELL="setopt ${(u)only_subshell[@]}"
fi
