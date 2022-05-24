if exists("g:loaded_project_session") && g:loaded_project_session
	finish
en
let g:loaded_project_session = 1

set ssop-=blank,help
set ssop+=localoptions,resize,winpos,globals

if !exists('g:project_config_dir')
	let g:project_config_dir = '.'
en

if !exists('g:project_session_file')
	let g:project_session_file = g:project_config_dir . '/session'
en

if filereadable(g:project_session_file)
	exe 'so ' . g:project_session_file
en

au VimLeavePre * silent! exe 'mks! ' . g:project_session_file
