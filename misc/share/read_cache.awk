BEGIN {
    flag = 0;
}

{
    if ($0 == "return 0") {
        flag = 1;
        next;
    }
}

flag {
    print $0;
}
