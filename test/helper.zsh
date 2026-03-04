# test/helper.zsh — Common test setup for command-level tests
#
# Source this file at the top of each .t file:
#   source "$ZPLUG_ROOT/test/helper.zsh"

# Isolated ZPLUG_HOME per test file
export ZPLUG_HOME="$(mktemp -d)"
export ZPLUG_REPOS="$ZPLUG_HOME/repos"
export ZPLUG_BIN="$ZPLUG_HOME/bin"
export ZPLUG_LOADFILE="$ZPLUG_HOME/packages.zsh"
export ZPLUG_USE_CACHE=false

# Ensure stdin is not a pipe (CI runners may have piped stdin,
# which triggers zplug's deprecated pipe-syntax detection)
exec < /dev/null

# Initialize zplug
source "$ZPLUG_ROOT/init.zsh"

# Reset state
zplugs=()

cleanup() {
    rm -rf "$ZPLUG_HOME"
}
trap cleanup EXIT
