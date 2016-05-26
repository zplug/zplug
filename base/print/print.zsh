#!/usr/bin/env zsh

__zplug::print::print::put() {
    command printf -- "$@"
}

__zplug::print::print::die() {
    command printf -- "$@" >&2
}
