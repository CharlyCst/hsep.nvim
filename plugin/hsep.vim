if exists('g:loaded_hsep') | finish | endif

let s:save_cpo = &cpo " save user cpoptions
set cpo&vim           " reset to default

command! HSep lua require'hsep'.hsep()

let &cpo = s:save_cpo " restore cpoptions
unlet s:save_cpo

let g:loaded_hsep = 1

