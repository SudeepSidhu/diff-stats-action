#!/bin/bash

set -e

if [[ "$ADD_SIZE_LABEL" != "true" ]]; then
  echo "Skipping size labelling as it wasn't requested"
  exit 0
fi

PR_NUMBER=$(jq -r ".pull_request.number" "$GITHUB_EVENT_PATH")

if [[ "$PR_NUMBER" == "null" ]]; then
  PR_NUMBER=$(jq -r ".issue.number" "$GITHUB_EVENT_PATH")
fi

if [[ "$PR_NUMBER" == "null" ]]; then
  echo "Failed to determine PR Number."
  exit 1
fi

if [[ "$DIFF_OUTPUT" =~ ([0-9]+)( insertion) ]]; then
  INSERTIONS=${BASH_REMATCH[1]}
else
  # If the diff only shows deletions, the word 'insertions' is omitted, which breaks the regex above.
  INSERTIONS=0
fi

echo "Insertion count: $INSERTIONS"

if (( $INSERTIONS <= $EXTRA_SMALL_SIZE )); then
  LABEL=$EXTRA_SMALL_LABEL
elif (( $INSERTIONS <= $SMALL_SIZE )); then
  LABEL=$SMALL_LABEL
elif (( $INSERTIONS <= $MEDIUM_SIZE )); then
  LABEL=$MEDIUM_LABEL
elif (( $INSERTIONS <= $LARGE_SIZE )); then
  LABEL=$LARGE_LABEL
else
  LABEL=$EXTRA_LARGE_LABEL
fi

# Get the current labels to see if we actually need to add a label
echo "Collecting information about PR #$PR_NUMBER of $GITHUB_REPOSITORY..."

API_URI=https://api.github.com
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"

PR_RESP=$(curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" \
  "${API_URI}/repos/$GITHUB_REPOSITORY/pulls/$PR_NUMBER")

while IFS= read -r EXISTING_LABEL; do
  if [[ "$EXISTING_LABEL" == "$LABEL" ]]; then
    echo "PR already has $LABEL label - nothing to do here!"
    exit 0
  fi
done <<< "$(echo "$PR_RESP" | jq -rc .labels[].name)"

# Remove all the size labels and add the new one
ALL_LABELS="$EXTRA_SMALL_LABEL,$SMALL_LABEL,$MEDIUM_LABEL,$LARGE_LABEL,$EXTRA_LARGE_LABEL"

echo "Removing $ALL_LABELS labels and adding $LABEL"

gh pr edit $PR_NUMBER --remove-label "$ALL_LABELS"
gh pr edit $PR_NUMBER --add-label "$LABEL"
