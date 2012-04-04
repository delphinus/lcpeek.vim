if exists('g:loaded_lcpeek')| finish| endif| let g:loaded_lcpeek = 1
if !exists('g:peekdir')
  let g:peekdir = '~/'
endif
if !exists('g:peekmsg')
  let g:peekmsg = 0
endif
if !exists('g:peekdisable')
  let g:peekdisable = 0
endif
let g:peekmaster = []

let s:peekdir = fnamemodify(g:peekdir, ':p').'.lcpeek/'
let s:peeklist = []
let s:peeknum = -1

"PeekInputが使われている部分を多少目立たせる
au BufEnter *.vim syntax match PreProc /PeekInput/ containedin=ALL

function! PeekReset() "{{{
  let s:peeknum = 0
  let files = split(globpath(s:peekdir, '*'),'\n')
  let mkdirname = strftime('%Y%m%d_%H%M%S')
  call filter(files, 'getftype(v:val) == "file"')
  if !empty(files)
    call mkdir(s:peekdir.mkdirname)
  endif
  for picked in files
    let flag = 1
    call rename(picked, s:peekdir.mkdirname.'/'. fnamemodify(picked, ':t'))
  endfor
endfunction "}}}

function! PeekInput(Varname, varval) "{{{
  if g:peekdisable
    return
  endif

  if s:peeknum == -1
    call PeekReset()
    let s:peeknum = 0
  endif
  let s:peeknum +=1
  let peeknum = s:peeknum

  let stacktrace = substitute(expand('<sfile>'), '..PeekInput', '' ,'')
  if a:Varname == ''
    let varname = substitute(substitute(stacktrace,'function ','','g'), '<SNR>', '__', 'g')
  elseif a:Varname == 'peekmaster'
    echoerr 'The "peekmaster" name is reserved.'
    return
  else
    let varname = a:Varname
  endif
  let varname = substitute(varname, '\V:\|/\|\\\|*\|?\|"\|<\|>\||', '_', 'g')

  if !exists('g:'.varname)
    exe 'let g:'.varname.' = []'
    exe 'call add(s:peeklist, varname)'
  endif

  exe 'call add(g:'.varname.', peeknum.":		".string(a:varval)."		".stacktrace)'
  exe 'call add(g:peekmaster, peeknum.":".varname."		".string(a:varval)."		".stacktrace)'

  if !isdirectory(s:peekdir)
    call mkdir(s:peekdir)
  endif
  exe 'call writefile(g:'.varname.', s:peekdir.varname)'
  exe 'call writefile(g:peekmaster, s:peekdir."peekmaster")'

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

"TODO
"PeekInput時のスレッド引数
