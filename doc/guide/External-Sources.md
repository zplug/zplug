# Adding Sources

If there is a service/framework you want to install from that's not supported
by zplug (yet!), you can add your own. We call these "sources."
[GitHub](https://github.com), [Bitbucket](https://bitbucket.org), [GitHub
Gist](https://gist.github.com), GitHub releases,
[Gitlab](https://gitlab.com),
[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), and
[prezto](https://github.com/sorin-ionescu/prezto) are supported by default.
Sources are what you specify with the `from` tag (e.g. `from:bitbucket`), so
you will be able to do `from:my-foo-source`.  Writing your own sources brings
you the benefit of being able to tailor pre and post installation/loading
actions.

## What you need to do

Let's suppose we want a `foobar` source, that loads the content of the
file specified by the `use` tag or `$HOME/boo.zsh` if it exists. The first
step is to create a `foobar.zsh` in `$ZPLUG_ROOT/base/sources/`. The following
list shows the name of the functions that can be defined in this file.

- `__zplug::sources::foobar::load_plugin`
- `__zplug::sources::foobar::check`
- `__zplug::sources::foobar::install`
- `__zplug::sources::foobar::update`
- `__zplug::sources::foobar::get_url`
- `__zplug::sources::foobar::load_plugin`

Replace `foobar` with the name of your source.

## Add as a valid source

Add the name of your source to the `candidates` array in
`$ZPLUG_ROOT/autoload/tags/__from__`.

## Handlers

### `__zplug::foobar::check`

This function defines whether a package is currently installed or not. In our
case, we check that simply by looking at `$HOME/boo.zsh`. This function should
return 0 if the package is installed, and any other number (typically 1)
otherwise.

```zsh
__zplug::foobar::check()
{
    local    repo="$1"
    local -A tags

    tags[use]="$(
    __zplug::core::core::run_interfaces \
        'use' \
        "$repo"
    )"


    [[ -e $tags[use] ]] || [[ -e $HOME/boo.zsh ]]

    return $status
}
```

You can access the tag information using
`__zplug::core::core::run_interfaces` as shown above.

### `__zplug::foobar::install`

You can define how you want to install a package.

```zsh
__zplug::foobar::install() {
    local    repo="$1"
    local -A tags

    tags[use]="$(
    __zplug::core::core::run_interfaces \
        'use' \
        "$repo"
    )"

    tags[as]="$(
    __zplug::core::core::run_interfaces \
        'as' \
        "$repo"
    )"

    # Output to $zspec[use] if not empty, otherwise to boo.zsh
    echo "echo 'hi there'" > "$HOME/${tags[use]:-boo.zsh}"
    if [[ $tags[as] == command ]]; then
        chmod 755 "$HOME/${tags[use]:-boo.zsh}"
    fi

    return $status
}
```

### `__zplug::foobar::load_plugin`

This function is called when `as:plugin` is used. Following shows an example
of loading `$HOME/boo.zsh` as a plugin:

```zsh
__zplug::foobar::load_plugin() {
    local    repo="$1"
    local -A tags
    local -A default_tags
    local -a unclassified_plugins

    # Unused here, but can be useful in some cases
    local -a load_fpaths
    local -a load_plugins
    local -a nice_plugins
    local -a lazy_plugins

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )
    default_tags[use]="$(__zplug::core::core::run_interfaces 'use')"

    if [[ $tags[use] == $default_tags[use] ]]; then
        tags[use]="$HOME/boo.zsh"
    fi

    unclassified_plugins=( \
        __zplug::utils::shell::expand_glob "${tags[use]}" \
    )

    reply=()
    [[ -n $unclassified_plugins ]] && reply+=( unclassified_plugins "${(F)unclassified_plugins}" )

    return $status
}
```

Note the variables `unclassified_plugins`, `load_fpaths`, `load_plugins`,
`nice_plugins`, and `lazy_plugins`. Most of the times you should only need to
put the files you want to `source` into `unclassified_plugins`, because after
returning from this function the files will be organized into `load_plugins`
(for packages with `nice < 10`. Gets `source`d before `compinit`),
`nice_plugins` (`nice >= 10` packages. `source` after `compinit`), or
`lazy_plugins` (for `lazy:true` packages). Directories in `load_fpaths` will
be added to `fpath`.

When you want to expand a path that contains glob expressions, use
`__zplug::utils::shell::expand_glob "$path_to_expand"`. This takes care of the
details such as whether or not to use a sub-shell and whatnot. You can also
use the optional second argument to specify the default modifiers (like
`(N-.)`) that will be used in case the first argument doesn't contain one.

### `__zplug::foobar::load_command`

The idea of loading packages with `as:command` is pretty much the same as
`as:plugin`. The only difference is that you need to include the source and
the destination that will be used when linking the file. The destination in
almost all cases are `$ZPLUG_HOME/bin`.

```
__zplug::foobar::load_plugin() {
    local    repo="$1"
    local -A tags
    local -A default_tags
    local    dst
    local -a load_fpaths load_commands
    local -a sources

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )
    default_tags[use]="$(__zplug::core::core::run_interfaces 'use')"

    dst=${${tags[rename-to]:+$ZPLUG_HOME/bin/$tags[rename-to]}:-"$ZPLUG_HOME/bin"}

    # Add parent directories to fpath if any files starting in _* exist
    load_fpaths+=(${tags[dir]}/{_*,/**/_*}(N-.:h))

    sources=( ${(@f)"$( \
        __zplug::utils::shell::expand_glob "${tags[use]}" "(N-)"
    )"} )

    for src in "${sources[@]}"
    do
        load_commands+=("$src\0$dst")
    done

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_commands ]] && reply+=( load_commands "${(F)load_commands}" )

    return $status
}
```

In the for loop, the source (path to the file) and the destination are
concatenated with a `\0`.

Other sources can be found in `$ZPLUG_ROOT/base/sources`. Please take a look
at the existing sources and see how other handlers are written.
