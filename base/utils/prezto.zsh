__zplug::utils::prezto::depends()
{
    local       module="$1"
    local -a -U dependencies
    local       prezto_repo="$ZPLUG_REPOS/$_ZPLUG_PREZTO"

    dependencies=()

    # Note: Probably the only match is init.zsh, but just in case
    for module_f in "$prezto_repo"/modules/$module/*.zsh(N)
    do
        dependencies+=( ${(@s: :)"$( \
            grep "\bpmodload\b" "$module_f" 2>/dev/null \
                | sed 's/pmodload *'// \
                | sed "s/['\"]//g"
                )"} )
    done

    for dep in "${dependencies[@]}"
    do
        echo "$dep"
    done
}
