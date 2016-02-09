#!/bin/zsh

__omz_depends() {
    local    lib_f func_name dep
    local -a target
    local -a -U depends
    local -a func_names
    local -A omz_libs
    local omz_repo="$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH"

    for lib_f in "$omz_repo"/lib/*.zsh(.)
    do
        # List funcname in the library file
        func_names=( ${(@f)"$( \
            grep "^function" "$lib_f" \
            | sed 's/^function  *//g' \
            | sed 's/() {$//g' \
            | sed 's/ {$//g' \
            | grep -v " " \
            )"} )

        # Make list that consists of the funcname and filename
        for func_name in "${func_names[@]}"
        do
            omz_libs[$func_name]="$lib_f"
        done
    done

    target=( "$omz_repo/${1:?}"{.zsh-theme,/*.plugin.zsh}(N-.) )
    for lib_f in "${(k)omz_libs[@]}"
    do
        for t in "${target[@]}"
        do
            [[ -f $t ]] || continue
            sed '/^ *#/d' "$t" \
                | grep "$lib_f" \
                &>/dev/null &&
                depends+=( "$omz_libs[$lib_f]" )
        done
    done

    # Return dependency list
    for dep in "${depends[@]}"
    do
        echo "$dep"
    done
}

__omz_themes() {
    setopt prompt_subst
}
