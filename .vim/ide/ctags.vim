
	fu! s:ctags_initiate()
		if executable("ctags")
			let cmd = "ctags -R -f " . g:tags_file
			let l:job = job_start(cmd, {'callback': 'Callback'})
		el
			echom "Ctags was not found."
		en
	endf

