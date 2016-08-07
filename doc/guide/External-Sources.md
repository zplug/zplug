# External Sources

If there is a service/framework you want to install from that's not supported
by zplug (yet!), you can add your own. We call these external sources as
opposed to the sources such as [GitHub](https://github.com),
[Bitbucket](https://bitbucket.org),
[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), etc. that are
supported by zplug by default. Sources are what you specify with the `from`
tag (e.g. `from:bitbucket`), so you will be able to do `from:my-foo-source`.
Writing your own sources brings you the benefit of being able to tailor pre
and post installation/loading actions.

## What you need to do

Let's suppose we want a `peek-a-boo` source, that loads the content of the
file specified by the `use` tag or `$HOME/boo.zsh` if it exists. The first
step is to create a `peek-a-boo.zsh` in `$ZPLUG_ROOT/base/sources/`. Once we've
done that, there are four functions that we can choose to define, or just use
the default action: `check`, `install`, `load_command`, and `load_plugin`.

## Handlers

Make sure you replace the `peek-a-boo`s in the function name with whatever
name your external source is.

### `__zplug::peek-a-boo::check`

This function defines whether a package is currently installed or not. In our
case, we check that simply by looking at `$HOME/boo.zsh`. This function should
return 0 if the package is installed, and any other number (typically 1)
otherwise.

```zsh
__zplug::peek-a-boo::check() {
    __parser__ "$1"
    zspec=( "${reply[@]}" )

    [[ -e $zspec[use] ]] || [[ -e $HOME/boo.zsh ]]
}
```

`zspec` contains all the necessary tag information like `as`, `from` (although
this will always be the name of the external source) and such.

### `__zplug::peek-a-boo::install`

You can define how you want to install a package.

```zsh
__zplug::peek-a-boo::install() {
    __parser__ "$1"
    zspec=( "${reply[@]}" )

    # Output to $zspec[use] if not empty, otherwise to boo.zsh
    echo "echo 'hi there'" > "${zspec[use]:-boo.zsh}"
    if [[ $zspec[as] == command ]]; then
        chmod 755 "${zspec[use]:-boo.zsh}"
    fi

    return $status
}
```

### `__zplug::peek-a-boo::load_plugin`

This function is called when `as:plugin` is used. Following is a template that
you can stick into the beginning of your handler function:

```zsh
__zplug::my-source-name::load_plugin() {
    local    line
    local -A zspec

    line="$1"
    __parser__ "$line"
    zspec=( "${reply[@]}" )

    local -a load_plugins load_fpaths lazy_plugins
    local -a load_patterns
    local -a themes_ext plugins_ext

    ...

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_patterns ]] && reply+=( load_patterns "${(F)load_patterns}" )
    [[ -n $load_plugins ]] && reply+=( load_plugins "${(F)load_plugins}" )
    [[ -n $nice_plugins ]] && reply+=( nice_plugins "${(F)nice_plugins}" )
    [[ -n $themes_ext ]] && reply+=( themes_ext "${(F)themes_ext}" )
    [[ -n $plugins_ext ]] && reply+=( plugins_ext "${(F)plugins_ext}" )

    return 0
}
```

The key variables are the the six local arrays declared. You normally only
need to put the paths of the files you want to source in `load_patterns`, and
zplug will later figure out whether it should go into `load_plugins`
(immediately sorced), `nice_plugins` (sourced after `compinit`), or
`lazy_plugins` (only added to `$fpath`). `src/ext/local.zsh` is a good example
of this in action. It's generally a good idea to just put the paths into one
of the arrays, but you can source the file within the handler like the
following example.


```zsh
__zplug::peek-a-boo::load_plugin() {
    __parser__ "$1"
    zspec=( "${reply[@]}" )

    source "${zspec[use]:-boo.zsh}"

    return $status
}
```

### `__zplug::peek-a-boo::load_command`

We can choose to use the default zplug behavior for commands. By not defining
the function, zplug will create a symlink to `$ZPLUG_ROOT/bin` so that you can
use it as a command. You can add customize the source path and the destination
path as well as what directories to add to the `$fpath`.

```zsh
__zplug::my-source-name::load_command() {
    local    line
    local -A zspec

    line="$1"
    __parser__ "$line"
    zspec=( "${reply[@]}" )

    local -a load_fpaths
    local -a load_commands
    local dst

    dst=${${zspec[rename-to]:+$ZPLUG_HOME/bin/$zspec[rename-to]}:-"$ZPLUG_HOME/bin"}

    ...

    load_commands=( ${^load_commands}"\0$dst" )

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_commands ]] && reply+=( load_commands "${(F)load_commands}" )

    return 0
}
```

The idea is the same as the `load_plugin` function, but there is a catch:
since `load_commands` in the `__load__` file is an associative array with keys
being the source and values being the destination, you need to take that into
account when constructing the `reply`. The source and destination are
separated by a `\0` (null character).
