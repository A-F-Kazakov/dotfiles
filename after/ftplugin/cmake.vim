setl fdm=manual	
setl noic		
setl list	
setl lcs=tab:·\ ,trail:-

let b:project_dir = ".ide"

fu! ProjectInitiate()
	if !isdirectory(b:project_dir)
		if exists("*mkdir")
			call mkdir(b:project_dir, "p")
			echom "Project initialized"
		el
			echom "Cannot create project directory"
		en
	en
endf

if filereadable(".ide/config")
	so .ide/config
en
