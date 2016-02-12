#!/bin/zsh

__is_cli() {
    [[ $- =~ s ]]
}

__zpluged() {
    local    arg zplug repo
    local -A zspec

    autoload -Uz __parser__
    arg="$1"

    if [[ -z $arg ]]; then
        (( $+zplugs ))
        return $status
    else
        if [[ $arg == $_ZPLUG_OHMYZSH ]]; then
            for zplug in "${(k)zplugs[@]}"
            do
                zspec=( ${(@f)"$(__parser__ "$zplug")"} )
                case "$zspec[from]" in
                    "oh-my-zsh")
                        return 0
                        ;;
                esac
            done
        else
            repo="$arg"
        fi
        (( $+zplugs[$repo] ))
        return $status
    fi
}

__get_autoload_dirs() {
    if (( $# > 0 )); then
        reply=("$@")
    else
        reply=(
        "$ZPLUG_ROOT/autoload/commands"
        "$ZPLUG_ROOT/autoload/utils"
        )
    fi
}

__get_autoload_paths() {
    local -a fs
    __get_autoload_dirs "$@"
    fs=( "${^reply[@]}"/__*(N-.) )
    (( $#fs > 0 )) && reply=( "${fs[@]}" )
}

__get_autoload_files() {
    __get_autoload_paths "$@"
    (( $#reply > 0 )) && reply=( "${reply[@]:t}" )
}

__get_filter() {
    local item x

    for item in "${(s.:.)1}"
    do
        x="${item%% *}"
        # Check if x is available
        if (( $+commands[$x] )); then
            echo "$x"
            return 0
        else
            continue
        fi
    done

    return 1
}

__version_requirement() {
    local -i idx
    local -a min val

    [[ $1 == $2 ]] && return 0

    val=("${(s:.:)1}")
    min=("${(s:.:)2}")

    for (( idx=1; idx <= $#val; idx++ ))
    do
        if (( val[$idx] > ${min[$idx]:-0} )); then
            return 0
        elif (( val[$idx] < ${min[$idx]:-0} )); then
            return 1
        fi
    done

    return 1
}

__git_version() {
    __version_requirement ${(M)${(z)"$(git --version)"}:#[0-9]*[0-9]} "${@:?}"
    return $status
}

__zsh_version() {
    __version_requirement "$ZSH_VERSION" "${@:?}"
    return $status
}

__osx_version() {
    (( $+commands[sw_vers] )) || return 1
    __version_requirement ${${(M)${(@f)"$(sw_vers)"}:#ProductVersion*}[2]} "${@:?}"
    return $status
}

__get_os() {
    typeset -gx PLATFORM
    local os

    os="${(L)OSTYPE-"$(uname)"}"
    case "$os" in
        *'linux'*)  PLATFORM='linux'   ;;
        *'darwin'*) PLATFORM='darwin'  ;;
        *'bsd'*)    PLATFORM='bsd'     ;;
        *)          PLATFORM='unknown' ;;
    esac

    echo "$PLATFORM"
}

__is_osx() {
    [[ ${(L)OSTYPE:-"$(uname)"} == *darwin* ]]
}

__is_linux() {
    [[ ${(L)OSTYPE:-"$(uname)"} == *linux* ]]
}

__glob2regexp() {
    local -i i=0
    local    glob="${1:?}" char

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

__remove_deadlinks() {
    local link

    for link in "$@"
    do
        if [[ -L $link ]] && [[ ! -e $link ]]; then
            rm -f "$link"
        fi
    done
}

__packaging() {
    local k

    for k in "${(k)zplugs[@]}"
    do
        echo "$k"
    done \
        | awk \
        -f "$ZPLUG_ROOT/src/share/packaging.awk" \
        -v pkg="${1:?}"
}
