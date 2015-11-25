<img src="https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/logo.png" height="100" alt="vim-plug">
===

`zplug` is next-generation zsh plugin manager.

![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/demo.gif)

## Pros.

- Manage everything
- Super-fast parallel installation/update
- Branch/tag/commit support
- Can manage UNIX commands (what language is okay)
- Post-update hooks
- Support for externally managed plugins (oh-my-zsh?)
- Can manage binaries (e.g., GitHub Releases)
- Creates shallow clones to minimize disk space usage and download time

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

# Make sure you use double quotes
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-substring-search"

# shell commands
zplug "holman/spark", as:cmd
# shell commands (specify export directory path using `of` specifier)
zplug "b4b4r07/http_code", as:cmd, of:bin
# shell commands (whatever language is OK; e.g., perl script)
zplug "k4rthik/git-cal", as:cmd

# binaries (from GitHub Releases)
zplug "junegunn/fzf-bin", \
    as:cmd, \
    from:gh-r, \
    file:fzf
    
# run command after installed
zplug "tj/n", do:"make install"
    
# branch/tag
zplug "b4b4r07/enhancd", at:v1

# true or false
zplug "hchbaw/opp.zsh", if:"(( ${ZSH_VERSION%%.*} < 5 ))"

# Group dependencies, emoji-cli depends on jq
zplug "stedolan/jq", \
    as:cmd, \
    file:jq, \
    from:gh-r \
    | zplug "b4b4r07/emoji-cli"

# install plugins if there are plugins that have not been installed 
zplug check --install

# source plugins and add commands to $PATH
zplug load
```

Then `zplug install` to install plugins and reload `.zshrc`.

### `zplug` commands

|  Commands  | Description | Option |
|------------|-------------|--------|
| `install`  | Install described items (plugins/commands) in parallel | N/A |
| `load`     | Load installed items | N/A |
| `list`     | List installed items | N/A |
| `update`   | Update items in parallel | N/A |
| `check`    | Check whether an update or installation is available | `--verbose`,`--install` |

### `zplug` specifiers

| Specifiers | Description | Value (default) | Example |
|------------|-------------|-----------------|---------|
| `as`       | Regard that as plugins or commands | `src`,`cmd` (`src`) | `as:cmd` |
| `of`       | Specify the pattern to source (for `src`) or relative path to export (for `cmd`) | - (-) | `of:bin`,`of:*.zsh` |
| `from`     | Grab external binaries from e.g., GitHub Releases | `gh-r` (-) | `from:gh-r` |
| `at`       | Support branch/tag installation | branch/tag name (`master`) | `at:v1.5.6` |
| `file`     | Specify filename you want to rename | filename (-) | `file:fzf` |
| `dir`      | Installation directory | **READ ONLY** | - 
| `if`       | Whether to install or not | true/false (-) | `if:"[ -d ~/.zsh ]"` |
| `do`       | Run commands after installation | shell commands (-) | `do:"make"` |
| `frozen`   | Do not update unless explicitly specified | 0,1 (0) | `frozen:1` |

### `zplug` configurations

#### `ZPLUG_HOME`

It defaults to `~/.zplug`.

Directory to store/load plugins. The directory structure is below.

```
$ZPLUG_HOME
|-- bin
|   `-- some_command -> ../repos/username_A/reponame1/some_command
`-- repos
    |-- username_A
    |   |-- reponame1
    |   |   |-- README.md
    |   |   `-- some_command
    |   `-- reponame2
    |       |-- README.md
    |       `-- some_plugin.zsh
    `-- username_B
        `-- reponame1
```

If you specify `as:cmd` in `zplug` command, zplug will recognize its plugin as command and create a symbolic link of the same name (if you want to rename, set `file:` specifier) within `$ZPLUG_HOME/bin`. Because zplug add `$ZPLUG_HOME/bin` to the `$PATH`, you can run that command from any directories.

#### `ZPLUG_THREADS`

It defaults to 16. It is default number of threads to use. 

#### `ZPLUG_PROTOCOL`

It defaults to HTTPS. You set HTTPS or SSH to `$ZPLUG_PROTOCOL`. Unless otherwise reason , you should use the HTTPS protocol.

For more information, see also [**Which remote URL should I use?** - GitHub Help](https://help.github.com/articles/which-remote-url-should-i-use/)

## Note

:warning: there are still some bugs. This plugin isn't ready to use yet.

## License

[MIT][license] © BABAROT

[license]: http://b4b4r07.mit-license.org