__zplug::core::self::init()
{
    local repo="zplug/zplug"
    local src="$ZPLUG_REPOS/$repo/init.zsh"
    local dst="$ZPLUG_HOME/init.zsh"

    if [[ ! -f $src ]]; then
        __zplug::log::write::error \
            "$src: no such file or directory"
        return 1
    fi

    # Link
    ln -snf "$src" "$dst"
}

__zplug::core::self::update()
{
    local ret=0
    local HEAD

    if ! __zplug::base::base::zpluged "zplug/zplug"; then
        __zplug::io::print::f \
            --die \
            --zplug \
            "zplug/zplug: no package managed by zplug\n"
        return 1
    fi

    # If there is a difference in the remote and local
    # re-install zplug by itself and initialize
    if ! __zplug::core::self::info --up-to-date; then
        # TODO: "DONE"
        #__zplug::core::core::run_interfaces \
        #    "update" \
        #    "zplug/zplug"
        #    ^-- Leave these codes just in case for a while
        __zplug::sources::github::update "zplug/zplug"
        ret=$status
        if (( $ret == $_zplug_status[up_to_date] )); then
            ret=$_zplug_status[self_return]
        fi
        return $ret
    fi

    __zplug::core::self::info --HEAD \
        | read HEAD
    __zplug::io::print::f \
        --die \
        --zplug \
        "%s (v%s) %s\n" \
        "$fg[white]up-to-date$reset_color" \
        "$_ZPLUG_VERSION" \
        "$em[under]$HEAD[1,8]$reset_color"

    __zplug::log::write::info "zplug is up-to-date"
    return $_zplug_status[self_return]
}

__zplug::core::self::load()
{
    __zplug::core::self::init
}

__zplug::core::self::info()
{
    local    arg
    local -A revisions

    __zplug::utils::git::status "zplug/zplug"
    revisions=( "$reply[@]" )

    while (( $# > 0 ))
    do
        arg="$1"
        case "$arg" in
            --up-to-date)
                # local and origin/master are the same
                if [[ $revisions[local] == $revisions[master] ]]; then
                    return 0
                fi
                return 1
                ;;
            --local)
                echo "$revisions[local]"
                ;;
            --HEAD)
                echo "$revisions[master]"
                ;;
            --version)
                echo "$revisions[$_ZPLUG_VERSION^\{\}]"
                ;;
            -*|--*)
                return 1
                ;;
        esac
        shift
    done
}
