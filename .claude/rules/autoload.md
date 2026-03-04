---
description: Conventions for autoloaded CLI commands, options, and tag handlers
paths:
  - "autoload/**/*"
---

# Rules for autoload/

## File Naming

- Commands: `autoload/commands/__<name>__` (e.g., `__install__`)
- Options: `autoload/options/__<name>__` (e.g., `__version__`)
- Tags: `autoload/tags/__<name>__` (e.g., `__as__`)

Files have no `.zsh` extension. The double-underscore wrapping is required for the autoload discovery system.

## File Header

Every autoload file must start with:

```zsh
#!/usr/bin/env zsh
# Description:
#   One-line description of what this function does
```

The `# Description:` comment is parsed by `__zplug::core::core::get_interfaces()` for help text.

## Commands (autoload/commands/)

### Argument Parsing

Use this standard pattern:

```zsh
while (( $# > 0 ))
do
    arg="$1"
    case "$arg" in
        -*|--*)
            __zplug::core::options::unknown "$arg"
            return $status
            ;;
        "")
            return 1
            ;;
        */*)
            repos+=( "${arg:gs:@::}" )
            ;;
        *)
            return 1
            ;;
    esac
    shift
done
```

### Tag Access

Always parse tags before using them:

```zsh
__zplug::core::tags::parse "$repo"
tags=( "${reply[@]}" )
```

### Parallel Execution

For commands that operate on multiple repos:

```zsh
__zplug::job::parallel::init "$repos[@]"
repos=( "$reply[@]" )

for repo in "$repos[@]"; do
    {
        # ... work ...
        __zplug::job::handle::flock "$_zplug_log[action]" \
            "repo:$repo\tstatus:$status_code"
    } &
    repo_pids[$repo]=$(builtin printf $!)
    __zplug::job::handle::wait
done

__zplug::job::handle::elapsed_time $SECONDS
__zplug::job::parallel::deinit
```

## Tags (autoload/tags/)

### Three-Level Fallback

Every tag handler must follow this resolution order:

1. Explicit inline tag value (from `zplugs[$arg]`)
2. `zstyle` configuration (`:zplug:tag`)
3. Default value

```zsh
local default="plugin"

# 1. Parse from inline specification
val="${parsed_zplugs[(k)tagname:*]#tagname:*}"

# 2. Check zstyle
if [[ -z $val ]]; then
    zstyle -s ":zplug:tag" tagname val
fi

# 3. Apply default
: ${val:=$default}
```

### Validation

- Define allowed values in a `candidates` array
- Validate with regex: `[[ $val =~ ^(${(j:|:)candidates[@]})$ ]]`
- Boolean tags: validate against `_zplug_boolean_true` and `_zplug_boolean_false`
- On invalid input, call `__zplug::io::print::f --die --zplug --error --func` and return 1

### Return Value

Tag handlers MUST `echo` the resolved value. The caller reads it via command substitution.
