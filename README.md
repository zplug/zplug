# zplug v2

[![](https://travis-ci.org/b4b4r07/zplug2.svg?branch=master)](https://travis-ci.org/b4b4r07/zplug2)

This repository that is for zplug version 2.0.0 will be merged into [zplug](https://github.com/b4b4r07/zplug).

In addition, the specification is [here](https://github.com/b4b4r07/zplug/issues/71).

## Installation

```console
$ git clone https://github.com/b4b4r07/zplug ~/.zplug
```

## Migration

How to merge into zplug:

```console
$ git clone https://github.com/b4b4r07/zplug  ~/zplug
$ git clone https://github.com/b4b4r07/zplug2 ~/zplug2
$ cd ~/zplug
$ git remote add zplug2 ~/zplug2
$ git fetch zplug2
$ git merge zplug2/master
```

## Misc

For more details, see the man page with `man ./doc/man/man1/zplug.1`.
