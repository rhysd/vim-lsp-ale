let s:Dispose = v:null

function! lsp#ale#notify_diag_results(bufnr) abort
    if !lsp#internal#diagnostics#state#_is_enabled_for_buffer(a:bufnr)
        return
    endif
    call ale#other_source#StartChecking(a:bufnr, 'vim-lsp')
    let uri = lsp#utils#get_buffer_uri(a:bufnr)
    let diags = items(lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_server_for_uri(uri))
    let locs = []
    for [server, diag] in diags
        for loc in lsp#ui#vim#utils#diagnostics_to_loc_list({'response': diag})
            let loc.text = '[' . server . '] ' . loc.text
            let locs += [loc]
        endfor
    endfor
    call ale#other_source#ShowResults(a:bufnr, 'vim-lsp', locs)
endfunction

function! s:on_diagnostics(req) abort
    call lsp#ale#notify_diag_results(bufnr(''))
endfunction

function! s:is_diagnostics_response(item) abort
    if !has_key(a:item, 'server') || !has_key(a:item, 'response')
        return v:false
    endif
    let res = a:item.response
    if !has_key(res, 'method')
        return v:false
    endif
    return res.method ==# 'textDocument/publishDiagnostics'
endfunction

function! lsp#ale#enable() abort
    if s:Dispose isnot v:null
        return
    endif

    let s:Dispose = lsp#callbag#pipe(
            \   lsp#stream(),
            \   lsp#callbag#filter(funcref('s:is_diagnostics_response')),
            \   lsp#callbag#subscribe({ 'next': funcref('s:on_diagnostics') }),
            \ )
endfunction

function! lsp#ale#disable() abort
    if s:Dispose is v:null
        return
    endif
    call s:Dispose()
    let s:Dispose = v:null
endfunction
