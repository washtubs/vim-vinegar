" vinegar.vim - combine with netrw to create a delicious salad dressing
" Maintainer:   Dhruva Sagar <http://dhruvasagar.com/>

if exists("g:loaded_vinegar") || v:version < 700 || &cp
  finish
endif
let g:loaded_vinegar = 1

function! s:fnameescape(file) abort
  if exists('*fnameescape')
    return fnameescape(a:file)
  else
    return escape(a:file," \t\n*?[{`$\\%#'\"|!<")
  endif
endfunction

nnoremap <silent> <Plug>VinegarUp :call <SID>opendir('edit')<CR>
if empty(maparg('-', 'n'))
  nmap - <Plug>VinegarUp
endif

nnoremap <silent> <Plug>VinegarTabUp :call <SID>opendir('tabedit')<CR>
nnoremap <silent> <Plug>VinegarSplitUp :call <SID>opendir('split')<CR>
nnoremap <silent> <Plug>VinegarVerticalSplitUp :call <SID>opendir('vsplit')<CR>

function! s:opendir(cmd)
  if empty(expand('%'))
    execute a:cmd '.'
  else
    let currfile = expand('%:t')
    execute a:cmd '%:h'
    call <SID>seek(currfile)
  endif
endfunction

function! s:seek(file)
  let pattern = '^ *\%(▸ \)\?'.escape(a:file, '.*[]~\').'\>'
  call search(pattern, 'wc')
  return pattern
endfunction

augroup vinegar
  autocmd!
  autocmd FileType nerdtree call s:setup_vinegar()
augroup END

function! s:escaped(first, last) abort
  let files = getline(a:first, a:last)
  call filter(files, 'v:val !~# "^\" "')
  call map(files, 'substitute(v:val, "[/*|@=]\\=\\%(\\t.*\\)\\=$", "", "")')
  " Strip any whitespace
  call map(files, 'substitute(v:val, "^\\s*\\(.\\{-}\\)\\s*$", "\\1", "")')
  let curdir = b:NERDTreeRoot.path.str()
  return join(map(files, 'fnamemodify(curdir."/".v:val,":~:.")'), ' ')
endfunction

function! s:setup_vinegar() abort
  execute 'nmap <buffer> -' g:NERDTreeMapUpdir
  nnoremap <buffer> ~ :edit ~/<CR>
  nnoremap <buffer> . :<C-U> <C-R>=<SID>escaped(line('.'), line('.') - 1 + v:count1)<CR><Home>
  xnoremap <buffer> . <Esc>: <C-R>=<SID>escaped(line("'<"), line("'>"))<CR><Home>
  nmap <buffer> ! .!
  xmap <buffer> ! .!
  nnoremap <buffer> <silent> cg :exe 'keepjumps cd ' .<SID>fnameescape(b:netrw_curdir)<CR>
  nnoremap <buffer> <silent> cl :exe 'keepjumps lcd '.<SID>fnameescape(b:netrw_curdir)<CR>
endfunction
