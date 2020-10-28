fu! s:format_code()
	let l:cmd = "clang-format -style=file -i " . @%
	let l:ret = system(l:cmd)
	silent! e
endf

aug auto_clang_format
   au!
	au BufWritePost *.h,*.cpp call s:format_code()
aug END
