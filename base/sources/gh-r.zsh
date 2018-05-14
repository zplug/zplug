__zplug::sources::gh-r::check()
{
    local    repo="$1"
    local -A tags

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"

    # Repo's directory is not found and
    # INDEX file is not found
    if [[ ! -d $tags[dir] ]] && [[ ! -f $tags[dir]/INDEX ]]; then
        return 1
    fi

    return 0
}

__zplug::sources::gh-r::install()
{
    local repo="$1" url

    url="$(
    __zplug::utils::releases::get_url \
        "$repo"
    )"

    __zplug::utils::releases::get "$url"

    return $status
}

__zplug::sources::gh-r::update()
{
    local repo="$1" index url
    local -A tags

    tags[dir]="$(__zplug::core::core::run_interfaces 'dir' "$repo")"
    tags[use]="$(__zplug::core::core::run_interfaces 'use' "$repo")"
    tags[at]="$(__zplug::core::core::run_interfaces 'at' "$repo")"

    __zplug::utils::shell::cd \
        "$tags[dir]" || return $_zplug_status[repo_not_found]

    url="$(
    __zplug::utils::releases::get_url \
        "$repo"
    )"

    if [[ -d $tags[dir] ]]; then
        # Update
        if [[ -f $tags[dir]/INDEX ]]; then
            index="$(command cat "$tags[dir]/INDEX" 2>/dev/null)"
            if [[ $tags[at] == "latest" ]]; then
                if grep -q "$index" <<<"$url"; then
                    # up-to-date
                    return $_zplug_status[up_to_date]
                else
                    __zplug::sources::gh-r::install "$repo"
                    return $status
                fi
            else
                # up-to-date
                return $_zplug_status[up_to_date]
            fi
        fi
    else
        return $_zplug_status[repo_not_found]
    fi

    return $_zplug_status[success]
}

__zplug::sources::gh-r::load_command()
{
    __zplug::sources::github::load_command "$argv[@]"
}
