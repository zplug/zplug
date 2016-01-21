#!/bin/zsh

if [[ -z $ZPLUG_ROOT ]]; then
    return 1
fi

init_mock_repos() {
    local name
    for name in "$@"
    do
        name="$ZPLUG_ROOT/test/_fixtures/repos/$name"
        git -C "$name" init --quiet
        git -C "$name" config user.email "git@zplug"
        git -C "$name" config user.name "zplug"
        git -C "$name" add -A >/dev/null
        git -C "$name" commit -m "$name" >/dev/null
    done
}

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

make_file() {
    local entry="$1"
    local dir="${entry:h}"

    if [[ -z $entry || -e $entry ]]; then
        return 1
    fi

    [[ -d $dir ]] || mkdir -p "$dir"
    touch "$entry"
}

create_mock_lib() {
    local arg="$1"
    make_file "$ZPLUG_ROOT/lib/${arg}.zsh"
}
