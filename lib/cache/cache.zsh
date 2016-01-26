#!/bin/zsh

__tags_for_cache() {
    local key

    for key in ${(k)zplugs}
    do
        echo "name:$key, $zplugs[$key]"
    done \
        | awk -f "$ZPLUG_ROOT/src/share/cache.awk"
}

__load_cache() {
    local key

    $ZPLUG_USE_CACHE || return 2
    if [[ -f $_ZPLUG_CACHE_FILE ]]; then
        &>/dev/null diff -b \
            <( \
            awk -f "$ZPLUG_ROOT/src/share/read_cache.awk" \
            "$_ZPLUG_CACHE_FILE" \
            ) \
            <( \
            for key in ${(k)zplugs}; do \
                echo "name:$key, $zplugs[$key]"; \
            done \
            | awk -f "$ZPLUG_ROOT/src/share/cache.awk"
        )

        case $status in
            0)
                # same
                source "$_ZPLUG_CACHE_FILE"
                return $status
                ;;
            1)
                # differ
                ;;
            2)
                # error
                __die "zplug: cache: something wrong\n"
                ;;
        esac
    fi

    return 1
}
