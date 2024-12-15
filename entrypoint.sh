#!/bin/bash -e

bumpType=$1

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

case $bumpType in

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

    echo "GITHUB_ACTOR $GITHUB_ACTOR"
    echo "GITHUB_REF $GITHUB_REF"
    echo "GITHUB_HEAD_REF $GITHUB_HEAD_REF"
    echo "GITHUB_BASE_REF $GITHUB_BASE_REF"
    echo "GITHUB_REF_NAME $GITHUB_REF_NAME"
    echo "GITHUB_WORKSPACE $GITHUB_WORKSPACE"
    echo "GITHUB_ENV $GITHUB_ENV"

    if [ -n "$GITHUB_HEAD_REF" ]; then
        git push origin HEAD:$GITHUB_HEAD_REF
    else
        git push
    fi
fi

exit 0
