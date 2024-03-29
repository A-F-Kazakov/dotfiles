" commentary.vim - Comment stuff out
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.3
" GetLatestVimScripts: 3695 1 :AutoInstall: commentary.vim

if exists("g:loaded_commentary") || v:version < 700
	finish
en
let g:loaded_commentary = 1

fu! s:surroundings() abort
	return split(get(b:, 'commentary_format', substitute(substitute(substitute(&commentstring, '^$', '%s', ''), '\S\zs%s',' %s', '') ,'%s\ze\S', '%s ', '')), '%s', 1)
endf

fu! s:strip_white_space(l,r,line) abort
	let [l, r] = [a:l, a:r]
	if l[-1:] ==# ' ' && stridx(a:line,l) == -1 && stridx(a:line,l[0:-2]) == 0
		let l = l[:-2]
	en
	if r[0] ==# ' ' && a:line[-strlen(r):] != r && a:line[1-strlen(r):] == r[1:]
		let r = r[1:]
	en
	return [l, r]
endf

fu! s:go(...) abort
	if !a:0
		let &operatorfunc = matchstr(expand('<sfile>'), '[^. ]*$')
		return 'g@'
	elseif a:0 > 1
		let [lnum1, lnum2] = [a:1, a:2]
	el
		let [lnum1, lnum2] = [line("'["), line("']")]
	en

	let [l, r] = s:surroundings()
	let uncomment = 2
	for lnum in range(lnum1,lnum2)
		let line = matchstr(getline(lnum),'\S.*\s\@<!')
		let [l, r] = s:strip_white_space(l,r,line)
		if len(line) && (stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
			let uncomment = 0
		en
	endfor

	if get(b:, 'commentary_startofline')
		let indent = '^'
	else
		let indent = '^\s*'
	endif

	for lnum in range(lnum1,lnum2)
		let line = getline(lnum)
		if strlen(r) > 2 && l.r !~# '\\'
			let line = substitute(line,
				\'\M' . substitute(l, '\ze\S\s*$', '\\zs\\d\\*\\ze', '') . '\|' . substitute(r, '\S\zs', '\\zs\\d\\*\\ze', ''),
				\'\=substitute(submatch(0)+1-uncomment,"^0$\\|^-\\d*$","","")','g')
		endif
		if uncomment
			let line = substitute(line,'\S.*\s\@<!','\=submatch(0)[strlen(l):-strlen(r)-1]','')
		else
			let line = substitute(line,'^\%('.matchstr(getline(lnum1),indent).'\|\s*\)\zs.*\S\@<=','\=l.submatch(0).r','')
		endif
		call setline(lnum,line)
	endfor
	let modelines = &modelines
	try
		set modelines=0
		silent doautocmd User CommentaryPost
	finally
		let &modelines = modelines
	endtry
	return ''
endf

fu! s:textobject(inner) abort
	let [l, r] = s:surroundings()
	let lnums = [line('.')+1, line('.')-2]
	for [index, dir, bound, line] in [[0, -1, 1, ''], [1, 1, line('$'), '']]
		wh lnums[index] != bound && line ==# '' || !(stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
			let lnums[index] += dir
			let line = matchstr(getline(lnums[index]+dir),'\S.*\s\@<!')
			let [l, r] = s:strip_white_space(l,r,line)
		endw
	endfor
	wh (a:inner || lnums[1] != line('$')) && empty(getline(lnums[0]))
		let lnums[0] += 1
	endwh
	wh a:inner && empty(getline(lnums[1]))
		let lnums[1] -= 1
	endwh
	if lnums[0] <= lnums[1]
		exe 'normal! 'lnums[0].'GV'.lnums[1].'G'
	en
endfu

com! -range -bar Commentary call s:go(<line1>,<line2>)
xn <expr>   <Plug>Commentary     <SID>go()
nn <expr>   <Plug>CommentaryLine <SID>go() . '_'

