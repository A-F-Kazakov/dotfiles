" Основные

	filetype plugin indent on

	syntax on

	colo molokai

   set lz					" Перерисовывает только когда это нужно
   set hid					" Не выгружать буфер, когда переключаемся на другой
   set ar	        " Перечитывать изменённые файлы автоматически
   set aw					" Сохраняет файл при переключении между файлами
   set sb					" Разрешает разделение экрана горизонтально
   set spr					" Разрешает разделение экрана вертикально
   set confirm				" Использовать диалоги вместо сообщений об ошибках

   set path=.,,**
   set browsedir=current	" Переходит в каталог с файлом
	set noswapfile

   set bo=all					" Отключает оповещение об ошибках
   set cot=menu

   set mouse=a					" Включает поддержку мыши при работе в терминале (без GUI)
   set mousem=popup

   set ff=unix					" Формат файла по умолчанию - будет перебираться в указанном порядке

	set backspace=indent,eol,start
   set dict+=g:path.'/dictionary'	    " Указывает где создать словарь для пользовательских расширений
   set clipboard=unnamed,unnamedplus    " Указывает использовать системный буфер обмена вместо буфера Vim
	set secure
	set wcm=<Tab>
	set ttimeoutlen=10

	if has('unix')
      set bdir=/tmp/
   elseif has('win32') || has('win64')
      set bdir=$TMP
	endif

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
   endif

" Поиск

   set hls	        " Подсвечивание результатов поиска
   set is	        " Поиск в процессе набора
   set ignorecase   " Игнорирует регистр букв при поиске
   set smartcase    " Если искомое выражения содержит символы в верхнем регистре - ищет с учётом регистра, иначе - без учёта

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
   set fcl=all		   " Автоматически сворачивает при выходе из блока

" Отступы

   set ai           " Включает автоотступы
   set si           " Включает "умные" отступы
   set ts=3         " Размер табуляции
   set shiftwidth=3 " Размер сдвига
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
   set so=3				" Количество строк внизу и вверху экрана показываемое при прокрутке
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

	nn \\ :call ToggleComment()<Cr>
	vn \\ :call ToggleComment()<Cr>

	nn `` :call ToggleVExplorer()<Cr>

	" Командная строка
	
		cno W! w!
		cno Q! q!
		cno Qall! qall!
		cno Wq wq
		cno wQ wq
		cno Qall qall
		cno vb vert sb

	" Переключение между окнами
	
		no <C-j> <C-w>j
		no <C-k> <C-w>k
		no <C-l> <C-w>l
		no <C-h> <C-w>h

   " Показать список буферов
	
		nm <F5> :buffers<Cr>
		vm <F5> <Esc>:buffers<Cr>
		im <F5> <Esc>:buffers<Cr>

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

	let s:comment_map = { "c": '\/\/', "cpp": '\/\/', "sh": '#', "fstab": '#', "conf": '#', "profile": '#', "bashrc": '#', "bash_profile": '#', "vim": '"', "tex": '%' }

	fu! ToggleComment()
		if has_key(s:comment_map, &filetype)
			let comment_leader = s:comment_map[&filetype]
			if getline('.') =~ "^\\s*" . comment_leader . " " 
				exe "silent s/^\\(\\s*\\)" . comment_leader . " /\\1/"
			else 
				if getline('.') =~ "^\\s*" . comment_leader
					exe "silent s/^\\(\\s*\\)" . comment_leader . "/\\1/"
				else
					exe "silent s/^\\(\\s*\\)/\\1" . comment_leader . " /"
				end
			end
		end
	endfu

	fu! ToggleVExplorer()
		if exists("t:expl_buf_num")
			let expl_win_num = bufwinnr(t:expl_buf_num)
			let cur_win_num = winnr()
			if expl_win_num != -1
				wh expl_win_num != cur_win_num
					exe "wincmd w"
					let cur_win_num = winnr()
            endwh
            clo
        end
        unlet t:expl_buf_num
		else
			Vexplore
         let t:expl_buf_num = bufnr("%")
		endif
	endfu

