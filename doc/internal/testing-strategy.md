# Testing Strategy for zplug Refactoring

## Current State

- Test framework: [Shove](https://github.com/key-amb/shove) v0.8.4 (TAP output)
- 27 test files, 111 test cases — **all `# skip` (no implementations)**
- Only working test: `test/all.t` (E2E integration via `misc/zshrc`)
- 18 modules have no test files at all (job/, log/ systems especially)
- Test runner: `make test` → `shove -r test/ -s zsh`

## Approach: Command-Level Tests First

Unit tests couple to internal implementation. When refactoring changes function
signatures, splits, or renames, unit tests break even if behavior is correct —
resulting in double the rewrite work.

Instead, write **command-level characterization tests** that capture observable
behavior from the user's perspective. These survive internal restructuring.

### What NOT to test first

- Internal function return values
- Data structure internals (how `zplugs` is populated)
- Log output format
- Individual utility functions

### What to test first

The public CLI commands and their observable effects:

| Command | Observable Effect |
|---------|-------------------|
| `zplug "user/repo"` | Registered in `zplugs` associative array |
| `zplug check` | Exit code reflects install state |
| `zplug list` | Lists registered plugins |
| `zplug install` | Creates directory under `$ZPLUG_HOME/repos/` |
| `zplug load` | Functions/commands become available in shell |
| `zplug clean` | Removes plugin directory |
| `zplug update` | Updates cloned repository |

## Network Dependency Handling

zplug is a package manager — `install` and `update` require network operations.
Most commands, however, do not.

### Commands that need NO mocking

- `zplug "user/repo"` (add) — pure in-memory registration
- `zplug check` — filesystem check only
- `zplug list` — reads `zplugs` array
- `zplug clean` — deletes directories
- `zplug load` — sources files from disk
- Tag default resolution — pure logic

**These cover the majority of refactoring-sensitive logic.** Start here.

### Commands that need mocking

- `zplug install` — calls `git clone` or `curl`/`wget`
- `zplug update` — calls `git fetch`/`merge` or `curl`/`wget`

### Network operation touchpoints

| Operation | Function | How it calls |
|-----------|----------|-------------|
| git clone | `__zplug::utils::git::clone()` | bare `git clone` (no `command` prefix) |
| git fetch/merge | `__zplug::utils::git::merge()` | bare `git fetch`, `git merge` |
| curl (releases) | `__zplug::utils::releases::get_url()` | `command curl` (bypasses functions) |
| curl (download) | `__zplug::utils::releases::get()` | `command curl` (bypasses functions) |
| URL resolution | `__zplug::sources::<source>::get_url()` | returns URL string |

### Mocking strategy

**git-based sources → local bare repositories**

Override `get_url()` to return `file://` URLs pointing to local fixtures.
Real `git clone`/`fetch` runs without network.

```zsh
# Override in test setup
__zplug::sources::github::get_url() {
    echo "file://$FIXTURE_ROOT/${1}.git"
}
```

`get_url()` is a stable interface boundary — it will exist in any reasonable
refactoring of the source handler system.

**curl/wget-based sources (gh-r) → PATH mock**

`command curl` bypasses function overrides but still uses PATH lookup.
Place a mock script at `test/mock/bin/curl` and prepend to PATH.

```bash
#!/bin/bash
# test/mock/bin/curl — returns canned responses based on URL
url="${@: -1}"
case "$url" in
    *releases/latest*) cat "$FIXTURE_ROOT/releases_latest.html" ;;
    *releases/download/*) cp "$FIXTURE_ROOT/dummy.tar.gz" . ;;
    *) echo "mock curl: unexpected URL: $url" >&2; exit 1 ;;
esac
```

```zsh
# In test setup
export PATH="$ZPLUG_ROOT/test/mock/bin:$PATH"
```

## Test Infrastructure

### Directory layout

```
test/
├── helper.zsh            # Common setup: init zplug, create tempdir, cleanup
├── fixtures/
│   └── setup.zsh         # Create local bare repos for install/update tests
├── mock/
│   └── bin/
│       └── curl           # PATH-based curl mock for gh-r tests
├── commands/              # Command-level tests (new)
│   ├── add.t
│   ├── check.t
│   ├── list.t
│   ├── clean.t
│   ├── load.t
│   ├── install.t
│   └── update.t
└── base/                  # Existing unit test stubs (implement after refactoring)
    └── ...
```

### Test helper template

```zsh
# test/helper.zsh

export ZPLUG_HOME="$(mktemp -d)"
source "$ZPLUG_ROOT/init.zsh"

cleanup() {
    rm -rf "$ZPLUG_HOME"
}
trap cleanup EXIT
```

### Fixture helper for install/update tests

```zsh
# test/fixtures/setup.zsh

setup_fixture_repo() {
    local name="$1"
    local bare_dir="$FIXTURE_ROOT/$name.git"
    local work="$(mktemp -d)"

    git init --bare "$bare_dir" &>/dev/null
    git clone "$bare_dir" "$work" &>/dev/null
    echo "# dummy" > "$work/${name##*/}.plugin.zsh"
    git -C "$work" add -A &>/dev/null
    git -C "$work" commit -m "init" &>/dev/null
    git -C "$work" push origin master &>/dev/null
    rm -rf "$work"
}
```

## Implementation Phases

### Phase 1: No-mock tests (before refactoring)

Write command-level tests for add, check, list, clean, and tag defaults.
No fixtures or mocks needed. This is the immediate priority.

### Phase 2: Install/update tests (before refactoring)

Set up fixture infrastructure (local bare repos, curl mock).
Write tests for install and load with fixture plugins.

### Phase 3: Unit tests (after refactoring)

Write unit tests for the new internal design to lock it in.
Use the existing Shove stubs in `test/base/` as a starting point.

## Notes

- Shove's `T_SUB` runs in a subshell — global state (`zplugs`) doesn't leak
  between test groups. This is a benefit for isolation.
- `source "$ZPLUG_ROOT/init.zsh"` is heavy. Source once per test file, not per
  `T_SUB` block.
- Zsh arrays are 1-indexed. Guard against off-by-one in assertions.
- Existing `test/all.t` has a known failure (job table exhaustion). Individual
  tests are the reliable signal.
