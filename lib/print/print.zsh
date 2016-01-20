#!/bin/zsh

__put() {
    command printf -- "$@"
}

__die() {
    command printf -- "$@" >&2
}
