lua require "nvim-autopairs".init()

" function RemapExpr()
"   let curline = getline('.')..')'
"   call setline('.',curline)
"   return "("
" endfunction
" function! RemapPairs()
"   return "\<c-r>=RemapExpr()\<cr>"
" endfunction
" inoremap <expr> ( RemapPairs()
" inoremap <esc> )<esc>)
