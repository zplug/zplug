# zplug <sup>v2</sup>

[![](https://img.shields.io/travis/b4b4r07/zplug2.svg?style=flat-square)][travis]
[![](http://issuestats.com/github/b4b4r07/zplug/badge/issue?style=flat-square)][issuestats]
[![](http://issuestats.com/github/b4b4r07/zplug/badge/pr?style=flat-square)][issuestats]
[![](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)][license]
[![](https://img.shields.io/badge/zplug-v2.0.0-ca7f85.svg?style=flat-square)][history]
[![](https://img.shields.io/badge/gitter-join-FF2B6E.svg?style=flat-square)][gitter]
[![](https://img.shields.io/badge/documentation-wiki-00b0cc.svg?style=flat-square)][wiki]

This repository that is for zplug version 2.0.0 will be merged into [zplug](https://github.com/b4b4r07/zplug).

In addition, the specification is [here](https://github.com/b4b4r07/zplug/issues/71).

## Installation

```console
$ git clone https://github.com/b4b4r07/zplug2 ~/.zplug
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

[travis]: https://travis-ci.org/b4b4r07/zplug2
[issuestats]: http://issuestats.com/github/b4b4r07/zplug
[license]: http://b4b4r07.mit-license.org
[history]: https://github.com/b4b4r07/zplug/wiki/history
[gitter]: https://gitter.im/b4b4r07/zplug
[wiki]: https://github.com/b4b4r07/zplug/wiki