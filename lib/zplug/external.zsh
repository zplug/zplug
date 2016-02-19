#!/bin/zsh

__import "print/print"

__zplug::zplug::external::load() {
    if [[ -f $ZPLUG_EXTERNAL ]]; then
        source "$ZPLUG_EXTERNAL"
    fi
}

__zplug::zplug::external::generate() {
    if [[ ! -f $ZPLUG_EXTERNAL ]]; then
        cat <<-TEMPLATE >$ZPLUG_EXTERNAL
	#!/bin/zsh
	# -*- mode: zsh -*-
	# vim:ft=zsh
	#
	# *** ZPLUG EXTERNAL FILE ***
	# You can register plugins or commands to zplug on the
	# command-line. If you use zplug on the command-line,
	# it is possible to write more easily its settings
	# by grace of the command-line completion.
	# In this case, zplug spit out its settings to
	# $ZPLUG_EXTERNAL instead of .zshrc.
	# If you launch new zsh process, zplug load command
	# automatically search this file and run source command.
	#
	#
	# Example:
	# zplug "b4b4r07/enhancd", as:plugin, of:"*.sh"
	# zplug "rupa/z",          as:plugin, of:"*.sh"
	#
TEMPLATE
    fi

    if [[ -n $1 ]]; then
        __zplug::print::print::put "$@\n" >>|$ZPLUG_EXTERNAL
    fi
}
