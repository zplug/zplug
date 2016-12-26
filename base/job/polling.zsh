#export PERIOD=10

__zplug::job::polling::finalizer()
{
    # Display the corsor
    tput cnorm
    # TODO
}

#add-zsh-hook periodic __zplug::job::polling::finalizer
