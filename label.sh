#!/bin/bash

set -ex

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

if [[ $DIFF_OUTPUT =~ ([0-9]+)( insertions) ]]; then
  INSERTIONS=${BASH_REMATCH[1]}
else
  echo "Could not extract insertions from \"$DIFF_OUTPUT\" - exiting..."
  exit 0
fi

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

ALL_LABELS="$EXTRA_SMALL_LABEL,$SMALL_LABEL,$MEDIUM_LABEL,$LARGE_LABEL,$EXTRA_LARGE_LABEL"

echo "Removing $ALL_LABELS labels and adding $LABEL"

gh pr edit $PR_NUMBER --remove-label "$ALL_LABELS"
# gh pr edit $PR_NUMBER --add-label $LABEL
