#!/bin/zsh

set -e

printf "Now zplug version is $_ZPLUG_VERSION\n"
printf "Please let me know new version: "
read next_version
printf "OK? $next_version: [y/n] "
read ok
case "$ok" in
    "Y"|"y"|"YES"|"yes"|"OK"|"ok")
        # ok
        ;;
    *)
        echo "canceled" >&2
        exit 1
        ;;
esac

dir="$(git rev-parse --show-toplevel)"
source "$dir/base/base/base.zsh"

if ! __zplug::base::base::valid_semver "$_ZPLUG_VERSION" "$next_version"; then
    printf "$next_version: invalid semver\n"
    exit 1
fi

branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ ! $branch =~ $next_version ]]; then
    echo "You are on $branch, but next version is $next_version" >&2
    exit 1
fi

if [[ -z $GITHUB_TOKEN ]]; then
    printf "GITHUB_TOKEN is missing\n" >&2
    exit 1
fi

if [[ -n "$(git status -s)" ]]; then
    git status -s
    printf "your $branch branch is not clean\n" >&2
    exit 1
fi

files=(
"$dir/base/core/core.zsh"
"$dir/README.md"
"$dir/doc/guide/ja/README.md"
)

# overwrite
echo "$next_version" >| "$dir/doc/VERSION"

# overwrite
for file in "$files[@]"
do
    cat "$file" | (rm "$file"; sed "s/$_ZPLUG_VERSION/$next_version/" > "$file")
done

# show diff
git diff

printf "Can I continue to process? [y/n] "
read ok
case "$ok" in
    "Y"|"y"|"YES"|"yes"|"OK"|"ok")
        # ok
        ;;
    *)
        echo "canceled" >&2
        exit 1
        ;;
esac

# git ops
set -x
git add -p
git commit -m "New version $next_version"
git push -u origin $branch
git checkout master
git merge --no-ff $branch
git push -u origin master
# maybe not necessary thanks to curl post proc
# git tag -a $next_version -m $next_version
# git push origin $next_version
set +x

body="Release of version '$next_version'"
printf "Do you enter releases message? [y/n] "
read ok
case "$ok" in
    "Y"|"y"|"YES"|"yes"|"OK"|"ok")
        while true
        do
            echo "Please let me know release message (kill to type ^D)"
            ok=
            message="$(cat)"
            printf "--- OK? --- [y/n] "
            read ok
            case "$ok" in
                [Yy]*)
                    break
                    ;;
                [Nn]*)
                    continue
                    ;;
                * ) echo "Please answer yes or no.";;
            esac
        done
        ;;
    *)
        # do nothing
        ;;
esac

curl --data \
    '{ \
    "tag_name": "'$next_version'", \
    "target_commitish": "master", \
    "name": "'$next_version'", \
    "body": "'$body'", \
    "draft": false, \
    "prerelease": false \
}' "https://api.github.com/repos/zplug/zplug/releases?access_token=$GITHUB_TOKEN"

printf "Completed.\n"
