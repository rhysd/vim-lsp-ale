function! ale#other_source#StartChecking(bufnr, name) abort
    let s:start_checking_called = [a:bufnr, a:name]
endfunction

function! ale#other_source#ShowResults(bufnr, name, results) abort
    let s:show_results_called = [a:bufnr, a:name, a:results]
endfunction

function! ale#other_source#last_start_checking() abort
    return s:start_checking_called
endfunction

function! ale#other_source#last_show_results() abort
    return s:show_results_called
endfunction

function! WaitUntil(func, ...) abort
    let timeout = get(a:, 1, 1) " 1sec by default
    let total = 0
    while !a:func()
        sleep 100m
        let total += 0.1
        if total >= timeout
            " Note: v:true/v:false are not supported by themis.vim
            " https://github.com/thinca/vim-themis/pull/56
            return 0
        endif
    endwhile
    return 1
endfunction

function! ale#other_source#wait_until_show_results() abort
    let timeout = 1
    let total = 0
    while s:show_results_called is v:null
        sleep 100m
        let total += 0.1
        if total >= timeout
            throw 'ale#other_source#ShowResults() was not called while 1 second'
        endif
    endwhile
endfunction

function! ale#other_source#reset() abort
    let s:start_checking_called = v:null
    let s:show_results_called = v:null
endfunction

call ale#other_source#reset()
