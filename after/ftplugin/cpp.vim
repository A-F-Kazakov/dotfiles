function! MyFoldText()
	let nl = v:foldend - v:foldstart + 1
	let fbegin = trim(getline(v:foldstart))
	let fend = trim(getline(v:foldend))
	let txt = '+ ' . fbegin . ' ' . nl . ' ' . fend
	return txt
endfunction

setlocal nowrap
setlocal fdls=0
setlocal fdm=syntax	
setlocal noic
setlocal list
setlocal fcs=fold:\ 

setlocal syntax=cpp.doxygen
setlocal foldtext=MyFoldText()

