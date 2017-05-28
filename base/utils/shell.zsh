__zplug::utils::shell::remove_deadlinks()
{
    local link

    for link in "$@"
    do
        if [[ -L $link ]] && [[ ! -e $link ]]; then
            rm -f "$link"
        fi
    done
}

__zplug::utils::shell::search_commands()
{
    local -a args
    local    arg element cmd_name
    local    is_verbose=true

    while (( $# > 0 ))
    do
        arg="$1"
        case "$arg" in
            --verbose)
                is_verbose=true
                ;;
            --silent)
                is_verbose=false
                ;;
            -*|--*)
                return 1
                ;;
            *)
                args+=( "$arg" )
                ;;
        esac
        shift
    done

    for arg in "${args[@]}"
    do
        for element in "${(s.:.)arg}"
        do
            # Extract the first argument sparated by a space
            cmd_name="${element%% *}"

            # Check if cmd_name is available
            if (( $+commands[$cmd_name] )); then
                if $is_verbose; then
                    echo "$cmd_name"
                fi
                return 0
            else
                continue
            fi
        done
    done

    return 1
}

__zplug::utils::shell::glob2regexp()
{
    local -i i=0
    local    glob="$1" char

    printf "^"
    for ((; i < $#glob; i++))
    do
        char="${glob:$i:1}"
        case "$char" in
            \*)
                printf '.*'
                ;;
            .)
                printf '\.'
                ;;
            "{")
                printf '('
                ;;
            "}")
                printf ')'
                ;;
            ,)
                printf '|'
                ;;
            "?")
                printf '.'
                ;;
            \\)
                printf '\\\\'
                ;;
            *)
                printf "$char"
                ;;
        esac
    done
    printf "$\n"
}

__zplug::utils::shell::sudo()
{
    local pw="$ZPLUG_SUDO_PASSWORD"

    if [[ -z $pw ]]; then
        __zplug::log::write::error \
            "ZPLUG_SUDO_PASSWORD: is an invalid value\n"
        return 1
    fi

    sudo -k
    echo "$pw" \
        | sudo -S -p '' "$argv[@]"
}

__zplug::utils::shell::unansi()
{
    perl -pe 's/\e\[?.*?[\@-~]//g'
}

__zplug::utils::shell::cd()
{
    local    dir arg
    local -a dirs
    local    is_force=false

    while (( $# > 0 ))
    do
        arg="$1"
        case "$arg" in
            --force)
                is_force=true
                ;;
            -*|--*)
                return 1
                ;;
            "")
                ;;
            *)
                dirs+=( "$arg" )
                ;;
        esac
        shift
    done

    for dir in "$dirs[@]"
    do
        if $is_force; then
            [[ -d $dir ]] || mkdir -p "$dir"
        fi

        builtin cd "$dir" &>/dev/null
        return $status
    done

    return 1
}

__zplug::utils::shell::getopts()
{
    printf "%s\n" "$argv[@]" \
        | awk -f "$ZPLUG_ROOT/misc/contrib/getopts.awk"
}

__zplug::utils::shell::pipestatus()
{
    local _status="${pipestatus[*]-}"

    [[ ${_status//0 /} == 0 ]]
    return $status
}

__zplug::utils::shell::expand_glob()
{
    local    pattern="$1" file
    # Modifiers to use if $pattern does not include modifiers
    local    default_modifiers="${2:-(N)}"
    local -a matches

    # Modifiers not specified (by user)
    if [[ ! $pattern =~ '[^/]\([^)]*\)$' ]]; then
        pattern+="$default_modifiers"
    fi

    # Try expanding ~ and *
    matches=( ${~pattern} )

    # Use subshell for brace expansion
    if (( $#matches <= 1 )); then
        matches=( $( \
            zsh -c "$_ZPLUG_CONFIG_SUBSHELL; echo $pattern" \
            2> >(__zplug::log::capture::error) \
        ) )
    fi

    for file in "${matches[@]}"
    do
        [[ -e ${~file} ]] && echo ${~file}
    done
}

__zplug::utils::shell::zglob()
{
    (
    emulate -RL zsh
    setopt localoptions extendedglob
    local    f g match mbegin mend p_dir1 p_dir2
    local    MATCH MBEGIN MEND
    local    pat repl fpat
    local -a files targets
    local -A from to

    p_dir1=${~1:h}
    p_dir2=${~2:h}
    builtin cd $p_dir1
    pat=${1:t}
    repl=${2:t}
    shift 2

    if [[ $pat = (#b)(*)\((\*\*##/)\)(*) ]]; then
        fpat="$match[1]$match[2]$match[3]"
        setopt localoptions bareglobqual
        fpat="${fpat}(odon)"
    else
        fpat=$pat
    fi

    files=(${~fpat}(N))
    for f in $files[@]
    do
        if [[ $pat = (#b)(*)\(\*\*##/\)(*) ]]; then
            pat="$match[1](*/|)$match[2]"
        fi
        [[ -e $f && $f = (#b)${~pat} ]] || continue
        set -- "$match[@]"
        g=${(Xe)repl} 2>/dev/null
        from[$g]=$f
        to[$f]=$g
    done

    for f in $files[@]
    do
        [[ -z $to[$f] ]] && continue
        targets=($p_dir1/$f $p_dir2/$to[$f])
        print -r -- ${(q-)targets}
    done
    )
}

__zplug::utils::shell::eval()
{
    local cmd

    # Report stderr to error log
    eval "${=cmd}" 2> >(__zplug::log::capture::error) >/dev/null
    return $status
}

__zplug::utils::shell::json_escape()
{
    if (( $+commands[python] )) && python -c 'import json' 2> /dev/null; then
        python -c '
from __future__ import print_function
import json,sys
print(json.dumps(sys.stdin.read()))' \
    2> >(__zplug::log::capture::error)
    else
        echo "(Not available: python with json required)"
    fi
}

__zplug::utils::shell::is_atty()
{
    if [[ -t 0 && -t 1 ]]; then
        # terminal
        return 0
    else
        # pipeline
        return 1
    fi
}
