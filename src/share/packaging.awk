#!/usr/bin/env awk

BEGIN {
    FS = "/";
}

{
    if ($2 == pkg)
        list[i++] = $0;
}

END {
    if (length(list) == 1)
        print list[0];
    else
        print pkg;
}
