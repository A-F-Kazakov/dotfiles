if !exists("g:os")
	if has("win64") || has("win32") || has("win16")
		let g:os = "Windows"
	el
		let g:os = substitute(system('uname'), '\n', '', '')
	en
en
