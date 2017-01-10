__zplug::utils::git::clone()
{
    local    repo="$1"
    local    depth_option url_format
    local -i ret=1
    local -A tags default_tags

    # A validation of ZPLUG_PROTOCOL
    # - HTTPS (recommended)
    # - SSH
    if [[ ! $ZPLUG_PROTOCOL =~ ^(HTTPS|https|SSH|ssh)$ ]]; then
        __zplug::io::print::f \
            --die \
            --zplug \
            --error \
            "ZPLUG_PROTOCOL is an invalid protocol.\n"
        return 1
    fi

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    if [[ -d $tags[dir] ]]; then
        return $_zplug_status[already]
    fi

    if [[ $tags[depth] == 0 ]]; then
        depth_option=""
    else
        depth_option="--depth=$tags[depth]"
    fi

    # If an 'at' tag has been specified, do a deep clone to allow any commit to be
    # checked out.
    default_tags[at]="$(
    __zplug::core::core::run_interfaces \
        'at'
    )"
    if [[ $tags[at] != $default_tags[at] ]]; then
        depth_option=""
    fi

    # Assemble a URL for cloning from its handler
    if __zplug::core::sources::is_handler_defined "get_url" "$tags[from]"; then
        __zplug::core::sources::use_handler \
            "get_url" \
            "$tags[from]" \
            "$repo" \
            | read url_format

        if [[ -z $url_format ]]; then
            __zplug::io::print::f \
                --die \
                --zplug \
                --error \
                "$repo is an invalid 'user/repo' format.\n"
            return 1
        fi

        GIT_TERMINAL_PROMPT=0 \
            git clone \
            --quiet \
            --recursive \
            ${=depth_option} \
            "$url_format" "$tags[dir]" \
            2> >(__zplug::log::capture::error) >/dev/null
        ret=$status
    fi

    # The revison (hash/branch/tag) lock
    # NOTE: Since it's logged in `__zplug::utils::git::checkout` function,
    # there is no problem even if it's discarded /dev/null file here
    __zplug::utils::git::checkout "$repo" &>/dev/null

    if (( $ret == 0 )); then
        return $_zplug_status[success]
    else
        return $_zplug_status[failure]
    fi
}

__zplug::utils::git::checkout()
{
    local    repo="$1"
    local -a do_not_checkout
    local -A tags
    local    lock_name

    tags[at]="$(__zplug::core::core::run_interfaces 'at' "$repo")"
    tags[dir]="$(__zplug::core::core::run_interfaces 'dir' "$repo")"
    tags[from]="$(__zplug::core::core::run_interfaces 'from' "$repo")"

    do_not_checkout=( "gh-r" )
    if [[ ! -d $tags[dir]/.git ]]; then
        do_not_checkout+=( "local" )
    fi

    if (( $do_not_checkout[(I)$tags[from]] )); then
        return 0
    fi

    # Try not to be affected by directory changes
    # by running in subshell
    (
    # For doing `git checkout`
    if ! __zplug::utils::shell::cd "$tags[dir]"; then
        __zplug::io::print::f \
            --die \
            --zplug \
            --error \
            "no such directory '$tags[dir]' ($repo)\n"
        return 1
    fi

    if ! __zplug::utils::git::have_cloned; then
        return 0
    fi

    lock_name="${(j:/:)${(s:/:)tags[dir]}[-2, -1]}"
    if (( $_zplug_checkout_locks[(I)${lock_name}] )); then
        return 0
    fi

    # Acquire lock
    _zplug_checkout_locks+=( $lock_name )

    git checkout -q "$tags[at]" \
        2> >(__zplug::log::capture::error) >/dev/null

    # Release lock
    _zplug_checkout_locks=( ${_zplug_checkout_lock:#${lock_name}} )

    if (( $status != 0 )); then
        __zplug::io::print::f \
            --die \
            --zplug \
            --error \
            "pathspec '$tags[at]' (at tag) did not match ($repo)\n"
    fi
    )
}

__zplug::utils::git::have_cloned()
{
    git rev-parse --is-inside-work-tree &>/dev/null &&
        [[ "$(git rev-parse HEAD 2>/dev/null)" != "HEAD" ]]
}

# TODO:
# - __zplug::utils::git::fetch
# - __zplug::utils::git::pull
__zplug::utils::git::merge()
{
    local    key value
    local    opt arg
    local    failed=false
    local -A git

    __zplug::utils::shell::getopts "$argv[@]" \
        | while read key value; \
    do
        case "$key" in
            dir)
                git[dir]="$value"
                ;;
            branch)
                git[branch]="$value"
                ;;
            repo)
                git[repo]="$value"
                ;;
        esac
    done

    __zplug::utils::shell::cd \
        "$git[dir]" || return $_zplug_status[repo_not_found]

    {
        if [[ -e $git[dir]/.git/shallow ]]; then
            git fetch --unshallow
        else
            git fetch
        fi
        git checkout -q "$git[branch]"
    } 2> >(__zplug::log::capture::error) >/dev/null

    __zplug::utils::git::get_state
    case "$status" in
        $_zplug_status[not_on_branch])
            # detached HEAD (due to revision lock with at tag)
            return $_zplug_status[revision_lock]
            ;;
    esac

    git[local]="$(git rev-parse HEAD)"
    git[upstream]="$(git rev-parse "@{upstream}" 2> >(__zplug::log::capture::error))"
    git[base]="$(git merge-base HEAD "@{upstream}" 2> >(__zplug::log::capture::error))"

    if [[ -z $git[upstream] || -z $git[base] ]]; then
        # > git merge-base HEAD "@{upstream}
        # >fatal: HEAD does not point to a branch
        # the same status as $_zplug_status[revision_lock]
        # but return as detached_head explicitly
        return $_zplug_status[detached_head]
    fi

    if [[ $git[local] == $git[upstream] ]]; then
        # up-to-date
        return $_zplug_status[up_to_date]

    elif [[ $git[local] == $git[base] ]]; then
        # need to pull
        {
            git reset --hard HEAD
            git merge --ff-only "origin/$git[branch]"
            if (( $status != 0 )); then
                failed=true
            fi
            git submodule update --init --recursive
            if (( $status != 0 )); then
                failed=true
            fi
        } 2> >(__zplug::log::capture::error) >/dev/null

    elif [[ $git[upstream] == $git[base] ]]; then
        # need to push
        failed=true

    else
        # Diverged (e.g. conflicts)
        __zplug::utils::shell::cd "$HOME"
        rm -rf "$git[dir]"
        __zplug::core::core::run_interfaces \
            "install" \
            "$git[repo]" &>/dev/null
    fi

    if $failed; then
        return $_zplug_status[failure]
    fi
    return $_zplug_status[success]
}

__zplug::utils::git::status()
{
    local    repo="$1"
    local    key val line
    local -A tags revisions

    git ls-remote --heads --tags https://github.com/"$repo".git \
        | awk '{print $2,$1}' \
        | sed -E 's@^refs/(heads|tags)/@@g' \
        | while read line; do
            key=${${(s: :)line}[1]}
            val=${${(s: :)line}[2]}
            revisions[$key]="$val"
        done

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"

    # TODO: git rev-parse
    git \
        --git-dir="$tags[dir]/.git" \
        --work-tree="$tags[dir]" \
        log \
        --oneline \
        --pretty="format:%H" \
        --max-count=1 \
        | read val
    revisions[local]="$val"

    reply=( "${(kv)revisions[@]}" )
}

__zplug::utils::git::get_head_branch_name()
{
    local head_branch

    if __zplug::base::base::git_version 1.7.10; then
        head_branch="$(git symbolic-ref -q --short HEAD)"
    else
        head_branch="${$(git symbolic-ref -q HEAD)#refs/heads/}"
    fi

    if [[ -z $head_branch ]]; then
        git rev-parse --short HEAD
        return 1
    fi
    printf "$head_branch\n"
}

__zplug::utils::git::get_remote_name()
{
    local branch="$1" remote_name

    remote_name="$(git config branch.${branch}.remote)"
    if [[ -z $remote_name ]]; then
        __zplug::log::write::error \
            "no remote repository"
        return 1
    fi

    echo "$remote_name"
}

__zplug::utils::git::get_remote_state()
{
    local    remote_name branch
    local    merge_branch remote_show
    local    state url
    local -a behind_ahead
    local -i behind ahead

    branch="$1"
    remote_name="$(__zplug::utils::git::get_remote_name "$branch")"

    if (( $status == 0 )); then
        merge_branch="${$(git config branch.${branch}.merge)#refs/heads/}"
        remote_show="$(git remote show "$remote_name")"
        state="$(grep "^ *$branch *pushes" <<<"$remote_show" | sed 's/.*(\(.*\)).*/\1/')"

        if [[ -z $state ]]; then
            behind_ahead=( ${(@f)"$(git rev-list \
                --left-right \
                --count \
                "$remote_name/$merge_branch"...$branch)"} )
            behind=$behind_ahead[1]
            ahead=$behind_ahead[2]

            if (( $behind > 0 )); then
                state="local out of date"
            else
                origin_head="${$(git ls-remote origin HEAD)[1]}"

                git rev-parse -q "$origin_head" \
                    2> >(__zplug::log::capture::error) >/dev/null
                if (( $status != 0 )); then
                    state="local out of date"
                elif (( $ahead > 0 )); then
                    state="fast-forwardable"
                else
                    state="up to date"
                fi
            fi
        fi

        url="$(grep '^ *Push' <<<"$remote_show" | sed 's/^.*URL: \(.*\)$/\1/')"
    else
        state="$remote_name"
    fi

    echo "$state"
    echo "$url"
}

__zplug::utils::git::get_state()
{
    local    branch
    local -a res
    local    state url

    if [[ ! -e .git ]]; then
        return $_zplug_status[not_git_repo]
    fi

    state="not on any branch"
    branch="$(__zplug::utils::git::get_head_branch_name)"
    if (( $status == 0 )); then
        res=( ${(@f)"$(__zplug::utils::git::get_remote_state "$branch")"} )
        state="$res[1]"
        url="$res[2]"
    fi

    case "$state" in
        "up to date")
            return $_zplug_status[up_to_date]
            ;;
        "local out of date")
            return $_zplug_status[out_of_date]
            ;;
        "not on any branch")
            return $_zplug_status[not_on_branch]
            ;;
        *)
            return $_zplug_status[unknown]
            ;;
    esac
}

__zplug::utils::git::remote_url()
{
    # Check if it has git directory
    [[ -e .git ]] || return 1

    git remote -v \
        | sed -n '1p' \
        | awk '{print $2}'
}
