Tests
=====

## Directory structure

- [`test/unit`](./unit): Unit tests
  - [`test/unit/test.vimspec`](./unit/test.vimspec): Unit test cases
  - [`test/unit/runtime`](./unit/runtime): Runtime directory loaded on running unit tests. They mocks several external APIs like `ale#*` or `lsp#*`

## How to run tests

[vim-themis](https://github.com/thinca/vim-themis) is used as test runner.

By default, it runs tests with `vim` command. When running tests with Neovim, set `THEMIS_VIM=nvim` environment variable.

### Run unit tests

```sh
cd path/to/vim-lsp-ale
git clone https://github.com/thinca/vim-themis.git

# Run tests with Vim
./vim-themis/bin/themis ./test/unit/

# Run tests with NeoVim
THEMIS_VIM=nvim ./vim-themis/bin/themis ./test/unit/
```

## Measure coverage

[covimerage](https://github.com/Vimjas/covimerage) is used to measure test coverage. Install it by `pip install covimerage`.

Set a file path to `THEMIS_PROFILE` environment variable and run unit tests. Vim will store the profile data to the file.
`covimerage` command will convert the profile data into coverage data for `coverage` command provided by Python.

```sh
cd path/to/vim-lsp-ale
git clone https://github.com/thinca/vim-themis.git

# Run test case with $THEMIS_PROFILE environment variable
THEMIS_PROFILE=profile.txt ./vim-themis/bin/themis ./test/unit

# Store coverage data at .coverage_covimerage converted from the profile data
covimerage write_coverage profile.txt

# Show coverage report by `coverage` command
coverage report
```
