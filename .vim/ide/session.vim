if exists("g:project_session_loaded") && g:loaded_project_session  | finish | en
let g:project_session_loaded = 1

let g:project.session_path = g:project.folder . '/session'

if exists('g:project_session_file')
	let g:project.session_path = g:project_session_file
en

if filereadable(g:project.session_path)
	exe 'so ' . g:project.session_path
en

set ssop-=blank,help,options
set ssop+=localoptions,resize,winpos,globals

au VimLeavePre * silent! exe 'mks! ' . g:project.session_path
