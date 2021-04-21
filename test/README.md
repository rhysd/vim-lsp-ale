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
