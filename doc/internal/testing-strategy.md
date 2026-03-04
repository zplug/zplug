# Testing Strategy for zplug Refactoring

## Current State

- Test framework: [Shove](https://github.com/key-amb/shove) v0.8.4 (TAP output)
- Test runner: `make test` → `shove -r test/ -s zsh`
- **43 command-level tests** across 7 files (all passing)
- 27 unit test stub files in `test/base/` (111 cases, all `# skip`)
- E2E integration test: `test/all.t` (known job table exhaustion issue)

## Approach: Command-Level Tests First

Unit tests couple to internal implementation. When refactoring changes function
signatures, splits, or renames, unit tests break even if behavior is correct —
resulting in double the rewrite work.

Instead, write **command-level characterization tests** that capture observable
behavior from the user's perspective. These survive internal restructuring.

## Test Coverage

### Phase 1: No-mock tests (DONE)

| File | Tests | What it covers |
|------|-------|---------------|
| `test/commands/add.t` | 6 | Registration, tag storage, invalid name/tag rejection, duplicates, multiple plugins |
| `test/commands/check.t` | 6 | Uninstalled detection, verbose/debug output, if-condition skip, installed判定 |
| `test/commands/list.t` | 3 | Empty error, registered success, output content |
| `test/commands/clean.t` | 3 | Unmanaged removal, managed preservation, targeted removal |
| `test/commands/tags.t` | 16 | Default values (as, from, at, use, frozen, lazy, defer, depth, dir), explicit overrides, gh-r defaults |

### Phase 2: Install/load tests with fixtures (DONE)

| File | Tests | What it covers |
|------|-------|---------------|
| `test/commands/install.t` | 5 | Clone to ZPLUG_REPOS, plugin file creation, check after install, skip-if, idempotent install |
| `test/commands/load.t` | 4 | Plugin sourcing, function availability, command symlink, fpath for completions |

### Phase 3: Unit tests (after refactoring)

Write unit tests for the new internal design to lock it in.
Use the existing Shove stubs in `test/base/` as a starting point.

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

### Commands that need mocking

- `zplug install` — calls `git clone` or `curl`/`wget`
- `zplug update` — calls `git fetch`/`merge` or `curl`/`wget`

### Mocking strategy

**git-based sources → local bare repositories**

Override `get_url()` to return `file://` URLs pointing to local fixtures.
Real `git clone`/`fetch` runs without network.

**IMPORTANT**: The override must be placed AFTER `zplug "user/repo"`, not before.
The `zplug` add command calls `__zplug::core::sources::call()` which re-sources
`github.zsh` from disk, overwriting any prior function override.

```zsh
zplugs=()
zplug "test-user/test-plugin"
_setup_fixture_url_override   # AFTER add, not before
zplug install
```

**curl/wget-based sources (gh-r) → PATH mock**

`command curl` bypasses function overrides but still uses PATH lookup.
Place a mock script at `test/mock/bin/curl` and prepend to PATH.

## Test Infrastructure

### Directory layout

```
test/
├── helper.zsh            # Common setup: init zplug, create tempdir, cleanup
├── fixtures/
│   └── setup.zsh         # Create local bare repos for install/update tests
├── mock/
│   └── bin/              # PATH-based mocks (curl for gh-r tests)
├── commands/             # Command-level tests
│   ├── add.t
│   ├── check.t
│   ├── clean.t
│   ├── install.t
│   ├── list.t
│   ├── load.t
│   └── tags.t
└── base/                 # Existing unit test stubs (implement after refactoring)
    └── ...
```

### Running tests

```sh
make test TEST_TARGET=test/commands/          # all command tests
make test TEST_TARGET=test/commands/add.t     # single file
```

### Fixture repos

Fixture bare repos use `--initial-branch=master` because zplug defaults
`at:master`. Each test file creates fixtures at setup and cleans up on exit.

## Gotchas Discovered

- **`"${(M)${(z)...}:#pattern}"` bug**: Double-quoting a zsh array filter
  expansion joins the array to scalar before matching. Remove outer quotes.
  (Fixed in `base/base/base.zsh` `git_version()`)

- **`T_SUB` subshell isolation**: Each test group runs in `(...)`. Filesystem
  changes persist but variable changes do not leak. Install tests must create
  directories within each T_SUB independently.

- **Source handler reload**: `zplug "user/repo"` with `from:` tag calls
  `__zplug::core::sources::call()` which re-sources handler files from disk.
  Function overrides must be placed after the add call.

- **Default branch**: Modern git defaults to `main`, but zplug defaults `at:master`.
  Fixture repos must use `--initial-branch=master` to match.
