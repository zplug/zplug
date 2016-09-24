#!/bin/zsh

__zplug::sources::prezto::check()
{
    local    repo="$1"
    local -A tags

    tags[dir]="$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )"

    [[ -n $tags[dir] ]] && [[ -d $tags[dir] ]]
    return $status
}

__zplug::sources::prezto::install()
{
    local repo="$1"

    # Already cloned
    if __zplug::sources::prezto::check "$repo"; then
        return 0
    fi

    __zplug::utils::git::clone \
        "$_ZPLUG_PREZTO"
    return $status
}

__zplug::sources::prezto::update()
{
    local    repo="$1"
    local -A tags

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    tags[dir]="${$(
    __zplug::core::core::run_interfaces \
        'dir' \
        "$repo"
    )}"
    tags[at]="$(
    __zplug::core::core::run_interfaces \
        'at' \
        "$repo"
    )"

    __zplug::utils::git::merge \
        --dir    "$tags[dir]" \
        --branch "$tags[at]"

    return $status
}

__zplug::sources::prezto::get_url()
{
    __zplug::sources::github::get_url "$_ZPLUG_PREZTO"
}

__zplug::sources::prezto::load_plugin()
{
    local    repo="$1"
    local -A tags
    local -a load_fpaths
    local -a load_plugins
    local -a lazy_plugins
    local    module_name

    if (( $# < 1 )); then
        __zplug::io::log::error \
            "too few arguments"
        return 1
    fi

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    load_fpaths=()
    load_plugins=()
    lazy_plugins=()

    module_name="${tags[name]#*/}"

    if [[ ! -d $tags[dir] ]]; then
        zstyle ":prezto:module:$module_name" loaded "no"
        return 1
    fi

    if (( ! $+functions[pmodload] )) {
        pmodload() {
            # Do nothing
        }
    }

    for dependency in ${(@f)"$( __zplug::utils::prezto::depends "$module_name" )"}
    do
        load_plugins+=( "$tags[dir]/modules/$dependency/"init.zsh(N-.) )
    done

    if [[ $tags[use] != '*.zsh' ]]; then
        load_plugins+=( "$tags[dir]/"${~tags[use]}(N-.) )
    elif [[ -f $tags[dir]/$tags[name]/init.zsh ]]; then
        load_plugins+=( "$tags[dir]/$tags[name]/"init.zsh(N-.) )
    fi

    # Add functions directory to FPATH if it exists
    if [[ -d $tags[dir]/$tags[name]/functions ]]; then
        load_fpaths+=( "$tags[dir]/$tags[name]"/functions(N-/) )

        # autoload functions
        # Taken from prezto's init.zsh
        function {
            setopt local_options extended_glob

            local pfunction_glob='^([_.]*|prompt_*_setup|README*)(-.N:t)'
            lazy_plugins=( "$tags[dir]/$tags[name]/functions/"$~pfunction_glob )
        }
    fi

    zstyle ":prezto:module:$module_name" loaded "yes"

    if [[ $TERM == dumb ]]; then
        zstyle ":prezto:*:*" color "no"
        zstyle ":prezto:module:prompt" theme "off"
    fi

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_plugins ]] && reply+=( load_plugins "${(F)load_plugins}" )
    [[ -n $lazy_plugins ]] && reply+=( lazy_plugins "${(F)lazy_plugins}" )

    return 0
}
