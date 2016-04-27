#!/bin/zsh
# init.zsh:
#   This file is called only once

# It is desirable that the ZPLUG_ROOT and the ZPLUG_HOME is the same
# because zplug should be installed with git clone URL /path/to/local_dir
# e.g. ~/.zplug
typeset -gx ZPLUG_ROOT="${${(%):-%N}:A:h}"

# Unique array
typeset -gx -U path
typeset -gx -U fpath

# Add to the PATH
path=(
"$ZPLUG_ROOT"/bin
$path
)

# Add to the FPATH
fpath=(
"$ZPLUG_ROOT"/autoload(N-/)
"$ZPLUG_ROOT"/misc/completions(N-/)
$fpath
)

autoload -Uz zplug
