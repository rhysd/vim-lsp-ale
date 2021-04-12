" DiagnosticSeverity
let s:ERROR = 1
let s:WARN = 2
let s:INFO = 3
let s:HINT = 4

let s:Dispose = v:null

function! s:severity_threshold() abort
    let t = g:lsp_ale_severity_threshold
    if t ==? 'error'
        return s:ERROR
    elseif t ==? 'warning' || t ==? 'warn'
        return s:WARN
    elseif t ==? 'information' || t ==? 'info'
        return s:INFO
    elseif t ==? 'hint'
        return s:HINT
    else
        throw 'vim-lsp-ale: Unexpected severity "' . t . '". Severity must be one of "error", "warning", "information", "hint"'
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
    if s:Dispose is v:null
        return
    endif
    call ale#other_source#StartChecking(a:bufnr, 'vim-lsp')
    " Avoid the issue that sign and highlight are not set
    " https://github.com/dense-analysis/ale/issues/3690
    call timer_start(0, {-> s:notify_diag_to_ale(a:bufnr) })
endfunction

function! s:notify_diag_to_ale(bufnr) abort
    if !lsp#internal#diagnostics#state#_is_enabled_for_buffer(a:bufnr)
        call ale#other_source#ShowResults(a:bufnr, 'vim-lsp', [])
        return
    endif
    let uri = lsp#utils#get_buffer_uri(a:bufnr)
    let diags = items(lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_server_for_uri(uri))
    let threshold = s:severity_threshold()
    let results = []
    for [server, diag] in diags
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
endfunction

function! s:on_diagnostics(req) abort
    let bufnr = bufnr('')
    call ale#other_source#StartChecking(bufnr, 'vim-lsp')
    " Use timer_start to ensure calling s:notify_diag_to_ale after all
    " subscribers handled the publishDiagnostics event.
    " lsp_setup is hooked before vim-lsp sets various internal hooks. So this
    " function is called before the response is not handled by vim-lsp yet.
    call timer_start(0, {-> s:notify_diag_to_ale(bufnr) })
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
