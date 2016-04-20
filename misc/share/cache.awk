BEGIN {
    TAGS_SEP = ", ";
}

{
    arr[NR] = reconstruct($0);
}

END {
    for (i in arr)
        print arr[i];
}

function reconstruct(line,    tags) {
    gsub(/, +/, TAGS_SEP, line)
    split(line, tags, TAGS_SEP);
    quick_sort(tags, 1, length(tags));

    return join(tags, 1, length(tags), TAGS_SEP);
}

function quick_sort(array, left, right,     i, j, tmp, pivot) {
    if (left < right) {
        i = left;
        j = right;
        pivot = array[int((left + right) / 2)];
        while (i <= j) {
            while (array[i] < pivot) {
                i++;
            }
            while (array[j] > pivot) {
                j--;
            }
            if (i <= j) {
                tmp = array[i];
                array[i] = array[j];
                array[j] = tmp;
                i++;
                j--;
            }
        }
        quick_sort(array, left, j);
        quick_sort(array, i, right);
    }
}

function join(array, start, end, sep,    result, i) {
    if (sep == "") {
        sep = " ";
    } else if (sep == SUBSEP) {
        sep = "";
    }

    result = array[start];
    for (i = start + 1; i <= end; i++) {
        result = result sep array[i];
    }

    return result;
}
