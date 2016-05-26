#!/usr/bin/env zsh

__import "core/core"

__zplug::job::polling::finalize() {
    __zplug::core::core::get_autoload_files
    unfunction "${reply[@]}" &>/dev/null
}

add-zsh-hook \
    precmd \
    __zplug::job::polling::finalize
