"" vim-plug
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
call plug#begin()

" ステータスラインを表示
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" colorscheme
Plug 'tomasiser/vim-code-dark' " codedark
Plug 'junegunn/seoul256.vim' " seoul256
Plug 'altercation/vim-colors-solarized' " solarized

Plug 'Yggdroot/indentLine'

" Python Indent
Plug 'Vimjas/vim-python-pep8-indent'

call plug#end()

" シンタックスハイライト
syntax on
" カラースキーム
silent! colorscheme codedark
" let g:seoul256_background = 234 " 233(darkest) ~ 239(lightest)
" silent! colorscheme seoul256
"let g:solarized_termcolor = 256
"silent! colorscheme solarized

"" indentLine
let g:indentLine_char = '│'

"" vim-airline
" カラースキーム
let g:airline_theme = 'codedark'

" ------------------
" 表示設定
" ------------------
" 行番号表示
set number
" ターミナルのタイトルを編集ファイルに設定
set title
" マウス有効化
set mouse=a
" 不可視文字の表示
set list
" 不可視文字
" タブ、行末スペース、改行文字、表示幅に収まらず表示されていない文字、不可視のスペース？
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
" カーソル行を強調表示
set cursorline
" スクロール開始行数
set scrolloff=2

" 以下ステータスラインの表示設定はvim-alirlineを使わない場合のため
" ステータスラインを常に表示
set laststatus=2
" ファイル名表示
set statusline=%F
" 変更有無の表示
set statusline+=%m
" 読み込み専用表示
set statusline+=%r
" ヘルプページ表示[HELP]
set statusline+=%h
" プレビューウィンドウ表示[Preview]
set statusline+=%w
" これ以降を右寄せ表示
set statusline+=%=
" エンコーディング
set statusline+=[ENC=%{&fileencoding}]
" 現在の行番号/全行数
set statusline+=[LOW=%l/%L]

" ------------------
" SEARCH
" ------------------
" 検索結果をハイライト表示
set hlsearch
" インクリメント検索 文字を入力するごとにマッチする
set incsearch
" 大文字小文字の区別をしない
set ignorecase
" 大文字と小文字がどちらも含まれている場合は区別する
set smartcase
" ファイルの最後まで検索した後最初に戻る
set wrapscan

" ------------------
" EDIT
" ------------------
" タブ文字の表示幅(行頭以外）
set tabstop=4
" タブ文字の表示幅(行頭、0はtabstopと同じ）
set shiftwidth=0
" tab入力を半角スペースに変換
set smarttab
" tabを半角スペースに展開
set expandtab
" 改行時のインデント自動挿入
set autoindent
" 入力時対応するカッコの強調表示
set showmatch
" カッコに<>を追加
set matchpairs+=<:>
" 矩形選択時に行末に文字がなくてもカーソル移動できるようにする
set virtualedit+=block

" ------------------
" netrw ファイラ
" ------------------
" プラグインを有効化
filetype plugin on
" 表示形式 1: filename, size, last modified
let g:netrw_liststyle=1
" ヘッダを非表示にする
" let g:netrw_banner=0
" ファイルサイズを(k, m, g)で表示
let g:netrw_sizestyle="H"
" 日付の表示フォーマット yyyy/mm/dd(曜日) H:M:Sで表示
let g:netrw_timefmt="%Y/%m/%d(%a) %H:%M:%S"
" プレビュー(p)表示を垂直分割で表示
let g:netrw_preview=1
