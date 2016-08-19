__zplug::utils::releases::get_latest()
{
    local repo="$1"
    local cmd url

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    url="https://github.com/$repo/releases/latest"
    if (( $+commands[curl] )); then
        cmd="curl -fsSL"
    elif (( $+commands[wget] )); then
        cmd="wget -qO -"
    fi

    eval "$cmd $url" \
        2> >(__zplug::io::log::capture) \
        | grep -o '/'"$repo"'/releases/download/[^"]*' \
        | awk -F/ '{print $6}' \
        | sort \
        | uniq
}

__zplug::utils::releases::get_state()
{
    local state name="$1" dir="$2"
    local url="https://github.com/$name/releases"

    if (( $# < 2 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    if [[ "$(__zplug::utils::releases::get_latest "$name")" == "$(cat "$dir/INDEX")" ]]; then
        state="up to date"
    else
        state="local out of date"
    fi

    case "$state" in
        "local out of date")
            state="${fg[red]}${state}${reset_color}"
            ;;
        "up to date")
            state="${fg[green]}${state}${reset_color}"
            ;;
    esac
    __zplug::io::print::put "($state) '${url:-?}'\n"
}

__zplug::utils::releases::is_64()
{
    uname -m | grep -q "64$"
}

__zplug::utils::releases::get_url()
{
    local    repo="$1" result
    local    tag_use tag_at cmd url
    local -i arch=386
    local -a candidates

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    {
        tag_use="$(
        __zplug::core::core::run_interfaces \
            'use' \
            "$repo"
        )"
        tag_at="$(
        __zplug::core::core::run_interfaces \
            'at' \
            "$repo"
        )"

        #if [[ $tag_use == '*.zsh' ]]; then
        #    tag_use=
        #fi
        #if [[ $tag_at == "master" ]]; then
        #    tag_at="latest"
        #fi

        #if [[ -n $tag_at && $tag_at != "latest" ]]; then
        #    tag_at="tag/$tag_at"
        #else
        #    tag_at="latest"
        #fi

        #if [[ -n $tag_use ]]; then
        #    tag_use="$(__zplug::utils::shell::glob2regexp "$tag_use")"
        #else
        #    tag_use="$(__zplug::base::base::get_os)"
        #    if __zplug::base::base::is_osx; then
        #        tag_use="(darwin|osx)"
        #    fi
        #fi
    }

    # Get machine information
    if __zplug::utils::releases::is_64; then
        arch="64"
    fi

    url="https://github.com/$repo/releases/$tag_at"
    if (( $+commands[curl] )); then
        cmd="curl -fsSL"
    elif (( $+commands[wget] )); then
        cmd="wget -qO -"
    fi

    candidates=(
    ${(@f)"$(
    eval "$cmd $url" \
        2> >(__zplug::io::log::capture) \
        | grep -o '/'"$repo"'/releases/download/[^"]*'
    )"}
    )
    if (( $#candidates == 0 )); then
        __zplug::io::print::f \
            --die \
            --zplug \
            "$repo: there are no available releases\n"
        return 1
    fi

    echo "${(F)candidates[@]}" \
        | grep -E "${tag_use:-}" \
        | grep "$arch" \
        | head -n 1 \
        | read result

    if [[ -z $result ]]; then
        __zplug::io::print::f \
            --die \
            --zplug \
            "$repo: repository not found\n"
        return 1
    fi

    echo "https://github.com$result"
}

__zplug::utils::releases::get()
{
    local    url="$1"
    local    repo dir header artifact cmd
    local -A tags

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    # make 'username/reponame' style
    repo="${url:s-https://github.com/--:F[4]h}"

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"
    header="${url:h:t}"
    artifact="${url:t}"

    if (( $+commands[curl] )); then
        cmd="curl -L -O"
    elif (( $+commands[wget] )); then
        cmd="wget"
    fi

    (
    __zplug::utils::shell::cd \
        --force \
        "$tags[dir]"

    # Grab artifact from G-R
    eval "$cmd $url" \
        2> >(__zplug::io::log::capture) >/dev/null

    __zplug::utils::releases::index \
        "$repo" \
        "$artifact" \
        2> >(__zplug::io::log::capture) >/dev/null &&
        echo "$header" >"$tags[dir]/INDEX"
    )

    return $status
}

__zplug::utils::releases::index()
{
    local    repo="$1" artifact="$2"
    local    cmd="${repo:t}"
    local -a binaries

    case "$artifact" in
        *.zip)
            {
                unzip "$artifact"
                rm -f "$artifact"
            } 2> >(__zplug::io::log::capture) >/dev/null
            ;;
        *.tar.gz|*.tgz)
            {
                tar xvf "$artifact"
                rm -f "$artifact"
            } 2> >(__zplug::io::log::capture) >/dev/null
            ;;
        *.*)
            __zplug::io::log::error \
                "$artifact: Unknown extension format"
            return 1
            ;;
        *)
            # Through
            ;;
    esac

    binaries=(
    $(
    file **/*(N-.) \
        | awk -F: '$2 ~ /executable/{print $1}'
    )
    )

    if (( $#binaries == 0 )); then
        __zplug::io::log::error \
            "$cmd: Failed to grab binaries from GitHub Releases"
        return 1
    fi

    {
        mv -f "$binaries[1]" "$cmd"
        chmod 755 "$cmd"
        rm -rf *~"$cmd"(N)
    } 2> >(__zplug::io::log::capture) >/dev/null

    if [[ ! -x $cmd ]]; then
        __zplug::io::print::die \
            "$repo: Failed to install\n"
        return 1
    fi

    __zplug::io::print::put \
        "$repo: Installed successfully\n"

    return 0
}
