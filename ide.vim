let g:project_cfg_dir = ".ide"
let g:build_dir = g:project_cfg_dir . "/build"
let g:session_file = g:project_cfg_dir . "/session"
let g:tags_file = g:project_cfg_dir . "/tags"

" Project functions

	fu! Callback(self, data)
	  echom string(a:data)
	endf

	fu! s:ctags_initiate()
		if executable("ctags")
			let cmd = "ctags -R -f " . g:tags_file
			let l:job = job_start(cmd, {'callback': 'Callback'})
		el
			echom "Ctags was not found."
		en
	endf

	fu! s:project_clean()
		if	!isdirectory(g:build_dir) 
			return
		en

		echom delete(g:build_dir, "rf") == 0 ? "Build directory has been cleaned." : "Error while cleaning"
		let &makeprg = ''
	endf

	fu! s:project_check()
		if filereadable(g:session_file)
			exe "so " . g:session_file
		en
	
		if !filereadable(g:tags_file)
			call s:ctags_initiate()
		en 
	endf

	fu! s:project_initiate()
		let l:initiate_command = "cmake -S . -B " . g:build_dir
		let l:build_command = "cmake --build " . g:build_dir

		if exists("g:build_arch") && !empty(g:build_arch)
			let l:initiate_command .= "_" . g:build_arch
			let l:build_command .= "_" . g:build_arch
			let l:initiate_command .= " -A " . g:build_arch
		en

		if exists("g:build_generator") && !empty(g:build_generator)
			let l:initiate_command .= " -G \"" . g:build_generator	."\""
		en

		if exists("g:build_type") && !empty(g:build_type)
			let l:initiate_command .= " -DCMAKE_BUILD_TYPE=" . g:build_type
			let l:build_command .= " --config " . g:build_type
		en

		if exists("g:build_target") && !empty(g:build_target)
			let l:build_command .= " --target " .  g:build_target
		en

		if exists("g:build_options") && !empty(g:build_options)
			for key in keys(g:build_options)
				let l:initiate_command .= ' -D' . key . '=' . g:build_options[key]
			endfor
		en

		let l:job = job_start(l:initiate_command, {'callback': 'Callback'})
		let &makeprg = l:build_command
	endf

	fu! s:project_install()
		let cmd = "cmake --install " . g:build_dir
		let l:job = job_start(cmd, {'callback': 'Callback'})
	endf

" Project options

	let &tags=g:tags_file

	set errorformat=\ %#%f(%l\\\,%c):\ %m

" interface

	au VimLeavePre * silent! exe "mks! " . g:session_file
	au VimEnter * silent! call s:project_check()

	com! Init call s:project_initiate()
	com! Clean call s:project_clean()
	com! Install call s:project_install()
