[:us:](../../../README.md) :jp:

> Zsh のプラグインマネージャー

[![Travis][travis-badge]][travis-link]
[![Latest][latest-badge]][latest-link]
[![Slack][slack-badge]][slack-link]

<div align="center">
  <a href="http://zplug.sh">
    <img width=650px src="https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/logo.png">
  </a>
</div>
<br>

## メリット

- 何でも管理できる
  - [GitHub](https://github.com) や [Bitbucket](https://bitbucket.org) にあるプラグインや UNIX コマンド
  - Gist ファイル ([gist.github.com](https://gist.github.com))
  - 外部フレームワークなどのプラグイン (例: [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) や [prezto](https://github.com/sorin-ionescu/prezto) のプラグイン・テーマ)
  - [GitHub Releases](https://help.github.com/articles/about-releases/) のバイナリファイル
  - ローカルプラグイン
  - その他 ([カスタムソース](https://github.com/zplug/zplug/blob/master/doc/zplug/External-Sources.md)によって追加できる)
- 高速インストール・高速アップデート
- 遅延読み込みに対応
- リビジョンロック(ブランチやタグを固定する機能)
- `post-update` 等のフック機能
- パッケージ間の依存管理
- [antigen](https://github.com/zsh-users/antigen) とは違って、`*.plugin.zsh` を必要としない
- 対話的インターフェイス([fzf](https://github.com/junegunn/fzf), [peco](https://github.com/peco/peco), [zaw](https://github.com/zsh-users/zaw) など)
- キャッシュ機能による読み込み高速化 ([起動時間](#vs))

***DEMO:***

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/demo.gif)][repo]

## インストール

最新版 | 安定版
---|---
[![Latest][latest-badge]][latest-link] | [![Stable][stable-badge]][stable-link]

### 推奨方法

```console
$ curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
```

インストーラの実態:

- [zplug/installer](https://github.com/zplug/installer/blob/master/installer.zsh)

### [Homebrew](https://github.com/Homebrew/brew) から (OS X)

```console
$ brew install zplug
```

### git から

GitHub からクローンしてきて `init.zsh` を読み込む:

```console
$ export ZPLUG_HOME=/path/to/.zplug
$ git clone https://github.com/zplug/zplug $ZPLUG_HOME
```

## 必要条件

- `zsh`: バージョン 4.3.9 以上
- `git`: バージョン 1.7 以上
- `awk`: `mawk` 以外の AWK 処理系

## 利用方法

`.zshrc` に以下を書き込む:

1. `zplug` commands でインストールするパッケージについて書く
2. `zplug load` によりプラグインを読み込み、コマンドを `$PATH` に追加するようにする

### Example

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/example.png)][repo]

```zsh
source ~/.zplug/init.zsh

# ダブルクォーテーションで囲うと良い
zplug "zsh-users/zsh-history-substring-search"

# コマンドも管理する
# グロブを受け付ける（ブレースやワイルドカードなど）
zplug "Jxck/dotfiles", as:command, use:"bin/{histuniq,color}"

# こんな使い方もある（他人の zshrc）
zplug "tcnksm/docker-alias", use:zshrc

# frozen タグが設定されているとアップデートされない
zplug "k4rthik/git-cal", as:command, frozen:1

# GitHub Releases からインストールする
# また、コマンドは rename-to でリネームできる
zplug "junegunn/fzf-bin", \
    from:gh-r, \
    as:command, \
    rename-to:fzf, \
    use:"*darwin*amd64*"

# oh-my-zsh をサービスと見なして、
# そこからインストールする
zplug "plugins/git",   from:oh-my-zsh

# if タグが true のときのみインストールされる
zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

# prezto のプラグインやテーマを使用する
zplug "modules/osx", from:prezto, if:"[[ $OSTYPE == *darwin* ]]"
zplug "modules/prompt", from:prezto
# zstyle は zplug load の前に設定する
zstyle ':prezto:module:prompt' theme 'sorin'

# インストール・アップデート後に実行されるフック
# この場合は以下のような設定が別途必要
# ZPLUG_SUDO_PASSWORD="********"
zplug "jhawthorn/fzy", \
    as:command, \
    rename-to:fzy, \
    hook-build:"make && sudo make install"

# リビジョンロック機能を持つ
zplug "b4b4r07/enhancd", at:v1
zplug "mollifier/anyframe", at:4c23cb60

# Gist ファイルもインストールできる
zplug "b4b4r07/79ee61f7c140c63d2786", \
    from:gist, \
    as:command, \
    use:get_last_pane_path.sh

# bitbucket も
zplug "b4b4r07/hello_bitbucket", \
    from:bitbucket, \
    as:command, \
    use:"*.sh"

# `use` タグでキャプチャした文字列でリネームする
zplug "b4b4r07/httpstat", \
    as:command, \
    use:'(*).sh', \
    rename-to:'$1'

# 依存管理
# "emoji-cli" は "jq" があるときにのみ読み込まれる
zplug "stedolan/jq", \
    from:gh-r, \
    as:command, \
    rename-to:jq
zplug "b4b4r07/emoji-cli", \
    on:"stedolan/jq"
# ノート: 読み込み順序を遅らせるなら defer タグを使いましょう

# 読み込み順序を設定する
# 例: "zsh-syntax-highlighting" は compinit の後に読み込まれる必要がある
# （2 以上は compinit 後に読み込まれるようになる）
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# ローカルプラグインも読み込める
zplug "~/.zsh", from:local

# テーマファイルを読み込む
zplug 'dracula/zsh', as:theme

# 未インストール項目をインストールする
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
zplug load --verbose
```

最後に、 `zplug install` でプラグインをインストールし、`.zshrc`をリロードする

### 1. オプション

| オプション      | 説明 |
|-----------------|------|
| `--help`        | ヘルプを表示する |
| `--rollback`    | インストールに失敗したパッケージをロールバックする |
| `--self-manage` | zplug自身をzplugで管理する |
| `--version`     | バージョン情報を表示する |
| `--log`         | ログを見る（開発者向け） |

### 2. サブコマンド

|  サブコマンド  | 説明 | そのオプション |
|-----------|-------------|---------|
| `install` | 並列インストール | (なし) |
| `load`    | インストール済みプラグインを読み込み、インストール済みコマンドを `$PATH` に追加する | `--verbose` |
| `list`    | インストール済みパッケージを表示する (端的に連想配列 `$zplugs` を表示する) | `--select`,`--installed`,`--loaded` |
| `update`  | インストール済みパッケージを並列でアップデートする | `--select`,`--force` |
| `check`   | 未インストールなパッケージがないなら真を返し、そうでなければ偽を返す | `--verbose` |
| `status`  | パッケージが最新かどうか確認する| `--select` |
| `clean`   | 管理されていないパッケージを削除する | `--force`,`--select` |
| `clear`   | キャッシュを削除する | (なし) |
| `info`    | パッケージのタグ情報などを個別に表示する | (なし) |

#### 実用例

```zsh
# zplug check はインストールするものがないときに真を返す
# ゆえにそうでないとき zplug install する
if ! zplug check; then
    zplug install
fi

# プラグインを読み込み、コマンドを実行可能にする
zplug load

# zplug check は引数に与えられたリポジトリがインストールされているなら真を返す
if zplug check b4b4r07/enhancd; then
    # enhancd がインストールされている場合のみ設定する
    export ENHANCD_FILTER=fzf-tmux
fi
```

#### zplug を zplug で管理する

他のパッケージと同様に zplug を管理するには `.zshrc` に以下を書き込む。

```zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
```

あとは `zplug update` を実行するだけ。

<!-- [![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/update.gif)][repo] -->

### 3. タグ

`truthy` は `true`, `yes`, `on`, `1` で、 `falsy` は `false`, `no`, `off`, `0` を意味する。

| タグ | 説明 | 値 (デフォルト値) | 例 |
|-----|-------------|-----------------|---------|
| `as`          | プラグインとして、またはコマンドとして追加するか指定する | `plugin`,`command`,`theme` (`plugin`) | `as:command` |
| `use`         | 読み込むファイルパターンを指定する (`plugin` のとき) か `$PATH` に追加したいコマンドの相対パスを指定する (`command` のとき) / `from:gh-r` の場合は zplug が自動で OS のアーキテクチャを判別するが、意図しない結果の場合 `use:"*darwin*{amd,386}*"` のようにすると良い | *グロブ・パターン* (`use:"*.zsh"`) | `use:bin`,`use:"*.sh"`, `use:*darwin*` |
| `ignore`      | `use` タグと似ているが無視したいファイルパターンを指定する ([#56](https://github.com/zplug/zplug/issues/56) 参照) | *グロブ・パターン* (-) | `ignore:"some_*.zsh"` |
| `from`        | どこからインストールするか指定する | `github`,`bitbucket`,<br>`gh-r`,`gist`,<br>`oh-my-zsh`,`prezto`,`local` (`github`) | `from:gh-r` |
| `at`          | branch/tag/commit を指定して固定する | *リビジョン* (`master`) | `at:v1.5.6` |
| `rename-to`   | リンクするときに変更したいファイル名を指定する (`as:command` のときのみ有効) | *ファイル名* (-) | `rename-to:fzf` |
| `dir`         | パッケージのインストール先 | **READ ONLY** | `dir:/path/to/user/repo` |
| `if`          | パッケージをインストールするときの条件を指定する | *真偽値* (-) | `if:"[ -d ~/.zsh ]"` |
| `hook-build`  | インストール・アップデート後に実行するコマンド | *コマンド* (-) | `hook-build:"make install"` |
| `hook-load`   | ロード後に実行するコマンド | *コマンド* (-) | `hook-load:"echo 'Loaded!'"` |
| `frozen`      | 明示的に指定するとアップデート対象から省く | truthy または falsy (false) | `frozen:1` |
| `on`          | 指定されたパッケージがインストールされているときのみロードする | *package* | `on:user/repo` |
| `defer`        | プラグインの読み込みを遅らせる。 2 以上を指定すると、`compinit` コマンドの実行後に読まれることになる ([#26](https://github.com/zplug/zplug/issues/26) 参照) | 0 から 3 (0) | `defer:2` |
| `lazy`        | 遅延読み込みするかどうかを指定する | truthy または falsy (false) | `lazy:true` |
| `depth`       | リポジトリをクローンするときのヒストリサイズ。0 はすべてのヒストリをクローンする | 0 と正の整数 | `depth:10` |

#### デフォルト値を一括変更する

`zstyle` によってデフォルト値を変更できる。フォーマットは次のように:

```zsh
zstyle ":zplug:tag" tag_name new_default_value
```

例えば、もしプラグインよりコマンドを利用することが多いなら (具体的に言うと`as:command` とするほうが多い場合) こう書くことができる:

```zsh
zstyle ":zplug:tag" as command
```

こうすることでデフォルト値を変更することができる。`as` タグ以外のタグも同様に。

#### コマンドライン上から利用する

コマンドライン上から zplug パッケージを追加できる。もしコマンドライン上から追加することがあるのなら、zsh 補完を利用してより簡単でパワフルに追加できる。

<!-- [![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/cli.gif)][repo] -->

この場合、`.zshrc` でなく `$ZPLUG_LOADFILE` に設定が記述される。また、新しく zsh を立ち上げるときに、`zplug load` の際にこのファイルもロードする。

[`ZPLUG_LOADFILE`](#zplug_loadfile) の使い方については後述を参照。

### 4. 環境変数

#### `ZPLUG_HOME`

デフォルトでは `~/.zplug`。`zplug` はこのディレクトリ以下に配置される。ディレクトリ構成は以下である。

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

`as:command` を指定したとき、zplug はパッケージをコマンドとみなし、同名のシンボリックリンクを `$ZPLUG_BIN` に作成する (違う名前で作成したい場合、`rename-to:` タグを使う)。`$ZPLUG_BIN` は `$PATH` に追加されるので、インストールしたコマンドはいつでもどこからでも実行可能になる。

#### `ZPLUG_THREADS`

インストール・アップデート時に立ち上がるプロセス数の制限値。デフォルトは 16.

#### `ZPLUG_PROTOCOL`

デフォルトは HTTPS。取りうる値は `HTTPS` と `SSH`のみ。特別な理由がない限り、 `HTTPS` を推奨する。

詳細やその理由については [**Which remote URL should I use?** - GitHub Help](https://help.github.com/articles/which-remote-url-should-i-use/) を参照のこと。

#### `ZPLUG_FILTER`

デフォルトは `fzf-tmux:fzf:peco:percol:zaw`。`--select` オプションを指定すると、`$PATH` にあるコロンで区切られた最初の要素（この例では fzf-tmux）が zplug で使われる対話フィルタとして使用される。`ZPLUG_FILTER` は次のようにスペースや、ダブルクォーテーションを使用することができる: `fzf-tmux -d "10%":/path/to/peco:my peco`

#### `ZPLUG_LOADFILE`

デフォルトは `$ZPLUG_HOME/packages.zsh`。このファイルはコマンドライン上からパッケージの追加を行うときに使用される。これを利用することで `.zshrc` から分離してパッケージリストを管理することができる。

#### `ZPLUG_USE_CACHE`

デフォルトは `true`。true の場合、zplug はロードの高速化のためにキャッシュを利用するようになる。キャッシュファイルは `$ZPLUG_CACHE_DIR` に保存されている。キャッシュをクリアする場合は、`zplug clear` を実行するか以下のようにすると良い:

```console
$ ZPLUG_USE_CACHE=false zplug load
```

#### `ZPLUG_CACHE_DIR`

デフォルトは `$ZPLUG_HOME/.cache`。キャッシュの保存先を変更することができる。例えば `~/.cache/zplug` とか。

#### `ZPLUG_REPOS`

デフォルトは `$ZPLUG_HOME/repos`。パッケージのクローン先かつ保存先の場所を設定することができる。

#### `ZPLUG_SUDO_PASSWORD`

設定しておくと `hook-build` などのときに sudo コマンドが使えるようになる。しかし、セキュアな変数なので取扱に注意すること。

```zsh
# dotfiles で管理していないファイルに切り出すなどする
source ~/.zshrc_secret
zplug "some/command", hook-build:"make && sudo make install"
```

#### `ZPLUG_BIN`

デフォルトは `$ZPLUG_HOME/bin`。コマンドのシンボリックリンクの保存先を変更することができる。例えば `~/bin` とか。

### 外部コマンド

zplug では `git(1)` のように外部コマンド機能が利用できる。
`$PATH` のいずれかにある `zplug-cmdname` の規則を持つ実行ファイルは、まるでサブコマンドのように `zplug cmdname` の形で利用することができる。
これにより自由に自分で zplug のコマンドを追加したり拡張することができる。
作成方法や利用ガイドラインの詳細については [docs](https://github.com/zplug/zplug/blob/master/doc/zplug/External-Commands.md) ディレクトリ以下にあるので参照のこと。実際の外部コマンドのサンプルには [`zplug-env`](https://github.com/zplug/zplug/blob/master/bin/zplug-env) を参照すると良い。

## V.S.

zplug は他の有名な zsh プラグインマネージャーよりも速い:

[![](https://raw.githubusercontent.com/b4b4r07/screenshots/master/zplug/time.png)][repo]

## メモ

- antigen :syringe: はもうおしまい。これからは **zplug** :hibiscus: を使おう
- :hibiscus: zplug は [vim-plug](https://github.com/junegunn/vim-plug) や [neobundle.vim](https://github.com/Shougo/neobundle.vim) を参考に設計された

## その他

zplug などから利用できる zsh プラグインは [awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins) にあるので参考になる。

antigen や zgen、もしくは zplug v1 から移行するための情報は [zplug の公式 wiki](https://github.com/zplug/zplug/wiki/Migration) にある。

## ライセンス

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
