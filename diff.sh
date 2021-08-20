#!/bin/bash

set -e

PR_NUMBER=$(jq -r ".pull_request.number" "$GITHUB_EVENT_PATH")
if [[ "$PR_NUMBER" == "null" ]]; then
	PR_NUMBER=$(jq -r ".issue.number" "$GITHUB_EVENT_PATH")
fi
if [[ "$PR_NUMBER" == "null" ]]; then
	echo "Failed to determine PR Number."
	exit 1
fi
echo "Collecting information about PR #$PR_NUMBER of $GITHUB_REPOSITORY..."

URI=https://api.github.com
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"

PR_RESP=$(curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" \
          "${URI}/repos/$GITHUB_REPOSITORY/pulls/$PR_NUMBER")

BASE_BRANCH=$(echo "$PR_RESP" | jq -r .base.ref)
HEAD_BRANCH=$(echo "$PR_RESP" | jq -r .head.ref)

if [[ -z "$BASE_BRANCH" ]]; then
	echo "Cannot get base branch information for PR #$PR_NUMBER!"
	exit 1
fi

set -o xtrace

git checkout $BASE_BRANCH && git pull
git checkout $HEAD_BRANCH && git pull

OUTPUT=$(git diff $BASE_BRANCH...$BASE_BRANCH --stat ${DIFF_OPTIONS})

echo $OUTPUT

echo "::set-output name=diff-output::$(echo $(echo $OUTPUT | tail -1))"
