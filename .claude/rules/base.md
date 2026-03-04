---
description: Coding conventions for zplug core modules (base/ directory)
paths:
  - "base/**/*.zsh"
---

# Rules for base/

## Function Naming

All functions MUST use the hierarchical naming convention:

```
__zplug::<subdomain>::<module>::<function_name>()
```

The subdomain and module correspond to the directory path. For example, a function in `base/core/tags.zsh` must be named `__zplug::core::tags::<name>`.

## Variable Declarations

- Global variables: `typeset -gx` with UPPERCASE names (e.g., `ZPLUG_HOME`)
- Internal globals: `typeset -gx` with `_zplug_` prefix (e.g., `_zplug_status`)
- Local variables: `local` keyword with lowercase names
- Use type flags: `-i` for integers, `-A` for associative arrays, `-a` for indexed arrays, `-F` for floats, `-U` for unique arrays

## Return Values

Functions return data in one of three ways — do not mix patterns within a single function:

1. **Exit code** via `return $status` — for success/failure checks
2. **`reply` array** — for returning structured data (key-value pairs, lists)
3. **`echo`/`printf`** — for returning a single string value

Use the `_zplug_status` associative array for semantic exit codes:

```zsh
return $_zplug_status[success]    # 0
return $_zplug_status[failure]    # 1
return $_zplug_status[up_to_date] # 10
```

## Error Handling

Always use the structured print function for error output:

```zsh
__zplug::io::print::f \
    --die \
    --zplug \
    --error \
    "message with %s\n" \
    "$var"
return 1
```

Capture stderr from subcommands with process substitution:

```zsh
command git clone "$url" "$dir" \
    2> >(__zplug::log::capture::error) >/dev/null
```

## File Structure

- Files contain ONLY function definitions — no top-level executable code
- No import/require statements; functions are autoloaded
- Use zsh parameter expansion idioms (`${(s:.:)var}`, `${(M)...:#pattern}`, `${(k)array[@]}`) instead of external commands where possible
- Isolate directory-changing operations in subshells: `( cd "$dir"; ... )`

## Cross-Module Calls

- Call other modules' functions directly by their full name
- Use `__zplug::core::sources::use_handler` for dynamic source dispatch
- Parse tags via `__zplug::core::tags::parse "$repo"` then read `reply`

## Source Handlers (base/sources/)

Every source handler MUST implement these functions:

- `check()` — verify plugin is installed (return 0/1)
- `install()` — clone/download the plugin
- `update()` — pull/merge updates
- `get_url()` — echo the clone URL
- `load_plugin()` — populate `reply` with files to source
- `load_command()` — populate `reply` with commands to symlink
- `load_theme()` — populate `reply` with theme files
