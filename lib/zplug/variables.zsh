#!/bin/zsh

typeset -gx -A zplugs

typeset -gx ZPLUG_HOME=${ZPLUG_HOME:-~/.zplug}
typeset -gx ZPLUG_THREADS=${ZPLUG_THREADS:-16}
typeset -gx ZPLUG_SHALLOW=${ZPLUG_SHALLOW:-true}
typeset -gx ZPLUG_PROTOCOL=${ZPLUG_PROTOCOL:-HTTPS}
typeset -gx ZPLUG_FILTER=${ZPLUG_FILTER:-"fzf-tmux:fzf:peco:percol:zaw"}
typeset -gx ZPLUG_EXTERNAL=${ZPLUG_EXTERNAL:-$ZPLUG_HOME/init.zsh}
typeset -gx ZPLUG_USE_CACHE=true

typeset -gx -r _ZPLUG_VERSION="2.0.0"
typeset -gx -r _ZPLUG_CACHE_FILE="$ZPLUG_HOME/.cache"
typeset -gx -r _ZPLUG_URL="https://github.com/b4b4r07/zplug"
typeset -gx -r _ZPLUG_HELP="usage: zplug [COMMANDS] [OPTIONS]
  zplug is a next-generation plugin manager for zsh 

COMMANDS:
  help      Show this help message and usage
  version   Show version information
  install   Install described items in parallel
  update    Update items in parallel
  load      Source plugins to current shell and add \$ZPLUG_HOME/bin to \$PATH
  list      Show all of the zplugs in the current shell
  check     Check whether an update or installation is available
  status    Check if remote branch is up-to-date
  clean     Remove repositories which is no longer managed
  clear     Remove the cache file

For more information, see also $_ZPLUG_URL."

typeset -g -r _ZPLUG_OHMYZSH="robbyrussell/oh-my-zsh"
typeset -g -r _ZPLUG_TAG_PATTERN="(as|use|from|if|dir|rename_to|at|do|frozen|on|commit|nice|ignore|lazy)"
typeset -g -r _ZPLUG_OLDTAG_PATTERN="(of|file)"
