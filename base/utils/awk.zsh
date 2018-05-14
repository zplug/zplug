__zplug::utils::awk::path()
{
    local    awk_path
    local -a awk_paths
    local    awk variant

    # Look up all awk from PATH
    for awk_path in ${^path[@]}/{g,n,m,}awk
    do
        if [[ -x $awk_path ]]; then
            awk_paths+=( "$awk_path" )
        fi
    done

    # There is no awk execute file in this PATH
    if (( $#awk_paths == 0 )); then
        __zplug::log::write::error \
            "gawk or nawk is not found"
        return 1
    fi

    # Detect awk variant from available awk list
    for awk_path in "${awk_paths[@]}"
    do
        if ${=awk_path} --version 2>&1 | grep -q "GNU Awk"; then
            # GNU Awk
            variant="gawk"
            awk="$awk_path"
            # Use gawk if it's already installed
            break
        elif ${=awk_path} -Wv 2>&1 | grep -q "mawk"; then
            # mawk
            variant=${variant:-"mawk"}
            echo $awk:$variant
        else
            # nawk
            variant="nawk"
            awk="$awk_path"
            # Search another variant if awk is nawk
            continue
        fi
    done

    if [[ $awk == "" || $variant == "mawk" ]]; then
        __zplug::log::write::error \
            "gawk or nawk is not found"
        return 1
    fi

    echo "$awk"
}

__zplug::utils::awk::available()
{
    local awk_path

    __zplug::utils::awk::path \
        | read awk_path

    # AWK is available
    if [[ -n $awk_path ]]; then
        return 0
    else
        return 1
    fi
}

__zplug::utils::awk::ltsv()
{
    local \
        user_awk_script="$1" \
        ltsv_awk_script

    ltsv_awk_script=$(command cat <<-'EOS'
    function key(name) {
        for (i = 1; i <= NF; i++) {
            match($i, ":");
            xs[substr($i, 0, RSTART)] = substr($i, RSTART+1);
        };
        return xs[name":"];
    }
EOS
    )

    awk -F'\t' \
        "${ltsv_awk_script} ${user_awk_script}"
}
