let g:project_cfg_dir = ".ide"
let g:build_dir = g:project_cfg_dir . "/build"
let g:session_file = g:project_cfg_dir . "/session"
let g:tags_file = g:project_cfg_dir . "/tags"

" Project functions

	fun! Callback(self, data)
	  echom string(a:data)
	endf

	fun! s:ctags_initiate()
		if executable("ctags")
			let cmd = "ctags -R -f " . g:tags_file
			let l:job = job_start(cmd, {'callback': 'Callback'})
		else
			echom "Ctags was not found."
		endif
	endf

	fun! s:project_clean()
		if	!isdirectory(g:build_dir) 
			return
		endif

		echom delete(g:build_dir, "rf") == 0 ? "Build directory has been cleaned." : "Error while cleaning"
		let &makeprg = ''
	endf

	fun! s:project_check()
		if filereadable(g:session_file)
			exe "so " . g:session_file
		endif
	
		if !filereadable(g:tags_file)
			call s:ctags_initiate()
		endif 
	endf

	fun! s:project_initiate()
		let l:initiate_command = "cmake -S . -B " . g:build_dir
		let l:build_command = "cmake --build " . g:build_dir

		if exists("g:build_arch") && !empty(g:build_arch)
			let l:initiate_command .= "_" . g:build_arch
			let l:build_command .= "_" . g:build_arch
			let l:initiate_command .= " -A " . g:build_arch
		endif

		if exists("g:build_generator") && !empty(g:build_generator)
			let l:initiate_command .= " -G \"" . g:build_generator	."\""
		endif

		if exists("g:build_type") && !empty(g:build_type)
			let l:initiate_command .= " -DCMAKE_BUILD_TYPE=" . g:build_type
			let l:build_command .= " --config " . g:build_type
		endif

		if exists("g:build_target") && !empty(g:build_target)
			let l:build_command .= " --target " .  g:build_target
		endif

		if exists("g:build_options") && !empty(g:build_options)
			for key in keys(g:build_options)
				let l:initiate_command .= ' -D' . key . '=' . g:build_options[key]
			endfor
		endif

		let l:job = job_start(l:initiate_command, {'callback': 'Callback'})
		let &makeprg = l:build_command
	endf

	fun! s:project_install()
		let cmd = "cmake --install " . g:build_dir
		let l:job = job_start(cmd, {'callback': 'Callback'})
	endf

" Project options

	let &tags=g:tags_file

	set errorformat=\ %#%f(%l\\\,%c):\ %m

" interface

	au VimLeavePre * silent! exe "mks! " . g:session_file
	au VimEnter * silent! call s:project_check()

	command! Init call s:project_initiate()
	command! Clean call s:project_clean()
	command! Install call s:project_install()