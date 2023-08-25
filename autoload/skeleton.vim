scriptencoding utf-8

if !exists('g:loaded_skeleton_nop3')
  finish
endif
let g:loaded_skeleton_nop3 = 1

let s:save_cpo = &cpo
set cpo&vim

"関数はautoload/以下に定義する
"autoload出来るように命名規約を守る。
"filename#funcname()
"autoload/a_plugin.vim
"  fu a_plugin#f()|echo 'f()'|endf
"autoload/a_plubin/utils.vim
"  fu a_plugin#utils#f()|echo 'util_f()'|endf
":call a_plugin#f() "-> 'f()'
":call a_plugin#utils#f() "-> 'util_f()'
"ファイル名やディレクトリの変更を容易にするため、各ファイルで以下のように定義
"しておく。
"これでいつどこにファイルを移動しても関数名を変更する必要がなくなる。
let s:name = expand("<sfile>:p:r:gs?[\\/]?#?:gs?.*autoload#??:gs")

fu! {s:name}#test()
  echo 'test'
endf

fu! {s:name}#echo(str)
  echo "{a:str} !!!"
endf

function! {s:name}#hello_world()
  echo "Hello, World!"
endfunction

function! {s:name}#stl()
  set stl+=skeleton
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
