if exists('g:loaded_hsep') | finish | endif

let s:save_cpo = &cpo " save user cpoptions
set cpo&vim           " reset to default

command! -nargs=? HSep call luaeval("require'hsep'.hsep(_A)", <q-args>)

let &cpo = s:save_cpo " restore cpoptions
unlet s:save_cpo

let g:loaded_hsep = 1

