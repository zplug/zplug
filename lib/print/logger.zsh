#!/bin/zsh

__import "print/print"

__ink() {
    local    color is_bold=false
    local -i tty=1
    local -a text

    while (( $# > 0 ))
    do
        case "$1" in
            --color)
                if [[ ! $2 =~ ^(black|blue|cyan|default|green|grey|magenta|red|white|yellow)$ ]]; then
                    __die "$2: must be a color\n"
                    return 1
                fi
                color="$2"; shift
                ;;
            --bold)
                is_bold=true
                ;;
            --tty)
                if [[ $2 != <-> ]]; then
                    __die "$2: must be an interger\n"
                    return 1
                fi
                tty="$2"; shift
                ;;
            *)
                text+=("$1")
                ;;
        esac
        shift
    done

    if $is_bold; then
        color="$fg_bold[$color]"
    else
        color="$fg_no_bold[$color]"
    fi

    case $tty in
        1)
            __put "${color}${text}${reset_color}"
            ;;
        2)
            __die "${color}${text}${reset_color}"
            ;;
    esac
}

__log() {
    local    state="$1" text="$2"
    local    bold
    local -i tty=1

    case "$state" in
        TITLE)
            color="yellow"
            ;;
        INFO)
            color="blue"
            ;;
        FAIL | WARN)
            color="red"
            tty=2
            ;;
        ERROR)
            color="red"
            bold="--bold"
            tty=2
            ;;
        PASS)
            color="green"
            ;;
        SUCCESS)
            bold="--bold"
            color="green"
            ;;
        *)
            text="$1"
            ;;
    esac

    __ink --color white "["
    __ink --color magenta --bold "$(date +%H:%M:%S)"
    __ink --color white "]"
    __ink --color "$color" --tty "$tty" $bold " $text"
}
