# Sample zshrc

ZPLUG_SUDO_PASSWORD=
ZPLUG_PROTOCOL=ssh

source $HOME/.zplug/init.zsh

zplug "babarot/ultimate", as:theme
zplug 'babarot/zplug-doctor', lazy:yes
zplug 'babarot/zplug-cd', lazy:yes
zplug 'babarot/zplug-rm', lazy:yes

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
    echo
fi

zplug load

