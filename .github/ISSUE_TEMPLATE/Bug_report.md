---
name: Bug report
about: Create a report to help us improve

---

<!--
**Before Submitting**

Please read this instructions carefully!

1. If it is not reported according to this issue template, it may be closed unconditionally
2. In accordance with "Issue Type", you should uncomment below "EDITING AREA" corresponding the part
3. You checked the [FAQ](https://github.com/zplug/zplug/wiki/FAQ) for common problems.
4. Check your [requirements](https://github.com/zplug/zplug/wiki/FAQ#what-are-the-requirements) are satisfied.
-->

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Env (please complete the following information):**
 - `zplug version`:
 - `zsh --version`:
 - `uname -a`:

**Minimal zshrc (with less than 30 lines)**

Create a minimal reproducing set of configurations for this issue. Please remove all unnecessary parts!

```zsh
source ~/.zplug/init.zsh

#zplug "foo/bar", tag:baz
#zplug "...

if zplug check || zplug install; then
  zplug load --verbose
fi
```

**Additional context**
Add any other context about the problem here.
