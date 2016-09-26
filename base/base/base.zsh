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

__zplug::base::base::git_version()
{
    # Return false if git command doesn't exist
    if (( ! $+commands[git] )); then
        return 1
    fi

    __zplug::base::base::version_requirement \
        ${(M)${(z)"$(git --version)"}:#[0-9]*[0-9]} \
        "${@:?}"
    return $status
}

__zplug::base::base::zsh_version()
{
    __zplug::base::base::version_requirement \
        "$ZSH_VERSION" \
        "${@:?}"
    return $status
}

__zplug::base::base::osx_version()
{
    (( $+commands[sw_vers] )) || return 1
    __zplug::base::base::version_requirement \
        ${${(M)${(@f)"$(sw_vers)"}:#ProductVersion*}[2]} \
        "${@:?}"
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
