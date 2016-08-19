#!/usr/bin/env zsh

local arg="$1" fp ans

for fp in "${arg:-$ZPLUG_ROOT}/base"/*/*.zsh
do
    local parent="${fp:h:t}"
    local child="${fp:t:r}"
    local test_file="${arg:-$ZPLUG_ROOT}/test/base/$parent/$child.t"

    # Check if already exists
    if [[ -f $test_file ]]; then
        echo -en "$test_file: is already exists. Overwrite? y/N: "
        read -q ans && echo
        if [[ ! ${(L)ans} =~ ^y(es)?$ ]]; then
            continue
        fi
    fi

    # Update
    rm -f "$test_file"
    cat "$fp" \
        | grep "^__zplug::$parent::$child" \
        | awk '
    {
        gsub(/\(\)/, "")
        gsub(/ {/, "")
        print "T_SUB \"" $0 "\" (("
        print "  # skip"
        print "))"
    }
    ' >> "$test_file"
done

for fp in "${arg:-$ZPLUG_ROOT}"/autoload/{commands,options,tags}/__*__
do
    local dir="${fp:h}"
    local file="${fp:t}"
    local name="${file:gs:_:}"

    touch "${arg:-$ZPLUG_ROOT}/test/$dir/$name.t"
done
