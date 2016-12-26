__zplug::sources::gitlab::check()
{
    __zplug::sources::github::check "$argv[@]"
}

__zplug::sources::gitlab::install()
{
    __zplug::sources::github::install "$argv[@]"
}

__zplug::sources::gitlab::update()
{
    __zplug::sources::github::update "$argv[@]"
}

__zplug::sources::gitlab::get_url()
{
    local repo="$1" url_format

    case "$ZPLUG_PROTOCOL" in
        HTTPS | https)
            # https://git::@gitlab.com/%s.git
            url_format="https://git::@gitlab.com/${repo}.git"
            ;;
        SSH | ssh)
            # git@gitlab.com:%s.git
            url_format="git@gitlab.com:${repo}.git"
            ;;
    esac

    echo "$url_format"
}

__zplug::sources::gitlab::load_plugin()
{
    __zplug::sources::github::load_plugin "$argv[@]"
}

__zplug::sources::gitlab::load_command()
{
    __zplug::sources::github::load_command "$argv[@]"
}

__zplug::sources::gitlab::load_theme()
{
    __zplug::sources::github::load_theme "$argv[@]"
}
