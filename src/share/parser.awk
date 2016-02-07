BEGIN {
    KEY_SEP  = ":";
    TAGS_SEP = ", ";
}

{
    arr[NR] = $0;
}

END {
    if (get_tag(arr, package) != 0)
        exit 1;
}

function get_name(arr, tag,     n, tags, i, name) {
    n = split(tag, tags, "#");
    for (i in tags) {
        if (tags[i] ~ /\//) {
            name = tags[i];
            break;
        }
    }
    return name;
}

function get_tag(line, tag,    name, i, j, n, tags, line_tags, ret, key_and_value, key, value) {
    name = get_name(line, tag);
    if (name == "") {
        return 1;
    }
    n = split(tag, tags, "#");

    for (i in line) {
        if (line[i] ~ "name" KEY_SEP name TAGS_SEP) {
            m = split(line[i], line_tags, TAGS_SEP);
            for (j in line_tags) {
                split(line_tags[j], key_and_value, KEY_SEP);
                key   = key_and_value[1];
                value = key_and_value[2];
                if (n == 1) {
                    ret[key] = value;
                }
                if (in_array(key, tags) == 0) {
                    ret[key] = value;
                }
            }
        }
    }

    if (length(ret) == 0)
        return 1;

    for (key in ret)
        print key KEY_SEP ret[key];
}

function in_array(e, arr,    i) {
    for (i in arr) {
        if (arr[i] == e)
            return 0;
    }
    return 1;
}
