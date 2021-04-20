function! lsp#internal#diagnostics#state#_is_enabled_for_buffer(bufnr) abort
    return a:bufnr == g:lsp_ale_test_expected_bufnr
endfunction

function! lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_server_for_uri(uri) abort
    return g:lsp_ale_test_received_diags
endfunction
