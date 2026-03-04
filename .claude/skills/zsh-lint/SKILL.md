---
name: zsh-lint
description: Review Zsh scripts for Bash-isms and non-idiomatic patterns, then suggest or apply Zsh-native rewrites
user-invocable: true
argument-hint: "<file path or code snippet>"
allowed-tools: Read, Edit, Grep, Glob, WebSearch
---

# Zsh Idiom Linter

Review Zsh scripts and rewrite non-idiomatic patterns into proper Zsh style.
Detects Bash-isms, unnecessary external command usage, and missed Zsh-native features.

## Trigger

Activate when:

- User asks to "make this more Zsh-like", "review Zsh style", "rewrite in Zsh idioms"
- User pastes shell code and asks for improvement in a Zsh context
- User asks to remove Bash-isms from a script
- Working on `.zsh` files in this repository

## What to Check

### 1. External Commands Replaceable by Parameter Expansion

| Avoid | Prefer | Why |
|-------|--------|-----|
| `basename "$path"` | `${path:t}` | Zsh has `:t` (tail) modifier |
| `dirname "$path"` | `${path:h}` | Zsh has `:h` (head) modifier |
| `echo "$x" \| tr A-Z a-z` | `${(L)x}` | Expansion flag |
| `echo "$x" \| tr a-z A-Z` | `${(U)x}` | Expansion flag |
| `echo "$x" \| sed 's/a/b/g'` | `${x//a/b}` | Pattern substitution |
| `echo "$x" \| cut -d. -f1` | `${x%%.*}` | Suffix removal |
| `echo "$x" \| rev` | `${(j::)${(@Oa)${(s::)x}}}` | Only if simple; otherwise `rev` is fine |
| `echo "$x" \| wc -l` | `${(w)#${(f)x}}` or `${#${(f)x}}` | Line count via expansion |
| `echo "$x" \| sort -u` | `${(ou)${(f)x}}` | Sort + unique flags |
| `echo "$x" \| head -1` | `${${(f)x}[1]}` | Array indexing |
| `expr $a + $b` | `$(( a + b ))` | Arithmetic expansion |
| `seq 1 10` | `{1..10}` | Brace expansion |
| `cat file` | `$(<file)` | Zsh file read syntax |

### 2. Bash-isms to Avoid

| Bash-ism | Zsh Equivalent | Notes |
|----------|---------------|-------|
| `${arr[0]}` (first element) | `${arr[1]}` | Zsh is 1-indexed |
| `declare -a` | `typeset -a` | `typeset` is the Zsh convention |
| `declare -A` | `typeset -A` | Same |
| `$BASH_REMATCH` | `$MATCH` / `$match` | After `=~` |
| `${!var}` (indirect) | `${(P)var}` | Parameter expansion flag |
| `${!arr[@]}` (keys) | `${(k)arr}` | Key expansion flag |
| `read -a arr` | `read -A arr` | `-A` for array in Zsh |
| `[[ $x = *pattern* ]]` | `[[ $x == *pattern* ]]` | `==` preferred in Zsh |
| `function foo {` | `foo() {` | POSIX-style preferred; both work |
| `echo -e` | `print` | `print` supports escapes natively |
| `echo -n` | `print -n` | Or `print -rn --` for safety |
| `source file` | `source file` or `. file` | Both fine, but be consistent |
| `export VAR=val` | `export VAR=val` or `typeset -gx VAR=val` | Both fine |

### 3. Idiomatic Zsh Patterns

| Instead of | Prefer | Reason |
|------------|--------|--------|
| `if [ -n "$(ls dir)" ]` | `if (( $#dir_files )); ...` or glob qualifier | Avoid command substitution for file checks |
| `for f in $(ls *.txt)` | `for f in *.txt(N)` | `(N)` prevents error on no match |
| `test -d "$d" && cd "$d"` | `cd "$d" 2>/dev/null` or `[[ -d $d ]]` | `[[ ]]` preferred over `test`/`[ ]` |
| `cmd \| while read line` | `while read line; do ...; done < <(cmd)` or `for line in ${(f)$(cmd)}` | Avoid subshell from pipe |
| `local IFS=,; arr=($str)` | `arr=(${(s:,:)str})` | Split flag |
| `echo "$a" "$b" "$c"` | `print -r -- "$a" "$b" "$c"` | `print -r` avoids escape interpretation |
| `VAR=$(echo $x \| cmd1 \| cmd2)` | Chain expansions or single pipe | Reduce subshells |
| `[ $? -eq 0 ]` | Direct `if cmd; then` | Check exit status directly |
| `grep -q pat file && ...` | `[[ $(<file) == *pat* ]]` | For simple pattern checks on small files |
| `arr=($(echo $str))` | `arr=(${=str})` | `${=var}` does word splitting in Zsh |
| `wc -l < file` | `${#${(f)"$(<file)"}}` | Pure Zsh line count |

### 4. Quoting & Safety

| Issue | Fix |
|-------|-----|
| Unquoted `$var` in arguments | Usually safe in Zsh (no word splitting by default), but quote in `[[ ]]` RHS for literal match |
| `$(cmd)` with word split intent | Use `${(f)$(cmd)}` to split by lines, or `${=var}` for word split |
| Missing `emulate -L zsh` in public functions | Add for predictable behavior regardless of caller options |
| Missing `setopt LOCAL_OPTIONS` | Use when temporarily changing options inside a function |

### 5. Path/File Modifiers (Zsh-specific)

| Modifier | Meaning | Example |
|----------|---------|---------|
| `:t` | Tail (basename) | `${path:t}` → `file.txt` |
| `:h` | Head (dirname) | `${path:h}` → `/usr/local` |
| `:r` | Root (remove extension) | `${file:r}` → `archive.tar` |
| `:e` | Extension | `${file:e}` → `gz` |
| `:l` | Lowercase | `${var:l}` |
| `:u` | Uppercase | `${var:u}` |
| `:a` | Absolute path | `${path:a}` |
| `:A` | Absolute path with symlink resolution | `${path:A}` |
| `:gs/x/y/` | Global substitution | `${path:gs/./_/}` |

## Review Process

1. **Read** the target file or code
2. **Identify** patterns from the tables above
3. **Report** each finding with:
   - Line number and original code
   - Suggested Zsh-idiomatic replacement
   - Brief reason
4. **Categorize** severity:
   - **Error**: Will break or behave differently in Zsh (e.g., 0-indexed array access)
   - **Warning**: Works but not idiomatic (e.g., `basename` instead of `:t`)
   - **Style**: Minor preference (e.g., `declare` vs `typeset`)
5. **Offer to apply** the fixes automatically if the user agrees

## Output Format

```
## Zsh Lint: <filename>

### Errors
- **L42**: `${arr[0]}` → `${arr[1]}` — Zsh arrays are 1-indexed

### Warnings
- **L15**: `basename "$path"` → `${path:t}` — use Zsh path modifier
- **L28**: `echo "$x" | tr A-Z a-z` → `${(L)x}` — use expansion flag

### Style
- **L3**: `declare -a` → `typeset -a` — Zsh convention

### Summary
3 issues found (1 error, 2 warnings, 1 style)
```

When the user asks to fix (not just lint), apply changes directly using the Edit tool.
