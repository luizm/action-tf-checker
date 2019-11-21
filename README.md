# sh-checker

A GitHub Action that check a terraform recipes using a subcommand `fmt` and `validate` to do that.

## Usage

Job example to check all tf files but ignore the directory `.dirty-dir`

```
name: example
on:
  push:
jobs:
  sh-checker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: run the tf-checker
        uses: luizm/action-tf-checker@v0.1.0
        env:
          TF_CHECKER_EXCLUDE_REGEX: "/.dirty-dir/*"
```

**Environments:**

- TF_CHECKER_EXCLUDE_REGEX: The regex to filter the files or directories that don't need to check.