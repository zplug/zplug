__zplug::base()
{
    local     load_file arg
    local -aU load_files

    while (( $# > 0 ))
    do
        arg="$1"
        case "$arg" in
            -*|--*)
                return 1
                ;;
            */'*')
                # e.g. 'base/*'
                load_files+=( "$ZPLUG_ROOT/base/${arg:h}"/*.zsh(N-.) )
                ;;
            */*)
                # e.g. 'core/add'
                load_files+=( "$ZPLUG_ROOT/base/${arg}.zsh"(N-.) )
                ;;
            *)
                return 1
                ;;
        esac
        shift
    done

    # invalid format
    if (( $#load_files == 0 )); then
        return 1
    fi

    fpath=(
    "${load_files[@]:h}"
    "${fpath[@]}"
    )

    for load_file in "${load_files[@]}"
    do
        if (( $+functions[$load_file] )); then
            # already defined
            continue
        fi

        autoload -Uz "${load_file:t}" &&
            eval "${load_file:t}"     &&
            unfunction "${load_file:t}"
    done
}
