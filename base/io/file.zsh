__zplug::io::file::load()
{
    if [[ ! -f ${~ZPLUG_LOADFILE} ]]; then
        __zplug::log::write::info \
            "ZPLUG_LOADFILE is not found"
        return 0
    fi

    source "$ZPLUG_LOADFILE"
    return $status
}

__zplug::io::file::generate()
{
    if [[ -f $ZPLUG_LOADFILE ]]; then
        return 0
    fi

    cat <<-TEMPLATE >$ZPLUG_LOADFILE
#!/usr/bin/env zsh
# -*- mode: zsh -*-
# vim:ft=zsh
#
# *** ZPLUG EXTERNAL FILE ***
# You can register plugins or commands to zplug on the
# command-line. If you use zplug on the command-line,
# it is possible to write more easily its settings
# by grace of the command-line completion.
# In this case, zplug spit out its settings to
# $ZPLUG_LOADFILE instead of .zshrc.
# If you launch new zsh process, zplug load command
# automatically search this file and run source command.
#
#
# Example:
# zplug "b4b4r07/enhancd", as:plugin, use:"*.sh"
# zplug "rupa/z",          as:plugin, use:"*.sh"
#
TEMPLATE
}

__zplug::io::file::rm_touch()
{
    local filepath="${argv:?}"

    # For shorten the calculation time
    if [[ ! -d ${filepath:h} ]]; then
        mkdir -p "${filepath:h}"
    fi

    rm -f "$filepath"
    touch "$filepath"
}
