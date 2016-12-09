__zplug::core::interface::expose()
{
    local name

    for name in "${(ok)zplugs[@]}"
    do
        # In order to sort $zplugs[$name],
        # do not quate this string
        echo "${name}${zplugs[$name]:+, ${(os:, :)zplugs[$name]}}"
    done
}
