if (exists('g:loaded_lsp_ale') && g:loaded_lsp_ale) || &cp
    finish
endif
let g:loaded_lsp_ale = 1

let g:lsp_ale_severity_threshold = get(g:, 'lsp_ale_severity_threshold', 'warning')

" TODO: Disable ALE's LSP and vim-lsp diagnostics results

augroup plugin-lsp-ale
    autocmd!
    autocmd User lsp_setup call lsp#ale#enable()
    autocmd User ALEWantResults call lsp#ale#notify_diag_results(g:ale_want_results_buffer)
augroup END
