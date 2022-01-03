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

let s:prev_num_diags = {}
function! lsp#ale#_reset_prev_num_diags() abort
    let s:prev_num_diags = {}
endfunction

function! s:can_skip_diags(server, uri, diags) abort
    if !has_key(s:prev_num_diags, a:server)
        let s:prev_num_diags[a:server] = {}
    endif
    let prev = s:prev_num_diags[a:server]

    let num_diags = len(a:diags)
    if num_diags == 0 && get(prev, a:uri, -1) == 0
        " Some language servers send diagnostics notifications even if the
        " results are not changed from previous. It's hard to check the
        " notifications are perfectly the same as previous. Here only checks
        " emptiness and skip if both previous ones and current ones are
        " empty.
        " I believe programmers usually try to keep no lint errors in the
        " source code they are writing :)
        return v:true
    endif

    let prev[a:uri] = num_diags
    return v:false
endfunction

function! s:can_skip_all_diags(uri, all_diags) abort
    for [server, diags] in items(a:all_diags)
        if !s:can_skip_diags(server, a:uri, diags.params.diagnostics)
            return v:false
        endif
    endfor
    return v:true
endfunction

function! s:is_active_linter() abort
    if g:lsp_ale_auto_enable_linter
        return v:true
    endif
    let active_linters = get(b:, 'ale_linters', get(g:ale_linters, &filetype, []))
    return index(active_linters, 'vim-lsp') >= 0
endf

function! lsp#ale#on_ale_want_results(bufnr) abort
    " Note: Checking lsp#internal#diagnostics#state#_is_enabled_for_buffer here. If previous lint
    " errors remain in a buffer, they won't be updated when vim-lsp is disabled for the buffer.
    if s:Dispose is v:null || !lsp#internal#diagnostics#state#_is_enabled_for_buffer(a:bufnr)
        return
    endif

    let uri = lsp#utils#get_buffer_uri(a:bufnr)
    let all_diags = lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_server_for_uri(uri)
    if empty(all_diags) || s:can_skip_all_diags(uri, all_diags)
        " Do nothing when no diagnostics results
        return
    endif

    if s:is_active_linter()
        call ale#other_source#StartChecking(a:bufnr, 'vim-lsp')
        " Avoid the issue that sign and highlight are not set
        " https://github.com/dense-analysis/ale/issues/3690
        call timer_start(0, {-> s:notify_diag_to_ale(a:bufnr, all_diags) })
    endif
endfunction

function! s:notify_diag_to_ale(bufnr, diags) abort
    try
        let threshold = s:severity_threshold()
        let results = []
        for [server, diag] in items(a:diags)
            echo l:diag
            let locs = ale#lsp#response#ReadDiagnostics(diag)

            " Note: Do not filter `diag` destructively since the object is also used by vim-lsp
            " let locs = lsp#ui#vim#utils#diagnostics_to_loc_list({'response': diag})
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
    catch
        " Since ale#other_source#StartChecking() was already called, ale#other_source#ShowResults()
        " needs to be called to notify ALE that checking was done.
        call ale#other_source#ShowResults(a:bufnr, 'vim-lsp', [])
        let msg = v:exception . ' at ' . v:throwpoint
        if msg !~# '^vim-lsp-ale: '
            " Avoid E608 on rethrowing exceptions from Vim script runtime
            let msg = 'vim-lsp-ale: Error while notifying results to ALE: ' . msg
        endif
        throw msg
    endtry
    call ale#other_source#ShowResults(a:bufnr, 'vim-lsp', results)
endfunction

function! s:notify_diag_to_ale_for_buf(bufnr) abort
    if !s:is_active_linter()
        return
    endif

    let uri = lsp#utils#get_buffer_uri(a:bufnr)
    let diags = lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_server_for_uri(uri)
    call s:notify_diag_to_ale(a:bufnr, diags)
endfunction

function! s:on_diagnostics(res) abort
    let uri = a:res.response.params.uri
    if s:can_skip_diags(a:res.server, uri, a:res.response.params.diagnostics)
        return
    endif

    let path = lsp#utils#uri_to_path(uri)
    let bufnr = bufnr('^' . path . '$')
    if bufnr == -1
        " This branch is reachable when vim-lsp receives some notifications
        " but the buffer for them was already deleted. This can happen since
        " notifications are asynchronous
        return
    endif

    call ale#other_source#StartChecking(bufnr, 'vim-lsp')
    " Use timer_start to ensure calling s:notify_diag_to_ale after all
    " subscribers handled the publishDiagnostics event.
    " lsp_setup is hooked before vim-lsp sets various internal hooks. So this
    " function is called before the response is not handled by vim-lsp yet.
    call timer_start(0, {-> s:notify_diag_to_ale_for_buf(bufnr) })
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
