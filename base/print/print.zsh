#!/usr/bin/env zsh

__zplug::print::print::put() {
    LC_ALL=POSIX command printf -- "$@"
}

__zplug::print::print::die() {
    LC_ALL=POSIX command printf -- "$@" >&2
}
