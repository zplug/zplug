#!/bin/bash

cnt=0
if [[ -n $1 ]]; then
    files=("$@")
else
    files=($ZPLUG_ROOT/doc/txt/*.txt)
fi

echo "Generates man pages from ascii files!"
echo "It takes time..."

for file in "${files[@]}"
do
    section_number="$(sed -n '1s/^.*(\(.*\))$/\1/p' "$file")"
    if [[ ! $section_number =~ [1-7] ]]; then
        echo "$file of $section_number: invalid section number" >&2
        continue
    fi

    man_dir="$ZPLUG_ROOT/doc/man/man$section_number"
    if [[ ! -d $man_dir ]]; then
        mkdir -p "$man_dir"
    fi

    echo "--  ${file/$ZPLUG_ROOT/} -> ${man_dir/$ZPLUG_ROOT/}"
    a2x \
        --doctype=manpage \
        --format=manpage \
        --destination="$man_dir" \
        "$file" &>/dev/null &
    (( (cnt += 1) % 16 == 0 )) && wait
done

wait
echo "==> DONE"
rm -f $ZPLUG_ROOT/doc/txt/*.xml
