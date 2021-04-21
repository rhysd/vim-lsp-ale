function! lsp#utils#get_buffer_uri(bufnr) abort
    return 'file://' . s:bufname
endfunction

function! lsp#utils#uri_to_path(uri) abort
    return s:bufname
endfunction

function! lsp#utils#mock_buf_name(name) abort
    let s:bufname = a:name
endfunction
