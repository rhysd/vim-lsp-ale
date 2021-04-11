[vim-lsp][] + [ALE][]
=====================

[vim-lsp-ale][] is a Vim plugin for bridge between [vim-lsp][] and [ALE][].

When simply using ALE and vim-lsp, both plugins run LSP servers respectively. vim-lsp-ale takes
diagnostics results from vim-lsp and passes them to ALE. The diagnostics results are shown as part
of lint results by ALE.

## Installation

Install [vim-lsp][], [ale][ALE], [vim-lsp-ale][] with your favorite package manager or `:packadd` in your `.vimrc`.

An exmaple with [vim-plug](https://github.com/junegunn/vim-plug):

```viml
Plug 'dense-analysis/ale'
Plug 'prabirshrestha/vim-lsp'
Plug 'rhysd/vim-lsp-ale'
```

## Usage

- Disable showing diagnostics results from vim-lsp since ALE will show the results
- Disable LSP support of ALE since vim-lsp handles all LSP requests/responses
- Set `vim-lsp` linter for filetypes you want to check with vim-lsp in `g:ale_linters`

The following configuration is an example of using `gopls` for linting Go sources though vim-lsp.

```vim
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 0
let g:lsp_diagnostics_float_cursor = 0
let g:lsp_diagnostics_highlights_enabled = 0
let g:lsp_diagnostics_signs_enabled = 0
let g:lsp_diagnostics_virtual_text_enabled = 0
if executable('gopls')
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': ['gopls'],
        \ 'allowlist': ['go', 'gomod'],
        \ })
endif
let g:ale_disable_lsp = 0
let g:ale_linters = {
    \   'go': ['vim-lsp'],
    \ }
```

## License

Licensed under [the MIT license](./LICENSE).

[vim-lsp]: https://github.com/prabirshrestha/vim-lsp
[ALE]: https://github.com/dense-analysis/ale
[vim-lsp-ale]: https://github.com/rhysd/vim-lsp-ale
