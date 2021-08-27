# Diff Stats Action
An action that runs `git diff` on your PR and comments back with the diff stats. Goes a little bit beyond the stats reported by GitHub by letting you specifiy options to pass into `git diff` call (e.g. ignore certain files).

### Workflow example:

The following workflow ignores:
- files that have "generated" anywhere in the path
- json files
- svg files

```
name: Report Diff Stats

on:
  pull_request:
    types: ['opened', 'edited', 'reopened', 'synchronize']

jobs:
  diff:
    name: Report Diff Stats
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the latest code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Run diff and comment back with the stats
        uses: SudeepSidhu/diff-stats-action@v1
        with:
          diff-options: :^*generated* :^*.json :^*.svg
```

### Comment example:

Diff stats:
```
2 files changed, 3 insertions(+)
```
