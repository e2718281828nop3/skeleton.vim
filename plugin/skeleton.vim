"関数はautoload/以下に定義する
scriptencoding utf-8

"読み込みの可否をここで判断。
if exists('g:loaded_skeleton_nop3')
  finish
endif
let g:loaded_skeleton_nop3= 1

let s:save_cpo = &cpo
set cpo&vim

"autoloadしやすくするための変数
let s:name = expand("<sfile>:p:r:gs?[\\/]?#?:gs?.*autoload#??:gs")

"必要な関数をここで定義
"global。外部ファイルからアクセス可能。
let g:skeleton_prefix = 'Docllo'

"グローバル関数は大文字始まり
function SkeletonGlobal()
  return 'This is a global function.'
endf

"スクリプトローカル関数（以後スクリプト関数と呼ぶ）はs:ではじまる。
"スクリプト関数は基本的に外部からはアクセスできない。
"しかし、<SID>を使うことで外部からアクセスできるようになる。
"<SID>を使わなくても :function /skeleton とかで関数名を調べてコマンドから利用
"することは仕様上可能。使う場面はないと思うが。
function s:Add(one, two)
  let a = a:one + a:two
  exe "normal i".a."\<Esc>"
endf

fu! s:Echo(str)
  echo a:str." !!!!!"
endf

fu! s:Clear()
  normal ggVGd
endf

"スクリプト変数は、関数と違って外部から直接アクセスすることは出来ない。
"s:を<SID>に変換しても無理。
"しかしgetterとsetterを使えばアクセス可能
let s:skeleton = 'skeleton'
fu! s:get(var_name)
  return s:{a:var_name}
endf
fu! s:set(var_name, val)
  let s:{a:var_name} = a:val
endf

"コマンドとキーマッピングはplugin/以下に定義する
"コマンド、プラグイン、メニューの設定はスクリプト外からアクセスできる形で書く必
"要がある。つまり、スクリプト関数を使いたい場合はs:の代わりに<SID>を使う。
"スクリプト変数は使えない。使いたい場合はexe "文字列"で指定する。
"命名規約は大文字始まりであることのみ。スクリプト名＋関数名が推奨されているが
"強制性はない。

"ユーザーコマンドの定義
"s:xxxという形で書いても動くのか。。。
command! SkeletonDelete :normal 10dd
command! -nargs=1 SkeletonEcho :call s:Echo(<f-args>)
command! -nargs=+ SkeletonAdd :call s:Add(<f-args>)

"map定義
"プラグインの定義
"プラグインはユーザがマップして使うことを目的としてつくられる。
"プラグインの定義はmap定義で行われる。
"命名規約は特にないが、()を使い、スクリプト名を前置するのが通例
"
"normalキーマップを直接指定できる
nnoremap <Plug>(skeleton_system_copy) "*y

"関数をマップできる
noremap <script><Plug>(skeleton_test) :call SkeletonTest()<CR>

"スクリプト関数をマップするときはs:を<SID>に置き換える
noremap <script><Plug>(skeleton_clear) :call <SID>Clear()<CR>

"引数を取るときはコマンドをよぶと簡単
noremap <script><Plug>(skeleton_echo) :SkeletonEcho 
noremap <script><Plug>(skeleton_add) :SkeletonAdd 


"mapは、ユーザが既に定義していたら上書きしないのが良い作法。
"<unique>でlhsを、hasmapto()でrhsを確認。
if !hasmapto('<Plug>(skeleton_system_copy)', 'n')
" <Plug>をmapするときはnoremapは使えない。理由は後述。
  nmap <C-c> <Plug>(skeleton_system_copy)
end
if !hasmapto('<Plug>(skeleton_clear)', 'n')
  nmap <unique> cc <Plug>(skeleton_clear)
end
if !hasmapto('<Plug>(skeleton_echo)', 'n')
  nmap <unique> ee <Plug>(skeleton_echo)
end

"insert modeで関数を実行するときは <C-R>=funcname() を使う
imap <C-a> <C-R>=strftime("%c")<CR>
imap <C-b> <C-R>=<SID>get('skeleton')<CR>

"実行時に内容をコマンドラインに表示させたくない場合は<silent>属性をつける
imap <silent><C-b> <C-R>=<SID>get('skeleton')<CR>

"<expr>属性をつけるrhsに式を指定できる。
map <expr> <Leader>x pumvisible() ? ":echo 'visible'\<CR>":":echo 'not visible'\<CR>"

"mapとnoremapの使い分け
"mapは再帰的にmapをするので、最終的にデフォルトのキーマップに対するmapを設定する
"noremapはデフォルトのキーマップに対するマップを直接定義する。
"例
" map j k -> j を k にmap。jを押すと、カーソルが下にいくのではなく上に行く。
" ここで、
" map x j -> x を j にmap。xを押すとカーソルが上に移動する。x -> j -> k という流再帰な流れ。
" noremap x j -> jのデフォルトの機能にマップされる。 x -> j という流れ。カーソ
" ルが下に移動する
"
"<Plug>のキーマップは、mapで定義する。noremapは使えない。
"例
" map <Plug>(a_func) :call func()<CR>
" map f <Plug>(a_func) ... f -> <Plug>(a_func) -> call func()<CR>という流れ
" noremap f <Plug>(a_func) ... f -> なにもない
" ※<Plug>(a_func)のキーマップはデフォルトで存在しないので、noremapすると結
" 局何も実行されない。
"
"プラグイン、コマンド、関数の使い分け
"プラグイン<Plug>はユーザがマップして使うことを想定して定義されるものらしい。
"スクリプト内部（関数内とか）において<Plug>文字は使えない。つまりプラグインは使えない。
"よって、マップして使ってほしいもののみそのメッセージも込めて<Plug>にする。
"そうでないものは<Plug>にしない。という使い分けでいいと思う。
"コマンドは、その名の通りコマンドとして使うことを想定する場合に定義すれば良い
"。コマンドはまた、引数を受け取る<Plug>をつくるときにも便利に使えるし、スクリ
"プト内部でも使える。この辺りの判断は難しいが、それが最善だと思えれば使えば良
"い。
"グローバル関数との棲み分けは？
"グローバル関数を定義すればいつでもどこでもユーザが使える。だから敢えて<Plug>
"やコマンドを定義する必要があるかというと実用上そうでもない。でもグローバル属性は使わないにこし
"たことはないというのは他の言語同様Vim Scriptにおいても変わらないだろう。
"グローバル関数はなるべくつくらずに、スクリプト関数を基本とし、
"mapして使ってほしいものは<Plug>として、コマンドとして使ってほしいものは
"コマンドとして、その関数にインターフェースを被せ、関数として使ってほしいものはグローバル関数
"として提供する、という使い分けが良いだろう。

"オートコマンドの設定
augroup skeleton_nop3
"  autocmd InsertEnter * call skeleton_nop3#stl()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
