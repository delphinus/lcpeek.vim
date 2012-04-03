if exists('g:loaded_lcpeek')| finish| endif| let g:loaded_lcpeek = 1
if !exists('g:peekdir')
  let g:peekdir = '~/'
endif
if !exists('g:peekmsg')
  let g:peekmsg = 0
endif

let s:peekdir = fnamemodify(g:peekdir, ':p').'.lcpeek/'
let s:peeklist = []
let s:peeknum = -1


function! PeekReset() "{{{
  let s:peeknum = 0
  let files = split(globpath(s:peekdir, '*'),'\n')
  for picked in files
    if getftype(picked) == 'file'
      call delete(picked)
    endif
  endfor
endfunction "}}}

function! PeekInput(Varname, varval, ...) "{{{
  if s:peeknum == -1
    call PeekReset()
    let s:peeknum = 0
  endif
  if a:0
    if !empty(a:1)
      let peeknum = a:1
    else
      let s:peeknum +=1
      let peeknum = s:peeknum
    endif
  else
    let s:peeknum +=1
    let peeknum = s:peeknum
  endif

  let stacktrace = substitute(expand('<sfile>'), '..PeekInput', '' ,'')
  if a:Varname == ''
    let varname = substitute(substitute(stacktrace,'function ','','g'), '<SNR>', '__', 'g')
  else
    let varname = a:Varname
  endif
  let varname = substitute(varname, '\V:\|/\|\\\|*\|?\|"\|<\|>\||', '_', 'g')

  if !exists('g:'.varname)
    exe 'let g:'.varname.' = []'
    exe 'call add(s:peeklist, varname)'
  endif

  exe 'call add(g:'.varname.', peeknum.":		".string(a:varval)."		".stacktrace)'

  if !isdirectory(s:peekdir)
    call mkdir(s:peekdir)
  endif
  exe 'call writefile(g:'.varname.', s:peekdir.varname)'

  if g:peekmsg
    echomsg printf('(%d:) %s/%s = %s', peeknum, stacktrace, a:Varname , string(a:varval))
  endif
endfunction "}}}

function! PeekEcho() "{{{
  let echo = 'LcPeek:'
  for varname in s:peeklist
    exe 'let echo .= "\n". varname. " =". g:'.varname.'[-1]'
  endfor
  echo echo
endfunction "}}}

