__zplug::base::base::is_cli()
{
    # Return true if you run from cli
    [[ $- =~ s ]]
    return $status
}

__zplug::base::base::zpluged()
{
    local    arg="$1" zplug repo
    local -A zspec

    if [[ -z $arg ]]; then
        (( $+zplugs ))
        return $status
    else
        if [[ $arg == $_ZPLUG_OHMYZSH ]]; then
            for zplug in "${(k)zplugs[@]}"
            do
                __zplug::core::tags::parse "$zplug"
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

__zplug::base::base::version_requirement()
{
    local -i idx
    local -a min val
    local a="$1" op="$2" b="$3"

    [[ $a == $b ]] && return 0

    val=("${(s:.:)a}")
    min=("${(s:.:)b}")

    case "$op" in
        ">")
            for (( idx=1; idx <= $#val; idx++ ))
            do
                if (( val[$idx] > ${min[$idx]:-0} )); then
                    return 0
                elif (( val[$idx] < ${min[$idx]:-0} )); then
                    return 1
                fi
            done
            ;;
        "<")
            for (( idx=1; idx <= $#val; idx++ ))
            do
                if (( val[$idx] < ${min[$idx]:-0} )); then
                    return 0
                elif (( val[$idx] > ${min[$idx]:-0} )); then
                    return 1
                fi
            done
            ;;
        *)
            ;;
    esac

    return 1
}

__zplug::base::base::valid_semver()
{
    local prev="$1" next="$2"
    if [[ $prev == $next ]]; then
        # e.g. NG: prev 2.4.1, next 2.4.1
        return 1
    fi
    if __zplug::base::base::version_requirement "$prev" ">" "$next"; then
        # e.g. NG: prev 2.4.1, next 2.4.0
        return 1
    fi
    prev_elements=("${(s:.:)prev}")
    next_elements=("${(s:.:)next}")
    if (( $#next_elements != 3 )); then
        # e.g. NG: next 2.4
        return 1
    fi
    # TODO: more complex
    # prev_flat="${prev//./}"
    # next_flat="${next//./}"
    # if (( $(($next_flat - $prev_flat)) != 1 )); then
    #     # e.g. NG: prev 2.4.1, next 2.4.3
    #     return 1
    # fi
    return 0
}

__zplug::base::base::git_version()
{
    # Return false if git command doesn't exist
    if (( ! $+commands[git] )); then
        return 1
    fi

    __zplug::base::base::version_requirement \
        ${(M)${(z)"$(git --version)"}:#[0-9]*[0-9]} ">" "${@:?}"
    return $status
}

__zplug::base::base::zsh_version()
{
    __zplug::base::base::version_requirement \
        "$ZSH_VERSION" ">" "${@:?}"
    return $status
}

__zplug::base::base::osx_version()
{
    (( $+commands[sw_vers] )) || return 1
    __zplug::base::base::version_requirement \
        ${${(M)${(@f)"$(sw_vers)"}:#ProductVersion*}[2]} ">" "${@:?}"
    return $status
}

__zplug::base::base::get_os()
{
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

__zplug::base::base::is_osx()
{
    [[ ${(L)OSTYPE:-"$(uname)"} == *darwin* ]]
}

__zplug::base::base::is_linux()
{
    [[ ${(L)OSTYPE:-"$(uname)"} == *linux* ]]
}

__zplug::base::base::packaging()
{
    local k

    print -l "${(k)zplugs[@]}" \
        | awk \
        -f "$_ZPLUG_AWKPATH/packaging.awk" \
        -v pkg="${1:?}"
}
