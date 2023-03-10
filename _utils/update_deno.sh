#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git config pull.rebase false


rver=$(curl -sL -u "$PAT" "https://api.github.com/repos/denoland/deno/releases/latest" | yq '.tag_name')

[ -z "$rver" ] && exit 1
[[ $rver = null ]] && exit 1

DENO_VERSION=${rver#v}

PREV_DENO_VERSION=$(yq '.env.DENO_VERSION' ".github/workflows/deno.yml")
if [ "${PREV_DENO_VERSION}" != "${DENO_VERSION}" ]; then
    echo "Updating to ${DENO_VERSION} ..."
    yq ".env.DENO_VERSION = \"${DENO_VERSION}\" |. style=\"double\"" "deno/_template.yml" > ".github/workflows/deno.yml"

	git add ".github/workflows/deno.yml" && \
	git commit -s -m "Updated deno to ${DENO_VERSION}" && \
	git push
else
	echo "No update needed (${DENO_VERSION})"
fi


