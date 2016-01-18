> Zsh Plugin Manager

<div align="center">
  <a href="http://github.com/flyjs">
    <img width=650px src="https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/logo.png">
  </a>
</div>
<br>

<p align="center">
<big></big>
</p>

<p align="center">
  <a href="http://zsh.sourceforge.net/releases.html">
    <img src="https://img.shields.io/badge/zsh-v4.3.9-orange.svg?style=flat-square"
         alt="Zsh version">
  </a>

  <a href="https://travis-ci.org/b4b4r07/zplug_test">
    <img src="https://img.shields.io/travis/b4b4r07/zplug_test.svg?style=flat-square"
         alt="Build Status">
  </a>

  <a href="https://github.com/b4b4r07/zplug/wiki">
    <img src="https://img.shields.io/badge/documentation-wiki-00b0cc.svg?style=flat-square"
         alt="Wiki pages">
  </a>

  <a href="http://b4b4r07.mit-license.org">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square"
         alt="License">
  </a>

  <a href="https://gitter.im/b4b4r07/zplug">
    <img src="https://img.shields.io/badge/gitter-join-FF2B6E.svg?style=flat-square"
         alt="Gitter">
  </a>
</p>

<p align="center">
  <b><a href="#proc">About</a></b>
  |
  <b><a href="#usage">Usage</a></b>
  |
  <b><a href="#1-zplug-commands">Commands</a></b>
  |
  <b><a href="#2-zplug-tags">Tags</a></b>
  |
  <b><a href="#3-zplug-configurations">Configurations</a></b>
  |
  <b><a href="#note">Note</a></b>

</p>

<br>

## Pros.

- Can manage everything
  - Zsh plugins/UNIX commands on [GitHub](https://github.com) and [Bitbucket](https://bitbucket.org)
  - Gist file ([gist.github.com](https://gist.github.com))
  - Externally managed plugins e.g., [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) plugins/themes
  - Birary artifacts on [GitHub Releases](https://help.github.com/articles/about-releases/)
  - Local plugins
  - etc.
- Super-fast parallel installation/update
- Branch/tag/commit support
- Post-update hooks
- Dependencies between plugins
- Unlike [antigen](https://github.com/zsh-users/antigen), no ZSH plugin file (`*.plugin.zsh`) required
- Interactive interface ([fzf](https://github.com/junegunn/fzf), [peco](https://github.com/peco/peco), [zaw](https://github.com/zsh-users/zaw), and so on)
- Cache mechanism for reducing [the startup time](#vs)

***DEMO:***

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/install.gif)][repo]

## Installation

Download [zplug](https://git.io/zplug) and put it in `~/.zplug`

```console
$ git clone https://github.com/b4b4r07/zplug ~/.zplug
```

## Usage

Add a zplug section to your `.zshrc`:

1. List the plugins/commands with `zplug` commands
2. `zplug load` to source the plugins and add its commands to your `$PATH`

### Example

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/example.png)][repo]

```zsh
source ~/.zplug/zplug

# Make sure you use double quotes
zplug "zsh-users/zsh-history-substring-search"

# Can manage a plugin as a command
# And accept glob patterns (e.g., brace, wildcard, ...)
zplug "Jxck/dotfiles", as:command, of:"bin/{histuniq,color}"

# Can manage everything e.g., other person's zshrc
zplug "tcnksm/docker-alias", of:zshrc

# Prohibit updates to a plugin by using the "frozen:" tag
zplug "k4rthik/git-cal", as:command, frozen:1

# Grab binaries from GitHub Releases
# and rename to use "file:" tag
zplug "junegunn/fzf-bin", \
    as:command, \
    from:gh-r, \
    file:fzf, \
    of:"*darwin*amd64*"

# Support oh-my-zsh plugins and the like
zplug "plugins/git",   from:oh-my-zsh, if:"which git"
zplug "themes/duellj", from:oh-my-zsh
zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

# Run a command after a plugin is installed/updated
zplug "tj/n", do:"make install"

# Support checking out a specific branch/tag/commit of a plugin
zplug "b4b4r07/enhancd", at:v1
zplug "mollifier/anyframe", commit:4c23cb60

# Install if "if:" tag returns true
zplug "hchbaw/opp.zsh", if:"(( ${ZSH_VERSION%%.*} < 5 ))"

# Can manage gist file just like other plugins
zplug "b4b4r07/79ee61f7c140c63d2786", \
    from:gist, \
    as:command, \
    of:get_last_pane_path.sh

# Support bitbucket
zplug "b4b4r07/hello_bitbucket", \
    as:command, \
    from:bitbucket, \
    do:"chmod 755 *.sh", \
    of:"*.sh"

# Group dependencies, emoji-cli depends on jq in this example
zplug "stedolan/jq", \
    as:command, \
    file:jq, \
    from:gh-r \
    | zplug "b4b4r07/emoji-cli"

# Set priority to load command like a nice command
# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
zplug "zsh-users/zsh-syntax-highlighting", nice:10

# Can manage local plugins
zplug "~/.zsh", from:local
# A relative path is resolved with respect to the $ZPLUG_HOME
zplug "repos/robbyrussell/oh-my-zsh/custom/plugins/my-plugin", from:local

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

### 1. `zplug` commands

|  Command  | Description | Option |
|-----------|-------------|--------|
| `install` | Install described items (plugins/commands) in parallel | `--verbose`,`--select` |
| `load`    | Source installed plugins and add installed commands to `$PATH` | `--verbose` |
| `list`    | List installed items (Strictly speaking, view the associative array `$zplugs`) | `--select` |
| `update`  | Update installed items in parallel | `--self`,`--select` |
| `check`   | Return false if there are not installed items | `--verbose` |
| `status`  | Check if the remote repositories are up to date | `--select` |
| `clean`   | Remove repositories which are no longer managed | `--force`,`--select` |
| `clear`   | Remove the cache file | `--force` |

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

If you want to manage zplug by itself, run this command (after installing zplug, of course):

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

### 2. `zplug` tags

| Tag | Description | Value (default) | Example |
|-----------|-------------|-----------------|---------|
| `as`      | Specify whether to register as commands or to register as plugins | `plugin`,`command` (`plugin`) | `as:command` |
| `of`      | Specify the pattern to source files (for `plugin`) or specify relative path to add to the `$PATH` (for `command`) / In case of `from:gh-r`, can specify `of:"*darwin*{amd,386}*"` and so on | *glob* (`of:"*.zsh"`) | `of:bin`,`of:"*.sh"`, `of:*darwin*` |
| `from`    | Specify the services you use to install | `github`,`bitbucket`,<br>`gh-r`,`gist`,<br>`oh-my-zsh`,`local` (`github`) | `from:gh-r` |
| `at`      | Support branch/tag installation | *branch/tag* (`master`) | `at:v1.5.6` |
| `file`    | Specify filename you want to rename (only `as:plugin`) | *filename* (-) | `file:fzf` |
| `dir`     | Installation directory which is managed by zplug | **READ ONLY** | `dir:/path/to/user/repo` |
| `if`      | Specify the conditions under which to run `source` or add to `$PATH` | *boolean* (-) | `if:"[ -d ~/.zsh ]"` |
| `do`      | Run commands after installation/update | *commands* (-) | `do:make install` |
| `frozen`  | Do not update unless explicitly specified | 0,1 (0) | `frozen:1` |
| `commit`  | Support commit installation (regardless of whether the `$ZPLUG_SHALLOW` is true or not) | *revision* (-) | `commit:4428d48` |
| `on`      | Dependencies | **READ ONLY** | `on:user/repo` |
| `nice`    | Priority of loading the plugins. If this tag is specified 10 or more, zplug will load plugins after `compinit` (see also [#26](https://github.com/b4b4r07/zplug/issues/26)) | -20..19 (0) | `nice:19` |
| `ignore`  | Similar to `of` tag, specify exception pattern so as not to load the files you want to ignore (see also [#56](https://github.com/b4b4r07/zplug/issues/56)) | *glob* (-) | `ignore:"some_*.zsh"` |

#### Available on CLI

You can register plugins or commands to zplug on the command-line. If you use zplug on the command-line, it is possible to write more easily its settings by grace of the command-line completion.

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/cli.gif)][repo]

In this case, zplug spit out its settings to `$ZPLUG_EXTERNAL` instead of `.zshrc`. If you launch new zsh process, `zplug load` command automatically search this file and run `source` command.

### 3. `zplug` configurations

#### `ZPLUG_HOME`

Defaults to `~/.zplug`. `zplug` will store/load plugins in this directory. The directory structure is below.

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

If you specify `as:command` in `zplug` command, zplug will recognize the plugin as a command and create a symbolic link of the same name (if you want to rename it, set `file:` tag) within `$ZPLUG_HOME/bin`. Because zplug adds `$ZPLUG_HOME/bin` to the `$PATH`, you can run that command from any directories.

#### `ZPLUG_THREADS`

The number of threads zplug should use. The default value is 16.

#### `ZPLUG_PROTOCOL`

Defaults to HTTPS. Valid options for `$ZPLUG_PROTOCOL` are HTTPS or SSH. Unless you have a specific reason, you should use the HTTPS protocol.

For more information, see also [**Which remote URL should I use?** - GitHub Help](https://help.github.com/articles/which-remote-url-should-i-use/)

#### `ZPLUG_SHALLOW`

Defaults to `true`. When cloning a Git repository, there is an option to limit the amount of history your clone will have. If you set this environment variable to `true`, you get the least amount of history, and you create a shallow clone.

#### `ZPLUG_FILTER`

Defaults to `fzf-tmux:fzf:peco:percol:zaw`. When `--select` option is specified, colon-separated first element that exists in the `$PATH` will be used by zplug as the interactive filter. The `ZPLUG_FILTER` also accepts the following values: `fzf-tmux -d "10%":/path/to/peco:my peco`.

#### `ZPLUG_EXTERNAL`

Defaults to `$ZPLUG_HOME/init.zsh`. This file is used to add plugins from zplug on the command-line.

#### `ZPLUG_USE_CACHE`

Defaults to `true`. If this variable is set, zplug comes to use a cache to speed up when it will load plugins after the first. The cache file is located in `$ZPLUG_HOME/.cache`. If you want to clear the cache, please run `zplug clear` or do the following:

```console
$ ZPLUG_USE_CACHE=false zplug load
```

## V.S.

zplug is the fastest of famous plugin managers for zsh. The figures are graphs showing the facts.

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/time.png)][repo]

## Note

- :tada: Congrats! Released v1.0.0 version!!
- ~~:construction: Until version 1.0.0 is released, `zplug` may be changed in ways that are not backward compatible.~~
- :art: Design vision
  - Fantabulous plugin
  - Without simple, but without complex
  - Manage everything
- Not antigen :syringe: but **zplug** :hibiscus: will be here to stay from now on.
- :hibiscus: It was heavily inspired by [vim-plug](https://github.com/junegunn/vim-plug), [neobundle.vim](https://github.com/Shougo/neobundle.vim) and the like.

## Other resources

[awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins) is a list of ZSH plugins, themes and completions that you can use with zplug.

## License

[MIT][license] © BABAROT

[repo]: https://github.com/b4b4r07/zplug
[travis]: https://travis-ci.org/b4b4r07/zplug_test
[license]: http://b4b4r07.mit-license.org
