# test/fixtures/setup.zsh — Create local bare git repos for testing

FIXTURE_ROOT="$(mktemp -d)"

# Create a bare git repo that can be cloned via file:// protocol
# Usage: setup_fixture_repo "user/repo" [files...]
#   If no files given, creates a default .plugin.zsh file
setup_fixture_repo() {
    local name="$1"; shift
    local bare_dir="$FIXTURE_ROOT/$name.git"
    local work="$(mktemp -d)"

    mkdir -p "${bare_dir:h}"
    git init --bare --initial-branch=master "$bare_dir" --quiet 2>/dev/null

    git clone "$bare_dir" "$work" --quiet 2>/dev/null
    git -C "$work" checkout -b master --quiet 2>/dev/null
    git -C "$work" config user.name "test"
    git -C "$work" config user.email "test@test"

    if (( $# > 0 )); then
        # Create specified files
        for f in "$@"; do
            mkdir -p "$work/${f:h}"
            echo "# fixture: $f" > "$work/$f"
        done
    else
        # Default: create a plugin file
        echo "# fixture plugin" > "$work/${name:t}.plugin.zsh"
    fi

    git -C "$work" add -A 2>/dev/null
    git -C "$work" commit -m "init" --quiet 2>/dev/null
    git -C "$work" push origin master --quiet 2>/dev/null
    rm -rf "$work"
}

# Create a fixture repo with a branch
# Usage: setup_fixture_branch "user/repo" "branch-name" [files...]
setup_fixture_branch() {
    local name="$1" branch="$2"; shift 2
    local bare_dir="$FIXTURE_ROOT/$name.git"
    local work="$(mktemp -d)"

    git clone "$bare_dir" "$work" --quiet 2>/dev/null
    git -C "$work" checkout -b "$branch" --quiet 2>/dev/null
    git -C "$work" config user.name "test"
    git -C "$work" config user.email "test@test"

    if (( $# > 0 )); then
        for f in "$@"; do
            mkdir -p "$work/${f:h}"
            echo "# fixture: $f (branch: $branch)" > "$work/$f"
        done
    else
        echo "# branch: $branch" >> "$work/${name:t}.plugin.zsh"
    fi

    git -C "$work" add -A 2>/dev/null
    git -C "$work" commit -m "branch $branch" --quiet 2>/dev/null
    git -C "$work" push origin "$branch" --quiet 2>/dev/null
    rm -rf "$work"
}

# Override get_url to point to local fixture repos
_setup_fixture_url_override() {
    __zplug::sources::github::get_url() {
        echo "file://$FIXTURE_ROOT/${1}.git"
    }
}

# Cleanup fixtures
_cleanup_fixtures() {
    rm -rf "$FIXTURE_ROOT"
}
