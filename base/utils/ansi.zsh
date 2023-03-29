__zplug::utils::ansi::remove()
{
    sed 's/\x1b\[[0-9;=?]*[a-zA-Z]/e/g'
}

__zplug::utils::ansi::erace_current_line()
{
    printf "\033[2K\r"
}

__zplug::utils::ansi::cursor_up()
{
    printf "\033[%sA" "${1:-"1"}"
}
