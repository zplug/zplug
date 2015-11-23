![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/logo.png)

[![](http://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)][license]

`zplug` is next-generation zsh plugin manager.

![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/demo.gif)

## Pros.

- Easier to setup
- Super-fast parallel installation/update
- Branch/tag/commit support
- Can manage not only zsh plugins but shell commands
- Support for externally managed plugins/commands

## Installation

```console
$ curl -fLo ~/.zplug/zplug --create-dirs https://raw.githubusercontent.com/b4b4r07/zplug/master/zplug
```

## Usage

Add a zplug section to your `.zshrc`:

1. List the plugins/commands with `zplug` commands
2. `zplug load` to source the plugins and add the commands to `$PATH`

### Example

```bash
source ~/.zplug/zplug

zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-substring-search"

# shell commands
zplug "holman/spark", as:cmd
# shell commands (specify export director)
zplug "b4b4r07/http_code", as:cmd, of:bin
# shell commands (whatever language is OK)
zplug "k4rthik/git-cal", as:cmd

# binaries (from GitHub Releases)
zplug "peco/peco", as:cmd, from:gh-r
zplug "junegunn/fzf-bin", \
    as:cmd, \
    from:gh-r, \
    file:fzf

# Group dependencies, emoji-cli depends on jq
zplug "stedolan/jq" \
    as:bin, \
    from:gh-r \
    | zplug "b4b4r07/emoji-cli"

# source plugins and add commands to $PATH
zplug load
```

Then `zplug install` to install plugins and reload `.zshrc`.

### `zplug` commands

| Commands | Description |
|----------|-------------|
| `install`  | Install plugins/commands |
| `load`     | Load installed plugins/commands |

### `zplug` specifiers

| Specifiers | Description | Value (default) | Example |
|------------|-------------|-----------------|---------|
| `as`       | Regards that as plugins or commands | `src`,`cmd` (`src`) | `as:cmd` |
| `of`       | Specify the pattern to source (for `src`) or relative path to export (for `cmd`) | - (-) | `of:bin`,`of:*.zsh` |
| `from`     | Specify external binaries e.g., GitHub Releases | `gh-r` (-) | `from:gh-r` |

### Environment variables

#### `ZPLUG_HOME`

It defaults to `~/.zplug`.

#### `ZPLUG_THREAD`

It defaults to 16.

## Note

:warning: **v0.0.1** there are still some bugs. This plugin isn't ready to use yet.

## License

[MIT][license] © BABAROT

[license]: http://b4b4r07.mit-license.org