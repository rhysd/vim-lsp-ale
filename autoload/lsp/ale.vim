" DiagnosticSeverity
let s:ERROR = 1
let s:WARN = 2
let s:INFO = 3
let s:HINT = 4

let s:Dispose = v:null

function! s:severity_threshold() abort
    let s = g:lsp_ale_diagnostics_severity
    if s ==? 'error'
        return s:ERROR
    elseif s ==? 'warning' || s ==? 'warn'
        return s:WARN
    elseif s ==? 'information' || s ==? 'info'
        return s:INFO
    elseif s ==? 'hint'
        return s:HINT
    else
        throw 'vim-lsp-ale: Unexpected severity "' . s . '". Severity must be one of "error", "warning", "information", "hint"'
    endif
endfunction

function! s:get_loc_type(severity) abort
    if a:severity == s:ERROR
        return 'E'
    elseif a:severity == s:WARN
        return 'W'
    elseif a:severity == s:INFO
        return 'I'
    elseif a:severity == s:HINT
        return 'H'
    else
        throw 'vim-lsp-ale: Unexpected severity: ' . a:severity
    endif
endfunction

function! lsp#ale#on_ale_want_results(bufnr) abort
    " Note: Checking lsp#internal#diagnostics#state#_is_enabled_for_buffer here. If previous lint
    " errors remain in a buffer, they won't be updated when vim-lsp is disabled for the buffer.
    if s:Dispose is v:null || !lsp#internal#diagnostics#state#_is_enabled_for_buffer(a:bufnr)
        return
    endif
    call ale#other_source#StartChecking(a:bufnr, 'vim-lsp')
    " Avoid the issue that sign and highlight are not set
    " https://github.com/dense-analysis/ale/issues/3690
    call timer_start(0, {-> s:notify_diag_to_ale(a:bufnr) })
endfunction

function! s:notify_diag_to_ale(bufnr) abort
    try
        let uri = lsp#utils#get_buffer_uri(a:bufnr)
        let diags = lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_server_for_uri(uri)
        let threshold = s:severity_threshold()
        let results = []
        for [server, diag] in items(diags)
            " Note: Do not filter `diag` destructively since the object is also used by vim-lsp
            let locs = lsp#ui#vim#utils#diagnostics_to_loc_list({'response': diag})
            let idx = 0
            for loc in locs
                let severity = get(diag.params.diagnostics[idx], 'severity', s:ERROR)
                if severity > threshold
                    continue
                endif
                let loc.text = '[' . server . '] ' . loc.text
                let loc.type = s:get_loc_type(severity)
                let results += [loc]
                let idx += 1
            endfor
        endfor
        call ale#other_source#ShowResults(a:bufnr, 'vim-lsp', results)
    catch
        " Since ale#other_source#StartChecking() was already called, ale#other_source#ShowResults()
        " needs to be called to notify ALE that checking was done.
        call ale#other_source#ShowResults(a:bufnr, 'vim-lsp', [])
        throw v:exception
    endtry
endfunction

let s:prev_num_diags = {}
function! lsp#ale#_reset_prev_num_diags() abort
    let s:prev_num_diags = {}
endfunction

function! s:on_diagnostics(res) abort
    let uri = a:res.response.params.uri
    let num_diags = len(a:res.response.params.diagnostics)
    if num_diags == 0 && has_key(s:prev_num_diags, uri) && s:prev_num_diags[uri] == 0
        " Some language servers send diagnostics notifications even if the
        " results are not changed from previous. It's hard to check the
        " notifications are perfectly the same as previous. Here only checks
        " emptiness and skip if both previous ones and current ones are
        " empty.
        " I believe programmers usually try to keep no lint errors in the
        " source code they are writing :)
        return
    endif

    let path = lsp#utils#uri_to_path(uri)
    let bufnr = bufnr('^' . path . '$')
    if bufnr == -1
        return
    endif

    call ale#other_source#StartChecking(bufnr, 'vim-lsp')
    " Use timer_start to ensure calling s:notify_diag_to_ale after all
    " subscribers handled the publishDiagnostics event.
    " lsp_setup is hooked before vim-lsp sets various internal hooks. So this
    " function is called before the response is not handled by vim-lsp yet.
    call timer_start(0, {-> s:notify_diag_to_ale(bufnr) })

    let s:prev_num_diags[uri] = num_diags
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

function! lsp#ale#enabled() abort
    return s:Dispose isnot v:null
endfunction
