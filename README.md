<img src="https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/logo.png" height="150" alt="vim-plug">
===

[repo]: https://github.com/b4b4r07/zplug

`zplug` is next-generation zsh plugin manager

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/demo.gif)][repo]

## Pros.

- Manage everything (plugin, command, and gist file)
- Super-fast parallel installation/update
- Branch/tag/commit support
- Can manage UNIX commands
- Post-update hooks
- Support for externally managed plugins
- Can manage binaries (e.g., GitHub Releases)
- Creates shallow clones to minimize disk space usage and download time
- Understand dependencies between plugins
- Unlike [antigen](https://github.com/zsh-users/antigen), no ZSH plugin support file (`*.plugin.zsh`) is needed

## Installation

Download [zplug](https://git.io/zplug) and put it in `~/.zplug`

```console
$ curl -fLo ~/.zplug/zplug --create-dirs git.io/zplug
```

## Usage

Add a zplug section to your `.zshrc`:

1. List the plugins/commands with `zplug` commands
2. `zplug load` to source the plugins and add the commands to `$PATH`

### Example

```zsh
source ~/.zplug/zplug

# Make sure you use double quotes
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"

# Can manage plugin as command
zplug "junegunn/dotfiles", as:command, of:bin/vimcat
# Manage everything e.g. zshrc (alias)
zplug "tcnksm/docker-alias", of:zshrc
# Prohibit updating by using frozen
zplug "k4rthik/git-cal", as:command, frozen:1

# Grab binaries (from GitHub Releases)
# and rename to use "file:" specifier
zplug "junegunn/fzf-bin", \
    as:command, \
    from:gh-r, \
    file:fzf

# Run command after installed
zplug "tj/n", do:"make install"

# Support branch/tag/commit
zplug "b4b4r07/enhancd", at:v1
zplug "mollifier/anyframe", commit:4c23cb60

# Install if `if` specifier returns true
zplug "hchbaw/opp.zsh", if:"(( ${ZSH_VERSION%%.*} < 5 ))"

# Gist can be used
zplug "b4b4r07/79ee61f7c140c63d2786", \
    from:gist, \
    as:command, \
    of:get_last_pane_path.sh

# Group dependencies, emoji-cli depends on jq
zplug "stedolan/jq", \
    as:command, \
    file:jq, \
    from:gh-r \
    | zplug "b4b4r07/emoji-cli"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose
```

Then `zplug install` to install plugins and reload `.zshrc`.

### 1. `zplug` commands

|  Command  | Description | Option |
|-----------|-------------|--------|
| `install` | Install described items (plugins/commands) in parallel | `--verbose` |
| `load`    | Load installed items | `--verbose` |
| `list`    | List installed items | N/A |
| `update`  | Update items in parallel | `--self` |
| `check`   | Check whether an installation is available | `--verbose`,`--install` |
| `status`  | Check if remote is up-to-date | N/A |
| `clean`   | Remove repositories which are no longer used | `--force` |

#### Combinations

- `zplug check` and `zplug install`
- `zplug status` and `zplug update`

#### Take a closer look

```zsh
# zplug check return true if all plugins are installed
# Therefore, when it returns not true (thus false),
# run zplug install
if ! zplug check; then
    zplug install
fi

# source and add to the PATH
zplug load

# zplug check returns true if argument repository exists
if zplug check b4b4r07/enhancd; then
    # setting if enhancd is available
    export ENHANCD_FILTER=fzf-tmux
fi
```

#### Let zplug manage zplug

If you want to manage zplug by itself, to run this command (after installing zplug, of course):

```console
$ zplug update --self
```

By using `--self` option, zplug will be cloned to `$ZPLUG_HOME/repos` and be created symlink to `$ZPLUG_HOME/zplug`.

Then to start to manage zplug in the same way as any other plugins, please write the following in your `.zshrc`.

```zsh
zplug "b4b4r07/zplug"
```

All that's left is to run `zplug update`.

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/update.gif)][repo]

### 2. `zplug` specifiers

| Specifier | Description | Value (default) | Example |
|-----------|-------------|-----------------|---------|
| `as`      | Specify whether to register as commands or to register as plugins | `plugin`,`command` (`plugin`) | `as:command` |
| `of`      | Specify the pattern to source files (for `plugin`) or specify relative path to add to the `$PATH` (for `command`) | - (-) | `of:bin`,`of:*.zsh` |
| `from`    | Grab external binaries from e.g., GitHub Releases | `gh-r` (-) | `from:gh-r` |
| `at`      | Support branch/tag installation | branch/tag name (`master`) | `at:v1.5.6` |
| `file`    | Specify filename you want to rename | filename (-) | `file:fzf` |
| `dir`     | Installation directory | **READ ONLY** | -
| `if`      | Specify the conditions under which to perform (`source`, add `$PATH`) | true/false (-) | `if:"[ -d ~/.zsh ]"` |
| `do`      | Run commands after installation | commands (-) | `do:make` |
| `frozen`  | Do not update unless explicitly specified | 0,1 (0) | `frozen:1` |
| `commit`  | Support commit installation (regardless of whether the `$ZPLUG_SHALLOW` is true or not) | commit hash (-) | `commit:4428d48` |
| `on`      | Dependencies | **READ ONLY** | - |

#### Available on CLI

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/cli.gif)][repo]

### 3. `zplug` configurations

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

If you specify `as:command` in `zplug` command, zplug will recognize its plugin as command and create a symbolic link of the same name (if you want to rename, set `file:` specifier) within `$ZPLUG_HOME/bin`. Because zplug add `$ZPLUG_HOME/bin` to the `$PATH`, you can run that command from any directories.

#### `ZPLUG_THREADS`

It defaults to 16. It is default number of threads to use.

#### `ZPLUG_PROTOCOL`

It defaults to HTTPS. You set HTTPS or SSH to `$ZPLUG_PROTOCOL`. Unless otherwise reason , you should use the HTTPS protocol.

For more information, see also [**Which remote URL should I use?** - GitHub Help](https://help.github.com/articles/which-remote-url-should-i-use/)

#### `ZPLUG_SHALLOW`

It defaults to `true`. Use shallow clone. It creates a shallow clone with a history truncated to the specified number of revisions (depth 1).

## Note

- :tada: Released Beta version!!
- :construction: Until version 1.0.0 is released, zplug may be destructive changed.
- Not antigen :syringe: but **zplug** :hibiscus: will be here to stay from now on.
- :hibiscus: It was heavily inspired by [vim-plug](https://github.com/junegunn/vim-plug) and the likes.

## Other resources

[awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins) is a list of ZSH plugins, themes and completions that you can use with zplug.

## License

[MIT][license] © BABAROT

[license]: http://b4b4r07.mit-license.org
