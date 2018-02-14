:us: [:jp:](./doc/guide/ja/README.md)

> Zsh Plugin Manager

[![Travis][travis-badge]][travis-link]
[![Latest][latest-badge]][latest-link]
[![Slack][slack-badge]][slack-link]

<div align="center">
  <a href="http://zplug.sh">
    <img width=650px src="https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/logo.png">
  </a>
</div>
<br>

## Pros.

- Can manage everything
  - Zsh plugins/UNIX commands on [GitHub](https://github.com) and [Bitbucket](https://bitbucket.org)
  - Gist files ([gist.github.com](https://gist.github.com))
  - Externally managed plugins e.g., [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) and [prezto](https://github.com/sorin-ionescu/prezto) plugins/themes
  - Binary artifacts on [GitHub Releases](https://help.github.com/articles/about-releases/)
  - Local plugins
  - etc. (you can add your [own sources](https://github.com/zplug/zplug/blob/master/doc/guide/External-Sources.md)!)
- Super-fast parallel installation/update
- Support for lazy-loading
- Branch/tag/commit support
- Post-update, post-load hooks
- Dependencies between packages
- Unlike [antigen](https://github.com/zsh-users/antigen), no ZSH plugin file (`*.plugin.zsh`) required
- Interactive interface ([fzf](https://github.com/junegunn/fzf), [peco](https://github.com/peco/peco), [zaw](https://github.com/zsh-users/zaw), and so on)
- Cache mechanism for reducing [the startup time](#vs)

***DEMO:***

<!-- [![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/install.gif)][repo] -->
[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/demo.gif)][repo]

## Installation

latest | stable
---|---
[![Latest][latest-badge]][latest-link] | [![Stable][stable-badge]][stable-link]

### The best way

```console
$ curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
```

Curious about the installation script? Check it out at [zplug/installer](https://github.com/zplug/installer/blob/master/installer.zsh).

### Using [Homebrew](https://github.com/Homebrew/brew) (OS X)

```console
$ brew install zplug
```

### Manually

Cloning from GitHub, and source `init.zsh`:

```console
$ export ZPLUG_HOME=/path/to/.zplug
$ git clone https://github.com/zplug/zplug $ZPLUG_HOME
```

## Requirements

- `zsh`: version 4.3.9 or higher
- `git`: version 1.7 or higher
- `awk`: An AWK variant that's **not** `mawk`

## Usage

Add a zplug section to your `.zshrc`:

1. List the packages with `zplug` commands
2. `zplug load` to source the plugins and add commands to your `$PATH`

### Example

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/example.png)][repo]

```zsh
source ~/.zplug/init.zsh

# Make sure to use double quotes
zplug "zsh-users/zsh-history-substring-search"

# Use the package as a command
# And accept glob patterns (e.g., brace, wildcard, ...)
zplug "Jxck/dotfiles", as:command, use:"bin/{histuniq,color}"

# Can manage everything e.g., other person's zshrc
zplug "tcnksm/docker-alias", use:zshrc

# Disable updates using the "frozen" tag
zplug "k4rthik/git-cal", as:command, frozen:1

# Grab binaries from GitHub Releases
# and rename with the "rename-to:" tag
zplug "junegunn/fzf-bin", \
    from:gh-r, \
    as:command, \
    rename-to:fzf, \
    use:"*darwin*amd64*"

# Supports oh-my-zsh plugins and the like
zplug "plugins/git",   from:oh-my-zsh

# Also prezto
zplug "modules/prompt", from:prezto

# Load if "if" tag returns true
zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

# Run a command after a plugin is installed/updated
# Provided, it requires to set the variable like the following:
# ZPLUG_SUDO_PASSWORD="********"
zplug "jhawthorn/fzy", \
    as:command, \
    rename-to:fzy, \
    hook-build:"make && sudo make install"

# Supports checking out a specific branch/tag/commit
zplug "b4b4r07/enhancd", at:v1
zplug "mollifier/anyframe", at:4c23cb60

# Can manage gist file just like other packages
zplug "b4b4r07/79ee61f7c140c63d2786", \
    from:gist, \
    as:command, \
    use:get_last_pane_path.sh

# Support bitbucket
zplug "b4b4r07/hello_bitbucket", \
    from:bitbucket, \
    as:command, \
    use:"*.sh"

# Rename a command with the string captured with `use` tag
zplug "b4b4r07/httpstat", \
    as:command, \
    use:'(*).sh', \
    rename-to:'$1'

# Group dependencies
# Load "emoji-cli" if "jq" is installed in this example
zplug "stedolan/jq", \
    from:gh-r, \
    as:command, \
    rename-to:jq
zplug "b4b4r07/emoji-cli", \
    on:"stedolan/jq"
# Note: To specify the order in which packages should be loaded, use the defer
#       tag described in the next section

# Set the priority when loading
# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
# (If the defer tag is given 2 or above, run after compinit command)
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Can manage local plugins
zplug "~/.zsh", from:local

# Load theme file
zplug 'dracula/zsh', as:theme

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

Finally, use `zplug install` to install your plugins and reload `.zshrc`.

### 1. Options for `zplug`

| Option          | Description |
|-----------------|-------------|
| `--help`        | Display the help message |
| `--rollback`    | Rollback a failed package |
| `--self-manage` | Self management of zplug |
| `--version`     | Display the version of zplug |
| `--log`         | Show the report of zplug errors |

### 2. Commands for `zplug`

|  Command  | Description | Options |
|-----------|-------------|---------|
| `install` | Install packages in parallel | (None) |
| `load`    | Source installed plugins and add installed commands to `$PATH` | `--verbose` |
| `list`    | List installed packages (more specifically, view the associative array `$zplugs`) | `--select`,`--installed`,`--loaded` |
| `update`  | Update installed packages in parallel | `--select`,`--force` |
| `check`   | Return true if all packages are installed, false otherwise | `--verbose` |
| `status`  | Check if the remote repositories are up to date | `--select` |
| `clean`   | Remove repositories which are no longer managed | `--force`,`--select` |
| `clear`   | Remove the cache file | (None) |
| `info`    | Show the information such as the source URL and tag values for the given package | (None) |

#### Take a closer look

```zsh
# zplug check returns true if all packages are installed
# Therefore, when it returns false, run zplug install
if ! zplug check; then
    zplug install
fi

# source plugins and add commands to the PATH
zplug load

# zplug check returns true if the given repository exists
if zplug check b4b4r07/enhancd; then
    # setting if enhancd is available
    export ENHANCD_FILTER=fzf-tmux
fi
```

#### Let zplug manage zplug

To manage zplug itself like other packages, write the following in your `.zshrc`.

```zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
```

All that's left is to run `zplug update`.

<!-- [![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/update.gif)][repo] -->

### 3. Tags for `zplug`

`truthy` is any of `true`, `yes`, `on`, `1` and `falsy` is any of `false`, `no`, `off`, `0`.

| Tag | Description | Value (default) | Example |
|-----|-------------|-----------------|---------|
| `as`          | Specify whether to register the package as plugins or commands | `plugin`,`command`,`theme` (`plugin`) | `as:command` |
| `use`         | Specify the pattern of the files to source (for `plugin`) or the relative path to add to the `$PATH` (for `command`) / With `from:gh-r`, zplug tries to guess which file to use from your OS and architecture. You can manually specify `use:"*darwin*{amd,386}*"` if that doesn't get the right file. | *glob* (`use:"*.zsh"`) | `use:bin`,`use:"*.sh"`, `use:*darwin*` |
| `ignore`      | Similar to `use` tag, but specify pattern of files you want to ignore (see also [#56](https://github.com/zplug/zplug/issues/56)) | *glob* (-) | `ignore:"some_*.zsh"` |
| `from`        | Specify where to get the package from | `github`,`bitbucket`,<br>`gh-r`,`gist`,<br>`oh-my-zsh`,`prezto`,`local` (`github`) | `from:gh-r` |
| `at`          | Specify branch/tag/commit to install | *revision* (`master`) | `at:v1.5.6` |
| `rename-to`   | Specify the filename you want to rename the command to (use this only with `as:command`) | *filename* (-) | `rename-to:fzf` |
| `dir`         | Installed directory of the package | **READ ONLY** | `dir:/path/to/user/repo` |
| `if`          | Specify the conditions under which to install and use the package | *boolean* (-) | `if:"[ -d ~/.zsh ]"` |
| `hook-build`  | Commands to after installation/update | *commands* (-) | `hook-build:"make install"` |
| `hook-load`   | Commands to after loading | *commands* (-) | `hook-load:"echo 'Loaded!'"` |
| `frozen`      | Do not update unless explicitly specified | truthy,falsy (false) | `frozen:1` |
| `on`          | Load this package only if a different package is installed | *package* | `on:user/repo` |
| `defer`        | Defers the loading of a package. If the value is 2 or above, zplug will source the plugin after `compinit` (see also [#26](https://github.com/zplug/zplug/issues/26)) | 0..3 (0) | `defer:2` |
| `lazy`        | Whether it is an autoload function or not | truthy,falsy (false) | `lazy:true` |
| `depth`       | The number of commits to include in the cloned repository. 0 means the whole history. | Any non-negative integer | `depth:10` |

#### Changing the defaults

You can use `zstyle` to change the default value. The format is:

```zsh
zstyle ":zplug:tag" tag_name new_default_value
```

For example, if you have a lot of commands and not so many plugins, (i.e. if
you find yourself specifying `as:command` often), you can do:

```zsh
zstyle ":zplug:tag" as command
```

The default value for all tags can be changed in this way.

#### Available on CLI

You can register packages to zplug from the command-line. If you use zplug from the command-line, it is possible to add stuff more easily with the help of powerful zsh completions.

<!-- [![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/cli.gif)][repo] -->

In this case, zplug spit out its settings to `$ZPLUG_LOADFILE` instead of `.zshrc`. If you launch new zsh process, `zplug load` command automatically search this file and run `source` command.

See [`ZPLUG_LOADFILE`](#zplug_loadfile) for other usage of `ZPLUG_LOADFILE`.

### 4. Environment variables for `zplug`

#### `ZPLUG_HOME`

Defaults to `~/.zplug`. `zplug` will store/load packages in this directory. The directory structure is shown below.

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

If you specify `as:command`, zplug will see the package as a command and create a symbolic link of the same name (if you want to rename it, use the `rename-to:` tag) in `$ZPLUG_BIN`. Because zplug adds `$ZPLUG_BIN` to the `$PATH`, you can run that command from anywhere.

#### `ZPLUG_THREADS`

The number of threads zplug uses when installing/updating. The default value is 16.

#### `ZPLUG_PROTOCOL`

Defaults to HTTPS. Valid options are `HTTPS` and `SSH`. Unless you have a specific reason, you should use the HTTPS protocol.

For more information, see also [**Which remote URL should I use?** - GitHub Help](https://help.github.com/articles/which-remote-url-should-i-use/)

#### `ZPLUG_FILTER`

Defaults to `fzf-tmux:fzf:peco:percol:zaw`. When `--select` option is specified, the first element in the colon-separated list that exists in the `$PATH` will be used by zplug as the interactive filter. You can also use spaces and double quotes in `ZPLUG_FILTER` like: `fzf-tmux -d "10%":/path/to/peco:my peco`.

#### `ZPLUG_LOADFILE`

Defaults to `$ZPLUG_HOME/packages.zsh`. This file is used to add plugins from zplug on the command-line. It is also a useful place to isolate your packages list from `.zshrc`. Rather than cluttering your `.zshrc` with many lines enumerating packages, you can put them in a separate file and set `ZPLUG_LOADFILE` to its path.

#### `ZPLUG_USE_CACHE`

Defaults to `true`. If this variable is true, zplug will use cache files to speed up the load process. The cache files are saved under the `$ZPLUG_CACHE_DIR` directory. If you want to clear the cache, please run `zplug clear` or do the following:

```console
$ ZPLUG_USE_CACHE=false zplug load
```

#### `ZPLUG_CACHE_DIR`

Defaults to `$ZPLUG_HOME/.cache`. You can change where the cache file is saved, for example, `~/.cache/zplug`.

#### `ZPLUG_REPOS`

Defaults to `$ZPLUG_HOME/repos`. You can change where the repositories are cloned in case you want to manage them separately.

#### `ZPLUG_SUDO_PASSWORD`

Defaults to `''`. You can set sudo password for zplug's `hook-build` tag. However, this variable should not be managed in dotfiles and so on.

```zsh
# your .zshrc
source ~/.zshrc_secret
zplug "some/command", hook-build:"make && sudo make install"
```

#### `ZPLUG_BIN`

Defaults to `$ZPLUG_HOME/bin`. You can change the save destination of the command's symbolic link, e.g. `~/bin`.

### External commands

zplug, like `git(1)`, supports external commands.
These are executable scripts that reside somewhere in the PATH, named `zplug-cmdname`,
which can be invoked with `zplug cmdname`.
This allows you to create your own commands without modifying zplug's internals.
Instructions for creating your own commands can be found in the [docs](https://github.com/zplug/zplug/blob/master/doc/zplug/External-Commands.md).
Check out the sample [`zplug-env`](https://github.com/zplug/zplug/blob/master/bin/zplug-env) external command for an example.

## V.S.

zplug is the fastest among the famous zsh plugin managers. Numbers? Here they are:

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/time.png)][repo]

## Note

- Not antigen :syringe: but **zplug** :hibiscus: will be here for you from now on.
- :hibiscus: It was heavily inspired by [vim-plug](https://github.com/junegunn/vim-plug), [neobundle.vim](https://github.com/Shougo/neobundle.vim) and the like.

## Other resources

[awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins) is a list of ZSH plugins, themes and completions that you can use with zplug.

For migration from antigen, zgen, or zplug v1, check out the [wiki
page](https://github.com/zplug/zplug/wiki/Migration).

## License

[MIT][license] (c) [@b4b4r07](https://github.com/b4b4r07)

[repo]: https://github.com/zplug/zplug
[license]: http://b4b4r07.mit-license.org
[travis-link]: https://travis-ci.org/zplug/zplug
[travis-badge]: https://img.shields.io/travis/zplug/zplug.svg?style=flat-square
[latest-badge]: https://img.shields.io/badge/latest-v2.4.2-ca7f85.svg?style=flat-square
[latest-link]: https://github.com/zplug/zplug/releases/latest
[stable-badge]: https://img.shields.io/badge/stable-v2.3.2-e9a326.svg?style=flat-square
[stable-link]: https://github.com/zplug/zplug/releases/tag/2.3.2
[slack-link]: https://zplug.herokuapp.com
[slack-badge]: https://img.shields.io/badge/slack-join-ca7f85.svg?style=flat-square
