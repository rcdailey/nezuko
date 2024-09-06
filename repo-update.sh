#!/usr/bin/env bash
set -e

cd /mnt/fast/docker

CHANGES=$(git status -uno --porcelain)
if [[ -n "$CHANGES" ]]; then
    echo "Working copy has modifications; will not proceed further"
    exit 1
fi

git checkout master
PREV_HEAD="${1:-$(git rev-parse HEAD)}"
git pull
CURR_HEAD="${2:-$(git rev-parse HEAD)}"

if [[ "$PREV_HEAD" == "$CURR_HEAD" ]]; then
    echo "No changes were pulled; exiting"
    exit 0
fi

echo
echo "Previous Commit: $PREV_HEAD"
echo " Current Commit: $CURR_HEAD"

COMPOSE_FILES=$(\
    git diff --name-only --diff-filter=AM $PREV_HEAD...$CURR_HEAD |\
    grep 'docker-compose.yml' || true)

for file in $COMPOSE_FILES; do
    echo
    echo "============================================================="
    echo "Running docker compose for $file"
    echo "============================================================="
    docker compose -f "$file" up -d --pull always --remove-orphans
done
