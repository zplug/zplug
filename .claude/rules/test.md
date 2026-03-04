---
description: Test framework conventions and patterns (Shove)
paths:
  - "test/**/*.t"
---

# Rules for test/

## Framework

Tests use [Shove](https://github.com/key-amb/shove), executed via `make test`.

## File Layout

Test files mirror the `base/` directory structure:

```
test/base/<category>/<module>.t
```

For example, `base/core/tags.zsh` is tested by `test/base/core/tags.t`.

## Test Syntax

```zsh
T_SUB "function_name_or_description" ((
  # test body
  t_is $actual $expected
))
```

- `T_SUB` — define a test case
- `t_is` — assert equality (exit code or value)

## Generating Tests

New test stubs can be generated with:

```sh
zsh misc/dev/make_tests.zsh
```

This scans `base/` for function definitions and creates skeleton `.t` files.

## Running Tests

```sh
make test                    # all tests
make test TEST_TARGET=test/base/core/tags.t  # single file
```

## Notes

- `test/all.t` sources `misc/zshrc` for a full integration test. It has a known pre-existing failure due to job table exhaustion — this is not a regression indicator.
- Individual module tests (e.g., `test/base/base/base.t`) are the reliable pass/fail signal.
