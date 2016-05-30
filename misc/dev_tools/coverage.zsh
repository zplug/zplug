#!/usr/bin/env zsh

local -F all=0
local -a pass
local -a fail
local    f is_create=false

while (( $# > 0 ))
do
    case "$1" in
        -c|--create)
            is_create=true
            ;;
        -*|--*)
            printf "$1: unkown option\n" >&2
            exit 1
            ;;
        *)
            ;;
    esac
    shift
done

get_untested_files() {
    local f
    for f in $ZPLUG_ROOT/(autoload|lib)/**/*(.:gs:$ZPLUG_ROOT/:)
    do
        let all++
        if [[ -f $ZPLUG_ROOT/test/${f:r}_test.zsh ]]; then
            pass+=($f)
        else
            fail+=($f)
        fi
    done
}

show_untested_files() {
    get_untested_files
    if (( $#fail > 0 )); then
        printf "- %s\n" ${fail[@]}
        printf "\n"
    fi
    printf "%d/%d (%3.1f%%)\n" $#pass $all $(($#pass / $all * 100))
}

if $is_create; then
    get_untested_files
    for f in "${fail[@]}"
    do
        f="test/${f:r}_test.zsh"
        mkdir -p "${f:h}"
        echo "#!/usr/bin/env zsh" >"$f"
    done
else
    show_untested_files
fi

