__zplug::sources::gist::check()
{
    __zplug::sources::github::check "$argv[@]"
}

__zplug::sources::gist::install()
{
    __zplug::sources::github::install "$argv[@]"
}

__zplug::sources::gist::update()
{
    __zplug::sources::github::update "$argv[@]"
}

__zplug::sources::gist::get_url()
{
    local repo="$1" url_format

    case "$ZPLUG_PROTOCOL" in
        HTTPS | https)
            # https://git::@github.com/%s.git
            url_format="https://git::@gist.github.com/${repo}.git"

            if __zplug::base::base::git_version 2.3; then
                # (git 2.3+) https://gist.github.com/%s.git
                export GIT_TERMINAL_PROMPT=0
                url_format="https://gist.github.com/${repo}.git"
            fi
            ;;
        SSH | ssh)
            # git@github.com:%s.git
            url_format="git@gist.github.com:${repo}.git"
            ;;
    esac

    echo "$url_format"
}

__zplug::sources::gist::load_plugin()
{
    __zplug::sources::github::load_plugin "$@"
}

__zplug::sources::gist::load_command()
{
    __zplug::sources::github::load_command "$@"
}

__zplug::sources::gist::load_theme()
{
    __zplug::sources::github::load_theme "$argv[@]"
}
