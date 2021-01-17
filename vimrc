" Основные

	filetype plugin indent on

	syntax on

	colo molokai

	set lz					" Перерисовывает только когда это нужно
	set hid					" Не выгружать буфер, когда переключаемся на другой
	set ar					" Перечитывать изменённые файлы автоматически
	set aw					" Сохраняет файл при переключении между файлами
	set sb					" Разрешает разделение экрана горизонтально
	set spr					" Разрешает разделение экрана вертикально
	set confirm				" Использовать диалоги вместо сообщений об ошибках

	set path+=.,,**
	set browsedir=current	" Переходит в каталог с файлом
	set noswapfile

	set bo=all					" Отключает оповещение об ошибках
	set cot=menu

	set mouse=a					" Включает поддержку мыши при работе в терминале (без GUI)
	set mousem=popup

	set ff=unix					" Формат файла по умолчанию - будет перебираться в указанном порядке

	set backspace=indent,eol,start
	set dict+=g:path.'/dictionary'		" Указывает где создать словарь для пользовательских расширений
	set clipboard=unnamed,unnamedplus	" Указывает использовать системный буфер обмена вместо буфера Vim
	set secure
	set wcm=<Tab>
	set ttimeoutlen=10

	if has('unix')
		set bdir=/tmp
	el
		set bdir=$TMP
	en

" Орфография

	if version >= 700
		me Spell.off :setlocal spell spelllang=<Cr>:setlocal nospell<Cr>
		me Spell.Russian+English :setlocal spell spelllang=ru_yo,en_us<Cr>
		me Spell.Russian :setlocal spell spelllang=ru<Cr>
		me Spell.English :setlocal spell spelllang=en<Cr>
		me Spell.-SpellControl- :
		me Spell.Word\ Suggest<Tab>z= z=
		me Spell.Add\ To\ Dictionary<Tab>zg zg
		me Spell.Add\ To\ TemporaryDictionary<Tab>zG zG
		me Spell.Remove\ From\ Dictionary<Tab>zw zw
		me Spell.Remove\ From\ Temporary\ Dictionary<Tab>zW zW
		me Spell.Previous\ Wrong\ Word<Tab>[s [s
		me Spell.Next\ Wrong\ Word<Tab>]s ]s
	en

" Поиск

	set hls				" Подсвечивание результатов поиска
	set is				" Поиск в процессе набора
	set ignorecase		" Игнорирует регистр букв при поиске
	set smartcase		" Если искомое выражения содержит символы в верхнем регистре - ищет с учётом регистра, иначе - без учёта

" Кодировки

	set enc=utf-8								" Кодировка редактора по умолчанию
	set tenc=utf-8								" Кодировка терминала по умолчанию utf8
	set fencs=utf-8,cp1251,koi8-r,cp866	" Варианты кодировки файла по умолчанию
	set kmp=russian-jcukenwin
	set imi=0
	set ims=0

" Сворачивания текста

	set mls=1
	set fdm=indent			" Определяет блоки на основе отступов
	set fdn=3				" Сворачивает до 3 уровня вложенности
	set fdo=all				" Автоматически разворачивает при входе в блок
	set fcl=all				" Автоматически сворачивает при выходе из блока

" Отступы

	set ai				" Включает автоотступы
	set si				" Включает "умные" отступы
	set ts=3				" Размер табуляции
	set shiftwidth=3	" Размер сдвига
	set sts=3
 
" Запрещенные форматы

	set wig+=*.bak,*.swp,*.swo
	set wig+=*.a,*.o,*.so,*.pyc,*.class,*.dll
	set wig+=*.jpg,*.jpeg,*.gif,*.png,*.pdf
	set wig+=*/.git*,*.tar,*.zip
	set wim=longest:full,list:full

" Внешний вид

	set title			" Показывает имя буфера в заголовке терминала
	set titlestring=%F	
	set nu
	set rnu				" Относительная нумерация строк
	set sc				" Показывает завершённые команды в статусбаре
	set lbr				" Переносит целые слова
	set sm				" Показывает парные символы
	set wmnu				" Дополнительная информация в строке состояния
	set ch=1				" Делает строку команд высотой в одну строку
	"set so=3				" Количество строк внизу и вверху экрана показываемое при прокрутке
	set ls=2				" Всегда показывает строку состояния
	set tw=130
	set cul

	let &t_SI = "\e[6 q"
	let &t_SR = "\e[4 q"
	let &t_EI = "\e[2 q"
	
	aug ccs
		au!
		au VimEnter * silent !echo -ne "\e[2 q"
	aug END

" Браузер	

	let g:netrw_browse_split = 4
	let g:netrw_altv = 1
	let g:netrw_banner = 0
	let g:netrw_liststyle = 3
	let g:netrw_winsize = 25

" Сочетания клавиш

	ino <C-l> <C-^>

	nn ; :

	nn <Cr> o<Esc>
	nn <Space> za

	nn + <C-a>
	nn - <C-x>

	nn <Tab> >>
	nn <S-Tab> <<

	vn <Tab> >>
	vn <S-Tab> <<

	nn dl yyp
	nn K i<Cr><Esc>
	nn U <C-r>
	nn Y y$

	nn n nzvzz
	nn N Nzvzz

	nn `` :call ToggleVExplorer()<Cr>

	" Командная строка
	
		cno vb vert sb

	" Переключение между окнами
	
		nm j <C-w>j
		nm k <C-w>k
		nm l <C-w>l
		nm h <C-w>h

	" Перемещения сплитов

		nm <C-j> <C-w>J
		nm <C-k> <C-w>K
		nm <C-l> <C-w>L
		nm <C-h> <C-w>H

	" suround
	
		nm ds	<Plug>Dsurround
		nm cs	<Plug>Csurround
		nm cS	<Plug>CSurround
		nm ys	<Plug>Ysurround
		nm yS	<Plug>YSurround
		nm yss <Plug>Yssurround
		nm ySs <Plug>YSsurround
		nm ySS <Plug>YSsurround
		xm S	<Plug>VSurround
		xm gS	<Plug>VgSurround

	" Коменарии

		nm \\	<Plug>Commentary
		vm \\ <Plug>CommentaryLine

	" Перемещение строк

		vm J <Plug>MoveBlockDown
		vm K <Plug>MoveBlockUp
		vm H <Plug>MoveBlockLeft
		vm L <Plug>MoveBlockRight

		nm J <Plug>MoveLineDown
		nm K <Plug>MoveLineUp
		nm H <Plug>MoveLineLeft
		nm L <Plug>MoveLineRight

	" Показать список буферов
	
		nm <F5> :buffers<Cr>
		vm <F5> <Esc>:buffers<Cr>
		im <F5> <Esc>:buffers<Cr>

	" Навигация
	
		nn <Up> <C-B>
		nn <Down> <C-F>
	
		nn <silent> [b :bn<Cr>
		nn <silent> ]b :bp<Cr>

		nn <silent> [t :tn<Cr>
		nn <silent> ]t :tp<Cr>

		nn <silent> [T :tfirst<Cr>
		nn <silent> ]T :tlast<Cr>

" Меню

	" Выбор кодировки, в которой читать файл

		me Encoding.Read.utf-8<Tab><F7> :e ++enc=utf8 <Cr>
		me Encoding.Read.windows-1251<Tab><F7> :e ++enc=cp1251<Cr>
		me Encoding.Read.koi8-r<Tab><F7> :e ++enc=koi8-r<Cr>
		me Encoding.Read.cp866<Tab><F7> :e ++enc=cp866<Cr>
		map <F7> :emenu Encoding.Read.<Tab>

	" Выбор кодировки, в которой сохранять файл

		me Encoding.Write.utf-8<Tab><F6> :set fenc=utf8 <Cr>
		me Encoding.Write.windows-1251<Tab><F6> :set fenc=cp1251<Cr>
		me Encoding.Write.koi8-r<Tab><F6> :set fenc=koi8-r<Cr>
		me Encoding.Write.cp866<Tab><F6> :set fenc=cp866<Cr>
		map <F6> :emenu Encoding.Write.<Tab>

	" Выбор формата концов строк 

		me Encoding.End_line_format.unix<Tab><F8> :set fileformat=unix<Cr>
		me Encoding.End_line_format.dos<Tab><F8> :set fileformat=dos<Cr>
		me Encoding.End_line_format.mac<Tab><F8> :set fileformat=mac<Cr>
		map <F8> :emenu Encoding.End_line_format.<Tab>

" Функции

	fu! ToggleVExplorer()
		if exists("t:expl_buf_num")
			let expl_win_num = bufwinnr(t:expl_buf_num)
			let cur_win_num = winnr()
			if expl_win_num != -1
				wh expl_win_num != cur_win_num
					exe "wincmd w"
					let cur_win_num = winnr()
				endw
				clo
			en
			unlet t:expl_buf_num
		el
			Vexplore
			let t:expl_buf_num = bufnr("%")
		en
	endf

