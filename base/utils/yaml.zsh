typeset -gx -A _zplug_yaml

__zplug::utils::yaml::tokenizer()
{
    local prefix="$1"
    local s='[[:space:]]*'
    local w='[a-zA-Z0-9_]*'
    local fs="$(echo '@' | tr '@' '\034')"

    sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:[[:space:]]*[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" \
        | awk -F "$fs" \
        '
    {
        indent = length($1) / 2;
        vname[indent] = $2;
        for (i in vname) {
            if (i > indent) {
                fidelete vname[i]
            }
        }
        if (length($3) > 0) {
            vn = "";
            for (i = 0; i < indent; i++) {
                vn=(vn)(vname[i])("_");
            }
            #printf("%s%s%s=\"%s\"\n", "'$prefix'", vn, $2, $3);
            printf("%s%s%s\n%s\n", "'$prefix'", vn, $2, $3);
        }
    }'
}

__zplug::utils::yaml::parser()
{
    local    yaml="$1" key
    local -A parsed_yaml

    _zplug_yaml=()

    parsed_yaml=( "${(@f)$(
    if [[ -f "$yaml" ]]; then
        cat "$yaml"
    else
        cat <&0
    fi \
        | __zplug::utils::yaml::tokenizer
    )}" )

    for key in "${(k)parsed_yaml[@]}"
    do
        _zplug_yaml[$key]="$parsed_yaml[$key]"
    done
}
