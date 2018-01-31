__zplug::utils::releases::get_latest()
{
    local repo="$1"
    local cmd url

    url="https://github.com/$repo/releases/latest"
    if (( $+commands[curl] )); then
        cmd="command curl -fsSL"
    elif (( $+commands[wget] )); then
        cmd="command wget -qO -"
    fi

    eval "$cmd $url" \
        2>/dev/null \
        | grep -o '/'"$repo"'/releases/download/[^"]*' \
        | awk -F/ '{print $6}' \
        | sort \
        | uniq
}

__zplug::utils::releases::get_state()
{
    local state name="$1" dir="$2"

    if [[ "$(__zplug::utils::releases::get_latest "$name")" == "$(cat "$dir/INDEX" 2>/dev/null)" ]]; then
        state="up to date"
    else
        state="local out of date"
    fi

    case "$state" in
        "up to date")
            return $_zplug_status[up_to_date]
            ;;
        "local out of date")
            return $_zplug_status[out_of_date]
            ;;
        *)
            return $_zplug_status[unknown]
            ;;
    esac
}

__zplug::utils::releases::is_64()
{
    uname -m | grep -q "64$"
}

__zplug::utils::releases::is_arm()
{
    uname -m | grep -q "^arm"
}

__zplug::utils::releases::get_url()
{
    local    repo="$1" result
    local -A tags
    local    cmd url
    local    arch
    local -a candidates

    {
        tags[use]="$(
        __zplug::core::core::run_interfaces \
            'use' \
            "$repo"
        )"
        tags[at]="$(
        __zplug::core::core::run_interfaces \
            'at' \
            "$repo"
        )"

        #if [[ $tags[use] == '*.zsh' ]]; then
        #    tags[use]=
        #fi
        #if [[ $tags[at] == "master" ]]; then
        #    tags[at]="latest"
        #fi

        #if [[ -n $tags[at] && $tags[at != "latest" ]]; then
        #    tags[at]="tag/$tags[at"
        #else
        #    tags[at]="latest"
        #fi

        #if [[ -n $tags[use] ]]; then
        #    tags[use]="$(__zplug::utils::shell::glob2regexp "$tags[use")"
        #else
        #    tags[use]="$(__zplug::base::base::get_os)"
        #    if __zplug::base::base::is_osx; then
        #        tags[use]="(darwin|osx)"
        #    fi
        #fi
    }

    # Get machine information
    if __zplug::utils::releases::is_64; then
        arch="64"
    elif __zplug::utils::releases::is_arm; then
        arch="arm"
    else
        arch="386"
    fi

    url="https://github.com/$repo/releases/$tags[at]"
    if (( $+commands[curl] )); then
        cmd="command curl -fsSL"
    elif (( $+commands[wget] )); then
        cmd="command wget -qO -"
    fi

    candidates=(
    ${(@f)"$(
    eval "$cmd $url" \
        2>/dev/null \
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

    candidates=( $( echo "${(F)candidates[@]}" | grep -E "${tags[use]:-}" ) )
    if (( $#candidates > 1 )); then
        candidates=( $( echo "${(F)candidates[@]}" | grep "$arch" ) )
    fi
    result="${candidates[1]}"

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
        cmd="command curl -s -L -O"
    elif (( $+commands[wget] )); then
        cmd="command wget"
    fi

    (
    __zplug::utils::shell::cd \
        --force \
        "$tags[dir]"

    # Grab artifact from G-R
    eval "$cmd $url" \
        &>/dev/null

    __zplug::utils::releases::index \
        "$repo" \
        "$artifact" \
        &>/dev/null &&
        echo "$header" >|"$tags[dir]/INDEX"
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
                unzip "$artifact"
                rm -f "$artifact"
            ;;
        *.tar.bz2)
                tar jxvf "$artifact"
                rm -f "$artifact"
            ;;
        *.tar.gz|*.tgz)
                tar xvf "$artifact"
                rm -f "$artifact"
            ;;
        *.*)
            return 1
            ;;
        *)
            # Through
            ;;
    esac

    # TODO: more strictly
    binaries=()
    binaries+=(**/$cmd(N-.))   # contains files named exactly $cmd
    binaries+=(**/*$cmd*(N-.)) # contains $cmd name files
    binaries+=(**/*(N-*))      # contains executable files
    binaries+=( $(file **/*(N-.)  | awk -F: '$2 ~ /executable/{print $1}') )
    if (( $#binaries == 0 )); then
        # Failed to grab binaries from GitHub Releases"
        # TODO: logging
        return 1
    fi
    # For debug
    if (( $#binaries > 1 )); then
        __zplug::io::print::die "$cmd: Found ${(qqqj:,:)binaries[@]} in $repo\n"
    fi

    mv -f "$binaries[1]" "$cmd"
    chmod 755 "$cmd"
    rm -rf *~"$cmd"(N)

    if [[ ! -x $cmd ]]; then
        __zplug::io::print::die \
            "$repo: Failed to install\n"
        return 1
    fi

    __zplug::io::print::put \
        "$repo: Installed successfully\n"

    return 0
}
