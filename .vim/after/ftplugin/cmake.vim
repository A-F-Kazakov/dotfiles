setl fdm=manual	
setl noic		
setl list	
setl lcs=tab:·\ ,trail:-

if filereadable(".ide/config")
	so .ide/config
elseif filereadable("config")
	so config
en

let s:dir = '.ide'
let s:config = s:dir . '/config'

if !filereadable(s:config)
	fu! s:projectSetup() abort
		if !isdirectory(s:dir)
			call mkdir(s:dir, 'p')
		en
		if g:os == "Windows"
			let s:cfg_path = expand("%:p:h") . '\' . s:config
			call system('copy ' . $HOME . '\vimfiles\ide\config.in ' . s:cfg_path)
		else
			let s:cfg_path = expand("%:p:h") . '/' . s:config
			call system('cp ' . $HOME . '/.vim/ide/config.in ' . s:cfg_path)
		en

		exec 'so ' . s:config
	endf

	com ProjectSetup call s:projectSetup()
en

