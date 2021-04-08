function! lsp#ale#notify_diag_results(bufnr) abort
    if !lsp#internal#diagnostics#state#_is_enabled_for_buffer(a:bufnr)
        return
    endif
    call ale#other_source#StartChecking(a:bufnr, 'some-name')
    let uri = lsp#utils#get_buffer_uri(a:bufnr)
    let diags = items(lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_server_for_uri(uri))
    let locs = []
    for [server, diag] in diags
        let locs += lsp#ui#vim#utils#diagnostics_to_loc_list({'response': diag})
    endfor
    call ale#other_source#ShowResults(a:bufnr, 'vim-lsp', locs)
endfunction
