function! lsp#callbag#pipe(source, filter, sink) abort
    let s:Filter = a:filter
    let s:Next = a:sink.next
    return {-> extend(s:, {'disposed': v:true})}
endfunction

function! lsp#callbag#filter(pred) abort
    return a:pred
endfunction

function! lsp#callbag#subscribe(sink) abort
    return a:sink
endfunction

" Functions for tests

function! lsp#callbag#piped() abort
    return s:Filter isnot v:null && s:Next isnot v:null
endfunction

function! lsp#callbag#disposed() abort
    return s:disposed
endfunction

function! lsp#callbag#reset() abort
    let s:Filter = v:null
    let s:Next = v:null
    let s:disposed = v:false
endfunction

function! lsp#callbag#mock_receive(res) abort
    if s:Filter(a:res)
        call s:Next(a:res)
    endif
endfunction
