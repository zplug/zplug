Thank you for helping improve zplug!

To make sure we can quickly assist you with any bugs, we have two requests:

## 1. Reproduce the bug with a minimal **.zshrc**

Remove as many lines in your **.zshrc** as possible, for example, if theres a problem with zsh-syntax-highlighting, try something like:

```zsh
  # Example minimal zshrc
  source ~/.zplug/init.zsh
  zplug "jimmijj/zsh-syntax-highlighting"
  zplug load
```

Sometimes the problem only manifests when there are two diffent plugins loaded. Knowing which two plugins will greatly help us come up with a fix.

## 2. Share some system information

By pasting the output of these three commands in your bugreport, we can be certain we are testing the right thing for your setup:

  [ ] `uname -a`
  [ ] `cat ~/.zshrc`
  [ ] `zsh --version`

By following these two steps, we can assist with any problem much faster!
