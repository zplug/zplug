# External Commands

zplug, like `git(1)`, supports external commands.
This lets you create new commands that can be run like:

```console
$ zplug mycommand --option1 --option2 package
```

without modifying zplug's internals.

## How to write commands

As long as the external command is executable (`chmod +x`) and live somewhere in `$PATH`,
any language will do (e.g. shell script, ruby script, etc.).

Example:

```zsh
#!/usr/bin/env zsh
# description: my new zplug command

echo "Hello, zplug"
```

when saving as zplug-foo, the command can be invoked like zplug foo.
In addition, the description line (line 2) is used as the description
in the completion.

```console
% zplug
Completing zplug commands
check    --> Check whether an update or installation is available
clean    --> Remove deprecated repositories
clear    --> Remove cache file
foo      --> [User-defined] my new zplug command
install  --> Install described items (plugins/commands) in parallel
list     --> Show all of the zplugs in the current shell
load     --> Load installed items
status   --> Check if remote branch is up-to-date
update   --> Update items in parallel
```

## Sample script

- [zplug-env](../../bin/zplug-env)
