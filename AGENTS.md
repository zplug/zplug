# AGENTS.md — zplug

## Project Overview

zplug is a Zsh plugin manager written entirely in Zsh. It supports parallel installation, lazy-loading, caching, and multiple plugin sources (GitHub, Bitbucket, Gist, Oh-My-Zsh, Prezto, GitHub Releases, local directories).

## Architecture

### Namespace Convention

All internal functions follow the pattern:

```
__zplug::<module>::<submodule>::<function>
```

For example: `__zplug::base::base::git_version`, `__zplug::core::tags::parse`.

### Directory Structure

```
zplug/
├── init.zsh              # Entry point — sources all base modules
├── base/                 # Internal implementation
│   ├── base/             # Utility: version checks, OS detection
│   ├── core/             # Plugin lifecycle: add, load, tags, cache
│   ├── io/               # Formatted output, file operations
│   ├── job/              # Parallel execution, queues, hooks
│   ├── log/              # Logging: capture, format, write
│   ├── sources/          # Source handlers (github, bitbucket, gh-r, etc.)
│   └── utils/            # Helpers: git, shell, awk, yaml, ansi
├── autoload/             # Zsh autoloaded functions (CLI interface)
│   ├── commands/         # install, update, load, check, clean, list, etc.
│   ├── options/          # --help, --version, --log, --rollback
│   └── tags/             # 19 tag handlers (from, as, at, use, do, if, etc.)
├── bin/                  # Executables (zplug-env)
├── test/                 # Unit tests (mirrors base/ structure)
├── doc/                  # Man page, guides, command docs
└── misc/                 # AWK scripts, completions, dev tools
```

### Key Data Structures

- `zplugs` — associative array mapping plugin names to their tag specifications
- Tags parsed via `__zplug::core::tags::parse` into `reply` array / `zspec` hash

### Source Handler Interface

Each source in `base/sources/` implements:
- `check()` — verify installation
- `install()` — clone/download
- `update()` — pull/merge
- `get_url()` — resolve clone URL
- `load_plugin()` / `load_command()` / `load_theme()` — load into shell

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 10 | Up-to-date |
| 11 | Out-of-date |
| 13 | Repository not found |
| 14 | Skipped (if-condition failed) |
| 15 | Skipped (frozen) |
| 16 | Skipped (local plugin) |

## Development

### Requirements

- Zsh 4.3.9+
- Git 1.7+
- AWK (nawk or gawk, not mawk)

### Running Tests

```sh
make test
```

Tests use the [Shove](https://github.com/key-amb/shove) framework. Test files are under `test/` and mirror the `base/` directory structure. Each `.t` file is a Zsh script executed by Shove.

### Docker

```sh
./build.sh   # Build the dev container
./run.sh     # Run it
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ZPLUG_HOME` | `~/.zplug` | Installation directory |
| `ZPLUG_THREADS` | `16` | Parallel job count |
| `ZPLUG_PROTOCOL` | `HTTPS` | Clone protocol |
| `ZPLUG_USE_CACHE` | `true` | Enable caching |
| `ZPLUG_LOADFILE` | `~/.zplug/packages.zsh` | Package specification file |

## Coding Guidelines

- All functions must use the `__zplug::module::submodule::name` naming pattern.
- Shell scripts are Zsh — do not use Bash-only syntax.
- Use zsh parameter expansion idioms (e.g., `${(s:.:)var}`, `${(M)...:#pattern}`) rather than external commands where possible.
- Keep changes minimal and focused. Avoid refactoring unrelated code.
- Run `make test` before submitting changes to verify existing tests pass.
- The `test/all.t` integration test has a known pre-existing failure (job table exhaustion) — individual module tests are the reliable indicator.

## Common Pitfalls

- **Version strings**: `git --version` can return non-standard suffixes like `.dirty`. Always sanitize version strings before numeric comparison (see `base/base/base.zsh`).
- **AWK compatibility**: zplug requires nawk or gawk. Helper AWK scripts are in `misc/contrib/`.
- **Array indexing**: Zsh arrays are 1-indexed. Guard against negative indices in loops.
- **Python dependency**: Log formatting uses Python for JSON. Must fall back to `python3` when `python` is unavailable (see `base/utils/shell.zsh`).
