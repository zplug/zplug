#!/usr/bin/env zsh

unansi() {
    cat <&0 \
        | perl -pe 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g'
}
