Tests
=====

## Directory structure

- [`test/unit`](./unit): Unit tests
  - [`test/unit/test.vimspec`](./unit/test.vimspec): Unit test cases
  - [`test/unit/runtime`](./unit/runtime): Runtime directory loaded on running unit tests. They mocks several external APIs like `ale#*` or `lsp#*`
- [`test/integ`](./integ): Integration tests
  - [`test/integ/test.vimspec`](./integ/test.vimspec): Integration test cases
  - [`test/integ/deps`](./integ/deps): Dependant plugins

## Unit tests

Unit tests confirm vim-lsp-ale works as intended.

### Prerequisites

Unit tests can be run with no dependency because they mock every external API.

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

### Measure unit test coverage

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

## Integration tests

Integration tests confirm integrity among vim-lsp, ALE, vim-lsp-ale and a language server.

### Prerequisites

Integration tests require all dependencies are installed in [deps](./integ/deps) directory.

```sh
cd path/to/vim-lsp-ale
git clone https://github.com/prabirshrestha/vim-lsp.git test/integ/deps/vim-lsp
git clone https://github.com/dense-analysis/ale.git test/integ/deps/ale
```

[rust-analyzer](https://rust-analyzer.github.io/) is used as language server to run integration tests.
Download the binary following [the instruction](https://rust-analyzer.github.io/manual.html#rust-analyzer-language-server-binary)
and put the binary in `$PATH` directory.

And [vim-themis](https://github.com/thinca/vim-themis) is used as test runner.

Note that integration tests were not confirmed on Windows.

### Run integration tests

```sh
cd path/to/vim-lsp-ale
git clone https://github.com/thinca/vim-themis.git
./vim-themis/bin/themis ./test/integ/
```

### Log files

When some integration tests fail, the following log files would be useful to investigate the failure.

- `test/integ/integ_messages.txt`: Messages in `:message` area while running the tests
- `test/integ/lsp-log.txt`: Log information of vim-lsp. It records communications between vim-lsp and a language server

## CI

Tests are run continuously on GitHub Actions.

https://github.com/rhysd/vim-lsp-ale/actions?query=workflow%3ACI

- Unit tests are run on Linux, macOS and Windows with Vim and Neovim
- Integration tests are run on Linux with Vim and Neovim
