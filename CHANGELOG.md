# Changelog

## master

### v0.1.3, 2015-11-25
- implement check command
- close #3
- add check command
- add check --verbose/--install option

### v0.1.2, 2015-11-25
- add `$ZPLUG_PROTOCOL`
- close #5
- replace die with __die because conflict name space of die
- add git_version function

### v0.1.2, 2015-11-25
- diable help command (temporary)

### v0.1.1, 2015-11-25
- add help/version command
- job control
- use `builtin` prefix for cd command
- add completion

### v0.1.0, 2015-11-24
- implement self update (close #1)
- modify function prefix (`zplug::` -> `__zplug::`)
- fix many bugs
- support updating binaries (gh-r specifier)
- add header logo, license and usage
- refactoring

### v0.0.8, 2015-11-24
- implement update command and frozen specifier
- reference #1
- add update/frozen specifier
- format

### v0.0.7, 2015-11-24
- format (printf)
- implement do specifier
- detect installed already

### v0.0.6, 2015-11-24
- refactoring
- comment
- bugfix
- rededign load function
- redesign export path feature

### v0.0.5, 2015-11-24
- support at specifier
- fix many bugs
  - `zplug::load` if src case
  - `zplug::load` if given asterisk quoted
  - ...
- add zplug::list
- refactoring
- bugfix

### v0.0.4, 2015-11-23
- add readme

### v0.0.3, 2015-11-23
- support grabbing binaries form GitHub Releases

### v0.0.2, 2015-11-22
- add `zplug::load` function
- support argument as specifier
- I/O interface
- refactoring

### v0.0.1, 2015-11-22
- started a project
- decide project name "zplug"
