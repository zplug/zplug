#!/usr/bin/env zsh

__zplug::core::core::is_cli() {
    [[ $- =~ s ]]
}

__zplug::core::core::is_external() {
    local source_name

    source_name="${1:?}"
    [[ -f $ZPLUG_ROOT/base/sources/$source_name.zsh ]]
}

__zplug::core::core::is_handler_defined() {
    local subcommand
    local source_name
    local handler_name

    subcommand="${1:?}"
    source_name="${2:?}"
    handler_name="__zplug::$source_name::$subcommand"

    if ! __zplug::core::core::is_external "$source_name"; then
        return 1
    fi

    (( $+functions[$handler_name] ))
}

__zplug::core::core::zpluged() {
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
                __parser__ "$zplug"
                zspec=( "${reply[@]}" )
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

__zplug::core::core::get_autoload_dirs() {
    if (( $# > 0 )); then
        reply=("$@")
    else
        reply=(
        "$ZPLUG_ROOT/autoload/commands"
        "$ZPLUG_ROOT/autoload/options"
        "$ZPLUG_ROOT/autoload/tags"
        "$ZPLUG_ROOT/autoload/utils"
        )
    fi
}

__zplug::core::core::get_autoload_paths() {
    local -a fs
    __zplug::core::core::get_autoload_dirs "$@"
    fs=( "${^reply[@]}"/__*(N-.) )
    (( $#fs > 0 )) && reply=( "${fs[@]}" )
}

__zplug::core::core::get_autoload_files() {
    __zplug::core::core::get_autoload_paths "$@"
    (( $#reply > 0 )) && reply=( "${reply[@]:t}" )
}

__zplug::core::core::get_tags() {
    reply=( "$ZPLUG_ROOT/autoload/tags/"__*__(:t:gs:__:) )
}

__zplug::core::core::get_filter() {
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

__zplug::core::core::version_requirement() {
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

__zplug::core::core::git_version() {
    __zplug::core::core::version_requirement \
        ${(M)${(z)"$(git --version)"}:#[0-9]*[0-9]} \
        "${@:?}"
    return $status
}

__zplug::core::core::zsh_version() {
    __zplug::core::core::version_requirement \
        "$ZSH_VERSION" \
        "${@:?}"
    return $status
}

__zplug::core::core::osx_version() {
    (( $+commands[sw_vers] )) || return 1
    __zplug::core::core::version_requirement \
        ${${(M)${(@f)"$(sw_vers)"}:#ProductVersion*}[2]} \
        "${@:?}"
    return $status
}

__zplug::core::core::get_os() {
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

__zplug::core::core::is_osx() {
    [[ ${(L)OSTYPE:-"$(uname)"} == *darwin* ]]
}

__zplug::core::core::is_linux() {
    [[ ${(L)OSTYPE:-"$(uname)"} == *linux* ]]
}

__zplug::core::core::glob2regexp() {
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

__zplug::core::core::remove_deadlinks() {
    local link

    for link in "$@"
    do
        if [[ -L $link ]] && [[ ! -e $link ]]; then
            rm -f "$link"
        fi
    done
}

__zplug::core::core::packaging() {
    local k

    for k in "${(k)zplugs[@]}"
    do
        echo "$k"
    done \
        | awk \
        -f "$ZPLUG_ROOT/misc/share/packaging.awk" \
        -v pkg="${1:?}"
}

# Call the handler of the external source if defined
__zplug::core::core::use_handler() {
    local subcommand
    local source_name
    local handler_name
    local line

    subcommand="${1:?}"
    source_name="${2:?}"
    handler_name="__zplug::$source_name::$subcommand"
    line="${3:?}"

    if ! __zplug::core::core::is_handler_defined "$subcommand" "$source_name"; then
        # Callback function undefined
        return 1
    fi

    eval "$handler_name '$line'"

    return $status
}
