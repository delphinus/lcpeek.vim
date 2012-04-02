if exists('g:loaded_lcpeek')| finish| endif| let g:loaded_lcpeek = 1
if !exists('g:peekdir')
  let g:peekdir = '~/'
endif
if !exists('g:peekmsg')
  let g:peekmsg = 0
endif

let s:peekdir = fnamemodify(g:peekdir, ':p').'.lcpeek/'
let s:peeklist = []
let s:peeknum = 0


au VimEnter * call PeekReset()
function! PeekReset() "{{{
  let s:peeknum = 0
  let files = split(globpath(s:peekdir, '*'),'\n')
  for picked in files
    call delete(picked)
  endfor
endfunction "}}}

function! PeekInput(varname, varval, ...) "{{{
  if a:0
    let peeknum = a:1
  else
    let s:peeknum +=1
    let peeknum = s:peeknum
  endif

  let varname = substitute(a:varname,'\V:\|/\|\\\|*\|?\|"\|<\|>\||', '_', 'g')

  if !exists('g:'.varname)
    exe 'let g:'.varname.' = []'
    exe 'call add(s:peeklist, varname)'
  endif

  let stacktrace = substitute(expand('<sfile>'), '..PeekInput', '' ,'')
  exe 'call add(g:'.varname.', peeknum.":		".string(a:varval)."		".stacktrace)'

  if !isdirectory(s:peekdir)
    call mkdir(s:peekdir)
  endif
  exe 'call writefile(g:'.varname.', s:peekdir.varname)'

  if g:peekmsg
    echomsg printf('(%d:) %s = %s       [%s]', peeknum, a:varname , string(a:varval), stacktrace)
  endif
endfunction "}}}

function! PeekEcho() "{{{
  let echo = 'LcPeek:'
  for varname in s:peeklist
    exe 'let echo .= "\n". varname. " =". g:'.varname.'[-1]'
  endfor
  echo echo
endfunction "}}}

