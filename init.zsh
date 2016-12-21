#!/usr/bin/env zsh

# A hash array for zplug
typeset -gx -A zplugs
zplugs=()

# A variable as a starting point of zplug
typeset -gx ZPLUG_ROOT="${${(%):-%N}:A:h}"

# Load basic functions such as an __zplug::base function
source "$ZPLUG_ROOT/base/init.zsh"
# Load autoloader
source "$ZPLUG_ROOT/autoload/init.zsh"

__zplug::base "base/*"
__zplug::base "core/*"
__zplug::base "io/*"
__zplug::base "log/*"
__zplug::base "job/*"
__zplug::base "sources/*"
__zplug::base "utils/*"

if ! __zplug::core::core::prepare; then
    __zplug::io::print::f \
        --die \
        --zplug \
        --error \
        "The loading of zplug was discontinued.\n"
    return 1
fi

# Load the external file of zplug
__zplug::io::file::load
