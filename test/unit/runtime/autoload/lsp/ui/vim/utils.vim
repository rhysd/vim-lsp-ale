function! lsp#ui#vim#utils#diagnostics_to_loc_list(res) abort
    if len(s:loclists) == 0
        return []
    endif

    let ret = s:loclists[0]
    let s:loclists = s:loclists[1:]
    return ret
endfunction

function! lsp#ui#vim#utils#mock_diagnostics_to_loc_list(loclists) abort
    let s:loclists = copy(a:loclists)
endfunction

function! lsp#ui#vim#utils#reset() abort
    let s:loclists = []
endfunction

call lsp#ui#vim#utils#reset()
