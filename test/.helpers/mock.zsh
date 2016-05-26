#!/usr/bin/env zsh

typeset -g _zplug_mock_repos="${ZPLUG_ROOT:?}/test/.fixtures/repos"

init_mock_repos() {
    local name
    for name in "$@"
    do
        name="$_zplug_mock_repos/$name"
        git -C "$name" init --quiet
        git -C "$name" config user.email "git@zplug"
        git -C "$name" config user.name "zplug"
        git -C "$name" add -A >/dev/null
        git -C "$name" commit -m "$name" >/dev/null
    done
}

mock_as_plugin() {
    local name="${1:?}"
    mkdir -p "$_zplug_mock_repos/$name"
    printf "${name:t}() { echo ${name:t}; }\n" \
        >"$_zplug_mock_repos/$name/${name:t}".zsh
    init_mock_repos "$name"
    (( $+functions[zplug] )) && zplug "$name"
}

mock_as_command() {
    local name="${1:?}"
    mkdir -p "$_zplug_mock_repos/$name"
    printf "#!/usr/bin/env zsh\necho ${name:t}\n" \
        >"$_zplug_mock_repos/$name/${name:t}"
    chmod 755 "$_zplug_mock_repos/$name/${name:t}"
    init_mock_repos "$name"
    (( $+functions[zplug] )) && zplug "$name", as:command
}

mock_remove() {
    local name="${1:?}"
    if [[ -d $_zplug_mock_repos/$name ]]; then
        rm -rf "$_zplug_mock_repos/$name"
    fi
}
