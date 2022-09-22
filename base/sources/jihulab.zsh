__zplug::sources::jihulab::check()
{
    __zplug::sources::github::check "$argv[@]"
}

__zplug::sources::jihulab::install()
{
    __zplug::sources::github::install "$argv[@]"
}

__zplug::sources::jihulab::update()
{
    __zplug::sources::github::update "$argv[@]"
}

__zplug::sources::jihulab::get_url()
{
    local repo="$1" url_format

    case "$ZPLUG_PROTOCOL" in
        HTTPS | https)
            # https://git::@jihulab.com/%s.git
            url_format="https://git::@jihulab.com/${repo}.git"
            ;;
        SSH | ssh)
            # git@jihulab.com:%s.git
            url_format="git@jihulab.com:${repo}.git"
            ;;
    esac

    echo "$url_format"
}

__zplug::sources::jihulab::load_plugin()
{
    __zplug::sources::github::load_plugin "$argv[@]"
}

__zplug::sources::jihulab::load_command()
{
    __zplug::sources::github::load_command "$argv[@]"
}

__zplug::sources::jihulab::load_theme()
{
    __zplug::sources::github::load_theme "$argv[@]"
}
