function out(k,v) {
    print(k "" (v == "" ? "" : " "v))
}

function pop() {
    return len <= 0 ? "_" : opt[len--]
}

{
    if (done) {
        out("_" , $0)
        next
    }

    if (match($0, "^-[A-Za-z]+")) {
        $0 = "- " substr($0, 2, RLENGTH - 1) " " substr($0, RLENGTH + 1)

    } else if (match($0, "^--[A-Za-z0-9_-]+")) {
        $0 = "-- " substr($0, 3, RLENGTH - 2) " " substr($0, RLENGTH + 2)
    }

    if ($1 == "--" && $2 == "") {
        done = 1

    } else if ($2 == "" || $1 !~ /^-|^--/ ) {
        out(pop(), $0)

    } else {
        while (len) {
            out(pop())
        }

        if ($3 != "") {
            if (match($0, $2)) {
                $3 = substr($0, RSTART + RLENGTH + 1)
            }
        }

        if ($1 == "--") {
            if ($3 == "") {
                opt[++len] = $2
            } else {
                out($2, $3)
            }
        }

        if ($1 == "-") {
            if ($2 == "") {
                print($1)
                next

            } else {
                n = split($2, keys, "")
            }

            if ($3 == "") {
                opt[++len] = keys[n]

            } else {
                out(keys[n], $3)
            }

            for (i = 1; i < n; i++) {
                out(keys[i])
            }
        }
    }
}

END {
    while (len) {
        out(pop())
    }
}
