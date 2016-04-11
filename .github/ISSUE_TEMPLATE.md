Thank you for helping improve zplug!

To make sure we can quickly assist you with any bugs, we have three requests:

## 1. Remove the cache file and zcompdump

Before moving on to the next step, make sure you have cleared the cache file
with `zplug clear` and removed the zcompdump file with `rm -f
$ZPLUG_HOME/zcompdump`.

## 2. Reproduce the bug with a minimal **.zshrc**

Remove as many lines in your **.zshrc** as possible, for example, if there's a problem with `zsh-syntax-highlighting`, try something like:

```zsh
  # Example minimal zshrc
  source ~/.zplug/init.zsh

  zplug "zsh-users/zsh-syntax-highlighting"

  zplug check || zplug install

  zplug load
```

Sometimes the problem only manifests when there are two different plugins loaded. Knowing which two plugins will greatly help us come up with a fix.

## 3. Share some system information

By pasting the output of these three commands in your bug report, we can be certain we are testing the right thing for your setup:

- [ ] `uname -a`
- [ ] `cat ~/.zshrc`
- [ ] `zsh --version`

By following these two steps, we can assist with any problem much faster!
