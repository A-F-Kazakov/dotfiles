fu! MyFoldText()
	let nl = v:foldend - v:foldstart + 1
	let fbegin = trim(getline(v:foldstart))
	let fend = trim(getline(v:foldend))
	let txt = '+ ' . fbegin . ' ' . nl . ' ' . fend
	return txt
endf

setl nowrap
setl fdls=0
setl fdm=syntax	
setl noic

setl syntax=c.doxygen
setl foldtext=MyFoldText()

