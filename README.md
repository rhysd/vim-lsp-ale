[vim-lsp][] + [ALE][]
=====================

[vim-lsp-ale][] is a Vim plugin for bridge between [vim-lsp][] and [ALE][]. Diagnostics results received
by vim-lsp are shown in ALE's interface.

When simply using ALE and vim-lsp, both plugins run LSP servers respectively. Running multiple server processes
consume resources and may cause some issues. Showing lint results from multiple plugins is confusing.
vim-lsp-ale solves the problem.

<img alt="screencast" src="https://github.com/rhysd/ss/blob/master/vim-lsp-ale/main.gif?raw=true" width="582" height="316"/>

## Installation

Install [vim-lsp][], [ale][ALE], [vim-lsp-ale][] with your favorite package manager or `:packadd` in your `.vimrc`.

An exmaple with [vim-plug](https://github.com/junegunn/vim-plug):

```viml
Plug 'dense-analysis/ale'
Plug 'prabirshrestha/vim-lsp'
Plug 'rhysd/vim-lsp-ale'
```

## Usage

Register LSP servers you want to use with `lsp#register_server` and set `vim-lsp` linter to `g:ale_linters`
for filetypes you want to check with vim-lsp.

The following example configures `gopls` to check Go sources.

```vim
if executable('gopls')
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': ['gopls'],
        \ 'allowlist': ['go', 'gomod'],
        \ })
endif
let g:ale_linters = {
    \   'go': ['vim-lsp'],
    \ }
```

This plugin configures vim-lsp and ALE automatically. You don't need to setup various variables.

When opening a source code including some lint errors, vim-lsp will receive the errors from language server
and ALE will report the errors in the buffer.

For more details, see [the documentation](./doc/vim-lsp-ale.txt).

## License

Licensed under [the MIT license](./LICENSE).

[vim-lsp]: https://github.com/prabirshrestha/vim-lsp
[ALE]: https://github.com/dense-analysis/ale
[vim-lsp-ale]: https://github.com/rhysd/vim-lsp-ale
