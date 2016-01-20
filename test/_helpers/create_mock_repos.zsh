#!/bin/zsh

[[ -z $ZPLUG_ROOT ]] && return 1

create_mock_repo() {
    local pkg dir
    local user repo
    local opt

    for opt in "$@"
    do
        case "$opt" in
            --plugin)
                types="plugin"
                ;;
            --command)
                types="command"
                ;;
            -*|--*)
                return 1
                ;;
            *)
                pkg="$opt"
                if [[ $pkg != */* ]]; then
                    # Skip
                    return 1
                fi
                break
        esac
        shift
    done

    user="${pkg:h}"
    repo="${pkg:t}"


    dir="$ZPLUG_ROOT/test/_fixtures/repos/$pkg"
    if [[ ! -d $dir ]]; then
        mkdir -p "$dir"
    fi

    case "$types" in
        "plugin")
            echo "$repo() { echo $repo; }" >"${dir}/${pkg:gs:/:}.zsh"
            ;;
        "command")
            printf "#!zsh\necho \"$@\n\"" >"$dir/$repo"
            chmod 755 "$dir/$repo"
            ;;
    esac
}

create_mock_plugin() {
    create_mock_repo --plugin "$1"
}

create_mock_command() {
    create_mock_repo --command "$1"
}

create_mock_omz() {
    git clone \
        --depth 1 \
        "https://github.com/$_ZPLUG_OHMYZSH" \
        "$ZPLUG_HOME/repos/$_ZPLUG_OHMYZSH" \
        &>/dev/null
}
