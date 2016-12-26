__zplug::utils::omz::depends()
{
    local       lib_f func_name dep
    local -a    target
    local -a -U depends
    local -a    func_names
    local -A    omz_libs
    local       omz_repo="$ZPLUG_REPOS/$_ZPLUG_OHMYZSH"

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

    target=( "$omz_repo/$1"{.zsh-theme,/*.plugin.zsh}(N-.) )
    for lib_f in "${(k)omz_libs[@]}"
    do
        for t in "${target[@]}"
        do
            [[ -f $t ]] || continue
            sed '/^ *#/d' "$t" \
                | egrep "(^|\s|['\"(\`])$lib_f($|\s|[\\\\'\")\`])" \
                2> >(__zplug::log::capture::error) >/dev/null &&
                depends+=( "$omz_libs[$lib_f]" )
        done
    done

    # Return dependency list
    print -l "${depends[@]}"
}
