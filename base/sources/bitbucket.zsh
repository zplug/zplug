__zplug::sources::bitbucket::check()
{
    __zplug::sources::github::check "$argv[@]"
}

__zplug::sources::bitbucket::install()
{
    __zplug::sources::github::install "$argv[@]"
}

__zplug::sources::bitbucket::update()
{
    __zplug::sources::github::update "$argv[@]"
}

__zplug::sources::bitbucket::get_url()
{
    local repo="$1" url_format

    case "$ZPLUG_PROTOCOL" in
        HTTPS | https)
            # https://git::@bitbucket.org/%s.git
            url_format="https://git::@bitbucket.org/${repo}.git"
            ;;
        SSH | ssh)
            # git@bitbucket.org:%s.git
            url_format="git@bitbucket.org:${repo}.git"
            ;;
    esac

    echo "$url_format"
}

__zplug::sources::bitbucket::load_plugin()
{
    __zplug::sources::github::load_plugin "$argv[@]"
}

__zplug::sources::bitbucket::load_command()
{
    __zplug::sources::github::load_command "$argv[@]"
}

__zplug::sources::bitbucket::load_theme()
{
    __zplug::sources::github::load_theme "$argv[@]"
}
