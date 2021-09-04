if exists("g:loaded_project_clang_format") && g:loaded_project_clang_format
	finish
en
let g:loaded_project_clang_format = 1

fu! s:format_code()
	let l:cmd = 'clang-format -style=file -i ' . @%
	let l:ret = system(l:cmd)
	silent! e
endf

aug auto_clang_format
   au!
	au BufWritePost *.hpp,*.h,*.cpp,*.c call s:format_code()
aug END
