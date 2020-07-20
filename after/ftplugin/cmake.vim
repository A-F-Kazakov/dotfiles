setlocal fdm=manual	
setlocal noic		
setlocal list	
setlocal lcs=tab:·\ ,trail:-

let b:project_dir = ".ide"

function! ProjectInitiate()
	if !isdirectory(b:project_dir)
		if exists("*mkdir")
			call mkdir(b:project_dir, "p")
			echom "Project initialized"
		else
			echom "Cannot create project directory"
		endif
	endif
endfunction

if filereadable(".ide/config")
	so .ide/config
endif
