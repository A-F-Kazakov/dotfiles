if exists('g:loaded_project_cmake') && g:loaded_project_cmake
    finish
en
let g:loaded_project_cmake = 1

let g:cmake_command = get(g:, 'cmake_command', 'cmake')

let s:config_vars = {
        \ 'g:project_source_dir'				: '.',
        \ 'g:project_build_dir'				: '.',
        \ 'g:project_build_type'				: 'Debug',
        \ 'g:project_generate_options'    : [],
        \ 'g:project_build_options'       : [],
        \ 'g:cmake_native_build_options'  : [],
        \ 'g:cmake_console_size'          : 15,
        \ 'g:cmake_console_position'      : 'botright',
        \ 'g:cmake_jump'                  : 0,
        \ 'g:cmake_jump_on_completion'    : 0,
        \ 'g:cmake_jump_on_error'         : 1,
        \ 'g:cmake_link_compile_commands' : 0,
        \ 'g:cmake_root_markers'          : ['.git', '.svn'],
        \ }

for s:cvar in items(s:config_vars)
	if !exists(s:cvar[0])
		let {s:cvar[0]} = s:cvar[1]
	el
		if type({s:cvar[0]}) is# v:t_list
			call extend({s:cvar[0]}, s:cvar[1])
		en
	en
endfo

" console

let s:console_buffer = -1
let s:console_id = -1
let s:console_script = fnameescape(join([expand('<sfile>:h'), 'console.sh'], '/'))

let s:cmd_id = -1
let s:cmd_done = 0
let s:last_cmd_output = []

let s:exit_term_mode = 0

fu! s:CreateBuffer() abort
	exe 'enew'
	let s:console_id = s:TermStart(s:console_script, function('s:CMakeConsoleCb'))
	nn <buffer> <silent> pg :CMakeGenerate<CR>
	"nn <buffer> <silent> cb :CMakeBuild<CR>
	"nn <buffer> <silent> ci :CMakeInstall<CR>
	nn <buffer> <silent> pq :CMakeClose<CR>
	nn <buffer> <silent> <C-C> :call s:commandStop()<CR>

	setl nonumber
	setl norelativenumber
	setl signcolumn=auto
	setl nobuflisted
	setl filetype=vimcmake
	setl statusline=[CMake]
	"setlocal statusline+=\ %{cmake#statusline#GetBuildInfo(0)}
	"setlocal statusline+=\ %{cmake#statusline#GetCmdInfo()}
	" Avoid error E37 on :CMakeClose in some Vim instances.
	setl bufhidden=hide
	aug project_cmake
		au WinEnter <buffer> call s:consoleOnEnter()
	aug END
	return bufnr()
endf

fu! s:CreateWindow() abort
	exe join([g:cmake_console_position, g:cmake_console_size, 'split'])
	setl winfixheight
	setl winfixwidth
endf

fu! s:consoleOpen(clear) abort
	let l:original_win_id = win_getid()
	let l:cmake_win_id = bufwinid(s:console_buffer)

	if l:cmake_win_id == -1
		" If a Vim-CMake window does not exist, create it.
		call s:CreateWindow()
		if bufexists(s:console_buffer)
			" If a Vim-CMake buffer exists, open it in the Vim-CMake window, or
			" delete it if a:clear is set.
			if !a:clear
				exe 'b ' . s:console_buffer
				call win_gotoid(l:original_win_id)
				return
			el
				exe 'bd! ' . s:console_buffer
			en
		en
		" Create Vim-CMake buffer if none exist, or if the old one was deleted.
		let s:console_buffer = s:CreateBuffer()
	el
		" If a Vim-CMake window exists, and a:clear is set, create a new
		" Vim-CMake buffer and delete the old one.
		if a:clear
			let l:old_buffer = s:console_buffer
			call s:consoleFocus()
			let s:console_buffer = s:CreateBuffer()
			if bufexists(l:old_buffer) && l:old_buffer != s:console_buffer
				exe 'bd! ' . l:old_buffer
			en
		en
	en

	if l:original_win_id != win_getid()
		call win_gotoid(l:original_win_id)
	en
endf

fu! s:consoleClose() abort
	if bufexists(s:console_buffer)
		let l:cmake_win_id = bufwinid(s:console_buffer)
		if l:cmake_win_id != -1
			exe win_id2win(l:cmake_win_id) . 'wincmd q'
		en
	en
endf

fu! s:consoleFocus() abort
	call win_gotoid(bufwinid(s:console_buffer))
endf

fu! s:SaveCmdOutput(string) abort
	" Remove ASCII color codes from string.
	let l:s = substitute(a:string, '\m\C\%x1B\[[0-9;]*[a-zA-Z]', '', 'g')
	" Split string into list entries.
	let l:l = split(l:s, '\r.')
	let s:last_cmd_output += l:l
endf

fu! s:CMakeConsoleCb(channel, data) abort
	if s:cmd_done
		let s:cmd_done = 0
		let s:last_cmd_output = []
	en
	call s:SaveCmdOutput(a:data)
	" Look for ETX (end of text) character from console.sh (dirty trick to mark end of command).
	if match(a:data, "\x03") >= 0
		let l:cmd_id = s:cmd_id
		let s:cmd_done = 1
		call s:SetCmdId('')
		"call cmake#build#UpdateTargets()
		"if l:cmd_id ==# 'build'
		"call cmake#quickfix#Generate()
		"endif
		" Exit terminal mode if inside the CMake console window (useful for
		" Vim). Otherwise the terminal mode is exited after WinEnter event.
		if win_getid() == bufwinid(s:console_buffer)
			call s:ExitTermMode()
		el
			let s:exit_term_mode = 1
		en
		"call cmake#statusline#Refresh()
		"call cmake#switch#SearchForExistingConfigs()
		"if g:cmake_jump_on_completion
			"call cmake#console#Focus()
		"endif
		"if match(l:data, '\m\CErrors have occurred') >= 0
			"if g:cmake_jump_on_error
				"call cmake#console#Focus()
			"endif
			"if l:cmd_id ==# 'build'
				"doautocmd <nomodeline> User CMakeBuildFailed
			"endif
		"else
			"if l:cmd_id ==# 'build'
				"doautocmd <nomodeline> User CMakeBuildSucceeded
			"endif
		"endif
	en
endf

fu! s:SetCmdId(id) abort
	if a:id ==# 'generate'
		let s:cmd_id = a:id
		"call cmake#statusline#SetCmdInfo('Generating buildsystem...')
	elseif a:id ==# 'build'
		let s:cmd_id = a:id
		"call cmake#statusline#SetCmdInfo('Building...')
	elseif a:id ==# 'install'
		let s:cmd_id = a:id
		"call cmake#statusline#SetCmdInfo('Installing...')
	el
		let s:cmd_id = ''
		"call cmake#statusline#SetCmdInfo('')
	en
endf

fu! s:consoleOnEnter() abort
	if winnr() == bufwinnr(s:console_buffer) && s:exit_term_mode
		let s:exit_term_mode = 0
		call s:ExitTermMode()
	en
endf

" terminal

fu! s:EnterTermMode() abort
	if mode() !=# 't'
		exe 'normal! i'
	en
endf

fu! s:ExitTermMode() abort
	if mode() ==# 't'
		call feedkeys("\<C-\>\<C-N>", 'n')
	en
endf

fu! s:TermStart(command, stdout_cb) abort
	let l:options = {}
	let l:options['curwin'] = 1
	if a:stdout_cb isnot# v:null
		let l:options['out_cb'] = a:stdout_cb
	en
	let l:term = term_start(a:command, l:options)
	" Set up autocmd to stocommandp terminal job before exiting Vim/Neovim. Older
	" versions of Vim/Neovim do not have 'ExitPre', in which case we use
	" 'VimLeavePre'. However, calling TermStop() on 'VimLeavePre' in Vim seems
	" to be too late and results in E947, in which case one should quit with
	" e.g. :qa!.
	aug project_cmake
		if exists('##ExitPre')
			au ExitPre * call s:TermStop()
		el
			au VimLeavePre * call s:TermStop()
		en
	aug END
	retu l:term
endf

fu! s:TermStop() abort
	try
		let l:job_id = term_getjob(s:console_id)
		call job_stop(l:job_id)
		call s:JobWait(l:job_id)
	catch /.*/
	endtry
endf

fu! s:TermSend(input) abort
	" For Vim, must go back into Terminal-Job mode for the command's output
	" to be appended to the buffer.
	call win_execute(bufwinid(s:console_buffer), 'call s:EnterTermMode()', '')
	call term_sendkeys(s:console_id, a:input . "\<CR>")
endf

" job

fu! s:JobStart(command, stdout_cb) abort
	let l:options = {}
	if a:stdout_cb isnot# v:null
		let l:options['out_cb'] = a:stdout_cb
	en
	let l:vim_command = join([&shell, &shellcmdflag, '"' . a:command . '"'])
	let l:job = job_start(l:vim_command, l:options)
	retu l:job
endf

fu! s:JobWait(job_id) abort
	wh job_status(a:job_id) ==# 'run'
		exe 'sleep 5m'
	endw
endf

" command

fu! s:Run(command, bg, wait, ...) abort
	" Note: Vim requires Funcref variable names to start with a capital.
	let l:StdoutCb = (a:0 > 0) ? a:1 : v:null
	if !a:bg
		" Open Vim-CMake console window with a fresh buffer.
		call s:consoleOpen(1)
		" Run command (send input to terminal buffer).
		call s:TermSend(join(a:command))
		" Jump to Vim-CMake window if requested.
		"if g:cmake_jump
		call s:consoleFocus()
		"endif
	el
		" Run background command and set callback.
		let l:job_id = s:JobStart(join(a:command), l:StdoutCb)
		if a:wait
			call s:JobWait(l:job_id)
		en
	en
endf

" Stop command currently running in the CMake console.

fu! s:commandStop() abort
	try
		call s:TermSend("\x03")
	catch /.*/
	endtry
endf

" commands

let s:cmake_version = []

fu! s:GetCMakeVersionCb(channel, data) abort
	if match(a:data, '\m\C^cmake version') == 0
		let l:version_str = split(split(a:data)[2], '\.')
		let l:major = str2nr(l:version_str[0])
		let l:minor = str2nr(l:version_str[1])
		let s:cmake_version = l:major * 100 + l:minor
	en
endf

" Get CMake version. The version is stored in s:cmake_version after the
" invocation of s:get_cmake_version_callback as MAJOR * 100 + MINOR (e.g.,
" version 3.13.3 would result in 313).
let s:command = [g:cmake_command, '--version']
call s:Run(s:command, 1, 1, function('s:GetCMakeVersionCb'))

fu! s:generate(bg, wait, clean, ...) abort
	let l:command = [g:cmake_command]
	let l:argstring = (a:0 > 0 && len(a:1) > 0) ? a:1 : ''
	"let l:arglist = s:ParseArgs(l:argstring)
	" Set source and build directories. Must be done after calling s:ParseArgs()
	" so that the current build configuration is up to date before setting the
	" build directory.
	"let l:source_dir = fnameescape(cmake#GetSourceDir())
	"let l:build_dir = fnameescape(cmake#switch#GetCurrentConfigDir())
	" Add CMake generate options to the command.
	"let l:command += g:project_generate_options
	"let l:command += l:arglist
	" Construct command based on CMake version.
	if s:cmake_version < 313
		let l:command += ['-H']
	el
		let l:command += ['-S']
	en

	let l:command += [g:project_source_dir, '-B', g:project_build_dir]

	call s:SetCmdId('generate')
	" Clean project buildsystem, if requested.
	if a:clean
		call s:Clean()
	en
	" Run generate command.
	call s:Run(l:command, a:bg, a:wait)
		"if g:cmake_link_compile_commands
		" Link compile commands.
	"let l:command = ['ln', '-sf', l:build_dir . '/compile_commands.json', l:source_dir]
	"call s:Run(l:command, 1, 1)
	"endif
endf

" Clean buildsystem (CMake files).

fu! s:Clean() abort
	"let l:build_dir = fnameescape(cmake#switch#GetCurrentConfigDir())
	if isdirectory(g:project_build_dir)
		let l:command = ['rm', '-rf', g:project_build_dir . '/*']
		call s:Run(l:command, 1, 1)
	en
endf

" mappings

com CMakeOpen call s:consoleOpen(0)
com CMakeClose call s:consoleClose()

com -nargs=? -bang CMakeGenerate call s:generate(0, 0, <bang>1, <f-args>)
com -nargs=? CMakeClean call s:Clean()

"command CMakeInstall call cmake#Install(0, 0)


