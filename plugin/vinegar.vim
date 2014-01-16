" vinegar.vim - combine with netrw to create a delicious salad dressing
" Maintainer:   Tim Pope <http://tpo.pe/>

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

nnoremap <silent> <Plug>VinegarUp :if empty(expand('%'))<Bar>edit .<Bar>else<Bar>edit %:h<Bar>call <SID>seek(expand('%:t'))<Bar>endif<CR>
if empty(maparg('-', 'n'))
  nmap - <Plug>VinegarUp
endif

function! s:seek(file)
  let pattern = '^'.escape(expand('#:t'), '.*[]~\').'[/*|@=]\=\%($\|\t\)'
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
  " NERDTree move up
  nmap <buffer> - u
  nnoremap <buffer> ~ :edit ~/<CR>
  nnoremap <buffer> . :<C-U> <C-R>=<SID>escaped(line('.'), line('.') - 1 + v:count1)<CR><Home>
  xnoremap <buffer> . <Esc>: <C-R>=<SID>escaped(line("'<"), line("'>"))<CR><Home>
  nmap <buffer> ! .!
  xmap <buffer> ! .!
endfunction
