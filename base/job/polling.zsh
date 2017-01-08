export PERIOD=30

__zplug::job::polling::periodic()
{
    if [[ -f $_zplug_lock[job] ]]; then
        setopt nomonitor
    else
        if [[ -o monitor ]]; then
            return 0
        fi
        if setopt monitor; then
            __zplug::log::write::info "turn monitor on"
        fi
    fi
}

add-zsh-hook periodic __zplug::job::polling::periodic
