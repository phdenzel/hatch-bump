#!/bin/bash -e

bump_type=$1
ref_branch=$2
force_push=$3

runner () {
    echo "🟡 starting $@"
    $@ && echo "🟢 $@ passed" || (echo "🔴 $@ failed" && exit 1)
}

if [[ -n "$GITHUB_WORKSPACE" ]]; then
    git config --global --add safe.directory $GITHUB_WORKSPACE
fi

git config --global user.name $GITHUB_ACTOR
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"

if [ -n "$(git status --porcelain)" ]; then
    # Working directory clean
    # Uncommitted changes
    echo "🔴 There are uncommitted changes, exiting"
    exit 1
fi

git reset --hard

VERSION=`hatch version`

case $bump_type in

    'release')
        hatch version release;;
    'major')
        hatch version major;;
    'minor')
        hatch version minor;;
    'micro' | 'patch' | 'fix')
        hatch version micro;;
    'alpha')
        hatch version alpha;;
    'beta')
        hatch version beta;;
    'c' | 'rc' | 'pre' | 'preview')
        hatch version pre;;
    'r' | 'rev' | 'post')
        hatch version rev;;
    'dev')
        hatch version dev;;
    *)
        echo "🔵 Skipped Version Bump";;
esac

NEW_VERSION=`hatch version`

if [ "$VERSION" != "$NEW_VERSION" ]; then
    echo "🟢 Success: bump version: $VERSION → $NEW_VERSION"

    git add .
    git commit -m "Bump version: $VERSION → $NEW_VERSION"
    git remote -v

    echo "🟢 Success version push"

    if [ "$force_push" = true ]; then
        PUSH_FLAGS="--force"
    else
        PUSH_FLAGS=""
    fi

    if [ -n "$ref_branch" ]; then
        git push $PUSH_FLAGS origin HEAD:$ref_branch
    elif [ -n "$GITHUB_HEAD_REF" ]; then
        git push $PUSH_FLAGS origin HEAD:$GITHUB_HEAD_REF
    else
        git push
    fi
fi

exit 0
