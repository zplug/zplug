# How to make zsh plugins

## Plugins adaptively-optimized for zplug

### autoload plugins

***Pattern 1***:

```
.
├── autoload
│   └── plugin   <=[main file]
└── doc
    ├── man
    │   └── man1
    │       └── plugin.1
    └── plugin.txt

4 directories, 3 files
```

zplug can manage zsh plugins with lazy loading. When you specify `zplug "package", lazy:1`, zplug search the `autoload` directory within the plugin directory and load it with lazy.

***Pattern 2***:

Of cource, you don't need to make `autoload` directory but in this case, you must specify `of` tag like `zplug "package", lazy:1, of:"plugin/plugin"` to tell a plugin file to zplug.

```
.
├── doc
│   ├── man
│   │   └── man1
│   │       └── plugin.txt
│   └── plugin.txt
├── init.zsh     <=[trigger file]
└── plugin
    └── plugin   <=[main file]

4 directories, 4 files
```

`init.zsh`:

```zsh
local this="${${(%):-%N}:A:h}"

fpath=(
$this/plugin(N-/)
$fpath
)

unset this

autoload -Uz plugin
```

However, if you prepare `init.zsh` that is trigger of loading the plugin, `of` tag doesn't require because zplug scan `*.zsh` file automatically in the top directory and load it.

- [sample plugin](https://github.com/b4b4r07/zsh_plugin)

### normal plugins

...

### commands

...
