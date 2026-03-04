---
name: zsh-expert
description: Zsh scripting expert — explain Zsh-specific syntax, parameter expansions, array operations, and idioms in detail
user-invocable: true
argument-hint: "<Zsh syntax or question>"
allowed-tools: Read, Grep, Glob, WebSearch, WebFetch
---

# Zsh Scripting Expert

Reference skill for Zsh syntax and idioms.
Provides accurate, practical explanations when the user asks about Zsh-specific constructs.

## Trigger

Automatically activate when:

- The user asks about Zsh parameter expansions, array operations, glob qualifiers, or other Zsh-specific syntax
- Code containing Zsh-specific constructs like `${(...)}` or `(( ))` is being discussed
- Questions like "How do I ... in Zsh" or "What does this Zsh syntax do"
- Questions about differences between Bash and Zsh

## Response Style

- Respond in the **same language** the user uses (English or Japanese)
- Start with a concise 1-2 line explanation of the syntax, then provide concrete examples
- Highlight differences from Bash when relevant
- Reference real examples from the zplug codebase with file paths and line numbers when applicable

## Reference: Zsh Parameter Expansion

### Basic Forms

| Syntax | Meaning |
|--------|---------|
| `${var}` | Variable expansion |
| `${var:-default}` | Use default if unset or empty |
| `${var:=default}` | Assign default if unset or empty, then expand |
| `${var:+alt}` | Use alt if set and non-empty |
| `${var:?message}` | Error if unset or empty |
| `${var-default}` | Use default if unset (empty is OK) |
| `${+var}` | 1 if set, 0 if unset |

### String Manipulation

| Syntax | Meaning |
|--------|---------|
| `${var#pattern}` | Remove shortest match from beginning |
| `${var##pattern}` | Remove longest match from beginning |
| `${var%pattern}` | Remove shortest match from end |
| `${var%%pattern}` | Remove longest match from end |
| `${var/pat/rep}` | Replace first match |
| `${var//pat/rep}` | Replace all matches |
| `${var/#pat/rep}` | Replace match at beginning |
| `${var/%pat/rep}` | Replace match at end |
| `${#var}` | String length (or element count for arrays) |
| `${var:offset}` | Substring from offset |
| `${var:offset:length}` | Substring from offset with length |

### Parameter Expansion Flags (Zsh-specific)

Used as `${(flags)var}`. Multiple flags can be combined.

| Flag | Meaning | Example |
|------|---------|---------|
| `(U)` | Convert to uppercase | `${(U)var}` |
| `(L)` | Convert to lowercase | `${(L)var}` |
| `(C)` | Capitalize each word | `${(C)var}` |
| `(s:sep:)` | Split on sep into array | `${(s:.:)version}` → `(1 0 3)` |
| `(j:sep:)` | Join array with sep | `${(j:,:)array}` → `a,b,c` |
| `(f)` | Split on newlines (same as `(s:\n:)`) | `${(f)output}` |
| `(F)` | Join with newlines (same as `(j:\n:)`) | `${(F)array}` |
| `(u)` | Remove duplicates (unique) | `${(u)array}` |
| `(o)` | Sort ascending | `${(o)array}` |
| `(O)` | Sort descending | `${(O)array}` |
| `(on)` | Sort numerically ascending | `${(on)array}` |
| `(M)` | Keep only matching elements | `${(M)array:#pattern}` |
| `(k)` | Get associative array keys | `${(k)assoc}` |
| `(v)` | Get associative array values | `${(v)assoc}` |
| `(kv)` | Get keys and values interleaved | `${(kv)assoc}` |
| `(t)` | Return variable type | `${(t)var}` → `scalar` |
| `(P)` | Indirect reference (name from value) | `${(P)name}` |
| `(e)` | Expand `$` variables in value | `${(e)template}` |
| `(q)` | Add quoting | `${(q)var}` |
| `(Q)` | Remove quoting | `${(Q)var}` |
| `(w)` | Word count (with `${#}`) | `${(w)#var}` |
| `(S)` | Reverse shortest/longest match for `#`/`%` | Substring match mode |
| `(V)` | Make invisible characters visible | `${(V)var}` |
| `(z)` | Tokenize using shell word splitting | `${(z)cmdline}` |

### Array Filtering

| Syntax | Meaning |
|--------|---------|
| `${array:#pattern}` | Keep elements NOT matching pattern |
| `${(M)array:#pattern}` | Keep ONLY elements matching pattern |
| `${array[(i)value]}` | Index of first occurrence of value |
| `${array[(I)value]}` | Index of last occurrence of value |
| `${array[(r)pattern]}` | First element matching pattern |
| `${array[(R)pattern]}` | Last element matching pattern |

## Reference: Array Operations

### Basics

```zsh
# Declaration
typeset -a arr=(one two three)

# Zsh is 1-indexed (Bash is 0-indexed)
echo $arr[1]          # one
echo $arr[-1]         # three (last element)

# Slicing
echo $arr[2,3]        # two three
echo $arr[2,-1]       # two three (from 2nd onward)

# Element count
echo $#arr            # 3
echo ${#arr[@]}       # 3

# Append
arr+=("four")
arr[5]="five"         # gaps filled with empty strings

# Delete (specific index)
arr[2]=()             # removes 2nd element and shifts

# Iterate all elements
for x in "${arr[@]}"; do echo $x; done

# Iterate with index
for i in {1..$#arr}; do echo "$i: $arr[$i]"; done
```

### Associative Arrays

```zsh
typeset -A hash
hash=(key1 val1 key2 val2)
# or
hash[key1]=val1

echo $hash[key1]        # val1
echo ${(k)hash}          # key1 key2 (keys)
echo ${(v)hash}          # val1 val2 (values)
echo ${(kv)hash}         # key1 val1 key2 val2

# Check key existence
(( ${+hash[key1]} )) && echo "exists"

# Element count
echo ${#hash}            # 2
```

## Reference: Globbing

### Extended Glob (`setopt EXTENDED_GLOB`)

| Pattern | Meaning |
|---------|---------|
| `**/` | Recursive directory match |
| `(pat1\|pat2)` | OR match |
| `^pattern` | Negation match |
| `pat~exclude` | Match pat but not exclude |
| `#` | Zero or more repetitions (regex `*`) |
| `##` | One or more repetitions (regex `+`) |

### Glob Qualifiers

Used as `pattern(qualifier)`. Filter files by attributes.

| Qualifier | Meaning |
|-----------|---------|
| `.` | Regular files only |
| `/` | Directories only |
| `@` | Symbolic links only |
| `*` | Executable files only |
| `r` / `w` / `x` | Owner read/write/execute |
| `R` / `W` / `X` | World read/write/execute |
| `N` | NULL_GLOB (no error if no match) |
| `D` | DOTGLOB (include hidden files) |
| `on` | Sort by name |
| `om` | Sort by modification time |
| `oL` | Sort by file size |
| `Om` | Reverse sort by modification time |
| `[1]` | First match only |
| `[1,5]` | First 5 matches |
| `m-7` | Modified within 7 days |
| `L+1M` | Larger than 1MB |
| `u:user:` | Owned by specified user |

```zsh
# Example: .zsh files under current dir, sorted by mtime
print -l **/*.zsh(.om)

# Example: regular files modified within 7 days
print -l *(m-7.)
```

## Reference: Conditionals & Arithmetic

### `[[ ]]` Conditional Expressions

```zsh
[[ -n $var ]]          # Non-empty check
[[ -z $var ]]          # Empty check
[[ $a == $b ]]         # String equality
[[ $a != $b ]]         # String inequality
[[ $a =~ regex ]]      # Regex match (results in MATCH, match)
[[ $a == pattern ]]    # Glob pattern match
[[ -e $file ]]         # File exists
[[ -d $dir ]]          # Is a directory
[[ -f $file ]]         # Is a regular file
[[ -L $file ]]         # Is a symbolic link
[[ -x $file ]]         # Is executable
```

**Zsh-specific**: `==` supports glob pattern matching inside `[[ ]]`. PCRE is available with `=~` when `setopt RE_MATCH_PCRE` is set.

### `(( ))` Arithmetic Expressions

```zsh
(( x = 5 + 3 ))        # Assignment
(( x++ ))               # Increment
(( x > 0 )) && echo positive
(( result = a > b ? a : b ))  # Ternary operator
```

## Reference: Zsh-Specific Builtins

| Command | Meaning |
|---------|---------|
| `typeset` / `declare` | Variable declaration (`-a` array, `-A` assoc array, `-i` integer, `-r` readonly, `-g` global) |
| `local` | Function-local variable (equivalent to `typeset`) |
| `autoload` | Declare lazy-loaded function |
| `autoload -Uz func` | `-U` suppress alias expansion, `-z` zsh-style |
| `zmodload` | Load Zsh modules |
| `zstyle` | Context-based configuration |
| `compdef` | Bind completion function |
| `add-zsh-hook` | Add hook function to precmd/preexec etc. |
| `emulate -L zsh` | Force Zsh emulation within a function |
| `setopt` / `unsetopt` | Set/unset shell options |
| `print` | Enhanced echo (`-P` prompt expansion, `-l` one per line, `-r` no escapes) |
| `read` | `-q` Y/n prompt, `-s` silent input, `-A` read into array |

## Reference: Useful Options

| Option | Meaning |
|--------|---------|
| `LOCAL_OPTIONS` | Restore options set within a function on return |
| `LOCAL_TRAPS` | Restore traps set within a function on return |
| `EXTENDED_GLOB` | Enable extended globbing |
| `NULL_GLOB` | No error when glob has no match |
| `KSH_ARRAYS` | Make arrays 0-indexed (rarely used) |
| `WARN_CREATE_GLOBAL` | Warn on implicit global variable creation in functions |
| `ERR_EXIT` | Exit immediately on command failure |
| `PIPE_FAIL` | Detect failures within pipelines |
| `NO_UNSET` | Error on referencing unset variables |

## Reference: Hooks & Traps

```zsh
# precmd: runs just before each prompt display
add-zsh-hook precmd my_precmd_func

# preexec: runs just before command execution (arg: command string)
add-zsh-hook preexec my_preexec_func

# chpwd: runs on directory change
add-zsh-hook chpwd my_chpwd_func

# zshexit: runs on shell exit
add-zsh-hook zshexit my_cleanup_func

# TRAPINT: Ctrl+C handler
TRAPINT() { print "interrupted"; return 128+2; }

# TRAPERR: error handler
TRAPERR() { print "error: $?" >&2; }

# TRAPZERR: non-zero exit handler (equivalent to TRAPERR)
```

## Reference: Anonymous Functions

```zsh
# Immediately-invoked function (creates scope)
() {
    local tmp="scoped"
    echo $tmp
}

# With arguments
() {
    echo "arg1=$1 arg2=$2"
} "hello" "world"
```

## Reference: Key Differences from Bash

| Feature | Bash | Zsh |
|---------|------|-----|
| Array indexing | 0-indexed | 1-indexed |
| Array access | `${arr[0]}` | `$arr[1]` or `${arr[1]}` |
| Bare `$arr` | First element | All elements (same as `${arr[@]}`) |
| Associative array declaration | `declare -A` | `typeset -A` |
| Word splitting | On by default | Off by default |
| Glob qualifiers | None | `(.om)` and many more |
| Parameter expansion flags | None | `${(s:.:)var}` and many more |
| `[[ $x == pattern ]]` | Glob match | Glob match |
| `=~` regex | ERE (BASH_REMATCH) | ERE (MATCH, match) |
| `print` command | Not built-in | Built-in |
| `emulate` | Not available | Available |
| Function scoping | Dynamic | Dynamic (`typeset` for local) |
| Anonymous functions | Not available | `() { ... }` |
| Hook mechanism | Not available | `add-zsh-hook` |

## Reference: ZLE (Zsh Line Editor)

```zsh
# Custom widget
my-widget() {
    BUFFER="modified"
    CURSOR=$#BUFFER
}
zle -N my-widget
bindkey '^X^M' my-widget

# Key variables
# BUFFER  — current input line
# CURSOR  — cursor position
# LBUFFER — text left of cursor
# RBUFFER — text right of cursor
# WIDGET  — name of currently executing widget
```

## Answer Guidelines

1. Start with a concise 1-2 line explanation of the syntax in question
2. Provide concrete code examples (minimal and runnable)
3. Note any gotchas or common pitfalls
4. Reference real usage in the zplug codebase when applicable, using `base/path/file.zsh:NN` format
5. For users coming from Bash, explicitly highlight the differences
6. List related syntax or flags under a "See also" section when relevant
