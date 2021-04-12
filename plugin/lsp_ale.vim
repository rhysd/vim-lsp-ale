if (exists('g:loaded_lsp_ale') && g:loaded_lsp_ale) || &cp
    finish
endif
let g:loaded_lsp_ale = 1

let g:lsp_ale_severity_threshold = get(g:, 'lsp_ale_severity_threshold', 'warning')

if get(g:, 'lsp_ale_setup_variables', v:true)
    " Enable diagnostics and disable all functionalities to show error
    " messages by vim-lsp
    let g:lsp_diagnostics_enabled = 1
    let g:lsp_diagnostics_echo_cursor = 0
    let g:lsp_diagnostics_float_cursor = 0
    let g:lsp_diagnostics_highlights_enabled = 0
    let g:lsp_diagnostics_signs_enabled = 0
    let g:lsp_diagnostics_virtual_text_enabled = 0
    " Disable ALE's LSP integration
    let g:ale_disable_lsp = 0
endif

augroup plugin-lsp-ale
    autocmd!
    autocmd User lsp_setup call lsp#ale#enable()
    autocmd User ALEWantResults call lsp#ale#notify_diag_results(g:ale_want_results_buffer)
augroup END
