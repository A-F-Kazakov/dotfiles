" surround.vim - Surroundings
" Author:		 Tim Pope <http://tpo.pe/>
" Version:		 2.1
" GetLatestVimScripts: 1697 1 :AutoInstall: surround.vim

if exists("g:loaded_surround") || &cp || v:version < 700
	finish
en
let g:loaded_surround = 1

fu! s:getchar()
	let c = getchar()
	if c =~ '^\d\+$'
		let c = nr2char(c)
	en
	return c
endf

fu! s:inputtarget()
	let c = s:getchar()
	wh c =~ '^\d\+$'
	let c .= s:getchar()
	endw
	if c == " "
		let c .= s:getchar()
	en
	if c =~ "\<Esc>\|\<C-C>\|\0"
		return ""
	el
		return c
	en
endf

fu! s:inputreplacement()
	let c = s:getchar()
	if c == " "
		let c .= s:getchar()
	en
	if c =~ "\<Esc>" || c =~ "\<C-C>"
		return ""
	el
		return c
	en
endf

fu! s:beep()
	exe "norm! \<Esc>"
	return ""
endf

fu! s:redraw()
	redraw
	return ""
endf

fu! s:extractbefore(str)
	if a:str =~ '\r'
		return matchstr(a:str,'.*\ze\r')
	el
		return matchstr(a:str,'.*\ze\n')
	en
endf

fu! s:extractafter(str)
	if a:str =~ '\r'
		return matchstr(a:str,'\r\zs.*')
	el
		return matchstr(a:str,'\n\zs.*')
	en
endf

fu! s:fixindent(str,spc)
	let str = substitute(a:str,'\t',repeat(' ',&sw),'g')
	let spc = substitute(a:spc,'\t',repeat(' ',&sw),'g')
	let str = substitute(str,'\(\n\|\%^\).\@=','\1'.spc,'g')
	if ! &et
		let str = substitute(str,'\s\{'.&ts.'\}',"\t",'g')
	en
	return str
endf

fu! s:process(string)
	let i = 0
	for i in range(7)
		let repl_{i} = ''
		let m = matchstr(a:string,nr2char(i).'.\{-\}\ze'.nr2char(i))
		if m != ''
			let m = substitute(strpart(m,1),'\r.*','','')
			let repl_{i} = input(match(m,'\w\+$') >= 0 ? m.': ' : m)
		en
	endfor
	let s = ""
	let i = 0
	wh i < strlen(a:string)
		let char = strpart(a:string,i,1)
		if char2nr(char) < 8
			let next = stridx(a:string,char,i+1)
			if next == -1
				let s .= char
			el
				let insertion = repl_{char2nr(char)}
				let subs = strpart(a:string,i+1,next-i-1)
				let subs = matchstr(subs,'\r.*')
				wh subs =~ '^\r.*\r'
					let sub = matchstr(subs,"^\r\\zs[^\r]*\r[^\r]*")
					let subs = strpart(subs,strlen(sub)+1)
					let r = stridx(sub,"\r")
					let insertion = substitute(insertion,strpart(sub,0,r),strpart(sub,r+1),'')
				endw
				let s .= insertion
				let i = next
			en
		el
			let s .= char
		en
		let i += 1
	endw
	return s
endf

fu! s:wrap(string,char,type,removed,special)
	let keeper = a:string
	let newchar = a:char
	let s:input = ""
	let type = a:type
	let linemode = type ==# 'V' ? 1 : 0
	let before = ""
	let after  = ""
	if type ==# "V"
		let initspaces = matchstr(keeper,'\%^\s*')
	el
		let initspaces = matchstr(getline('.'),'\%^\s*')
	en
	let pairs = "b()B{}r[]a<>"
	let extraspace = ""
	if newchar =~ '^ '
		let newchar = strpart(newchar,1)
		let extraspace = ' '
	en
	let idx = stridx(pairs,newchar)
	if newchar == ' '
		let before = ''
		let after	= ''
	elseif exists("b:surround_".char2nr(newchar))
		let all		= s:process(b:surround_{char2nr(newchar)})
		let before = s:extractbefore(all)
		let after	=	s:extractafter(all)
	elseif exists("g:surround_".char2nr(newchar))
		let all		= s:process(g:surround_{char2nr(newchar)})
		let before = s:extractbefore(all)
		let after	=	s:extractafter(all)
	elseif newchar ==# "p"
		let before = "\n"
		let after	= "\n\n"
	elseif newchar ==# 's'
		let before = ' '
		let after	= ''
	elseif newchar ==# ':'
		let before = ':'
		let after = ''
	elseif newchar =~# "[tT\<C-T><]"
		let dounmapp = 0
		let dounmapb = 0
		if !maparg(">","c")
			let dounmapb = 1
			exe "cn"."oremap > ><CR>"
		en
		let default = ""
		if newchar ==# "T"
			if !exists("s:lastdel")
				let s:lastdel = ""
			en
			let default = matchstr(s:lastdel,'<\zs.\{-\}\ze>')
		en
		let tag = input("<",default)
		if dounmapb
			silent! cunmap >
		en
		let s:input = tag
		if tag != ""
			let keepAttributes = ( match(tag, ">$") == -1 )
			let tag = substitute(tag,'>*$','','')
			let attributes = ""
			if keepAttributes
				let attributes = matchstr(a:removed, '<[^ \t\n]\+\zs\_.\{-\}\ze>')
			en
			let s:input = tag . '>'
			if tag =~ '/$'
				let tag = substitute(tag, '/$', '', '')
				let before = '<'.tag.attributes.' />'
				let after = ''
			el
				let before = '<'.tag.attributes.'>'
				let after = '</'.substitute(tag,' .*','','').'>'
			en
			if newchar == "\<C-T>"
				if type ==# "v" || type ==# "V"
				let before .= "\n\t"
			en
			if type ==# "v"
				let after	= "\n". after
			en
		en
	en
	elseif newchar ==# 'l' || newchar == '\'
		let env = input('\begin{')
		if env != ""
			let s:input = env."\<CR>"
			let env = '{' . env
			let env .= s:closematch(env)
			echo '\begin'.env
			let before = '\begin'.env
			let after  = '\end'.matchstr(env,'[^}]*').'}'
		en
	elseif newchar ==# 'f' || newchar ==# 'F'
		let fnc = input('function: ')
		if fnc != ""
			let s:input = fnc."\<CR>"
			let before = substitute(fnc,'($','','').'('
			let after  = ')'
			if newchar ==# 'F'
				let before .= ' '
				let after = ' ' . after
			en
		 en
	elseif newchar ==# "\<C-F>"
		let fnc = input('function: ')
		let s:input = fnc."\<CR>"
		let before = '('.fnc.' '
		let after = ')'
	elseif idx >= 0
		let spc = (idx % 3) == 1 ? " " : ""
		let idx = idx / 3 * 3
		let before = strpart(pairs,idx+1,1) . spc
		let after	= spc . strpart(pairs,idx+2,1)
	elseif newchar == "\<C-[>" || newchar == "\<C-]>"
		let before = "{\n\t"
		let after	= "\n}"
	elseif newchar !~ '\a'
		let before = newchar
		let after	= newchar
	el
		let before = ''
		let after	= ''
	en
	let after  = substitute(after ,'\n','\n'.initspaces,'g')
	if type ==# 'V' || (a:special && type ==# "v")
		let before = substitute(before,' \+$','','')
		let after	= substitute(after ,'^ \+','','')
		if after !~ '^\n'
			let after  = initspaces.after
		en
		if keeper !~ '\n$' && after !~ '^\n'
			let keeper .= "\n"
		elseif keeper =~ '\n$' && after =~ '^\n'
			let after = strpart(after,1)
		en
		if keeper !~ '^\n' && before !~ '\n\s*$'
			let before .= "\n"
			if a:special
				let before .= "\t"
			en
		elseif keeper =~ '^\n' && before =~ '\n\s*$'
			let keeper = strcharpart(keeper,1)
		en
		if type ==# 'V' && keeper =~ '\n\s*\n$'
			let keeper = strcharpart(keeper,0,strchars(keeper) - 1)
		en
	en
	if type ==# 'V'
		let before = initspaces.before
	en
	if before =~ '\n\s*\%$'
		if type ==# 'v'
			let keeper = initspaces.keeper
		en
		let padding = matchstr(before,'\n\zs\s\+\%$')
		let before = substitute(before,'\n\s\+\%$','\n','')
		let keeper = s:fixindent(keeper,padding)
	en
	if type ==# 'V'
		let keeper = before.keeper.after
	elseif type =~ "^\<C-V>"
		let repl = substitute(before,'[\\~]','\\&','g').'\1'.substitute(after,'[\\~]','\\&','g')
		let repl = substitute(repl,'\n',' ','g')
		let keeper = substitute(keeper."\n",'\(.\{-\}\)\(\n\)',repl.'\n','g')
		let keeper = substitute(keeper,'\n\%$','','')
	el
		let keeper = before.extraspace.keeper.extraspace.after
	en
	return keeper
endf

fu! s:wrapreg(reg,char,removed,special)
	let orig = getreg(a:reg)
	let type = substitute(getregtype(a:reg),'\d\+$','','')
	let new = s:wrap(orig,a:char,type,a:removed,a:special)
	call setreg(a:reg,new,type)
endf

fu! s:insert(...) " {{{1
	let linemode = a:0 ? a:1 : 0
	let char = s:inputreplacement()
	wh char == "\<CR>" || char == "\<C-S>"
		let linemode += 1
		let char = s:inputreplacement()
	endw
	if char == ""
		return ""
	en
	let cb_save = &clipboard
	set clipboard-=unnamed clipboard-=unnamedplus
	let reg_save = @@
	call setreg('"',"\r",'v')
	call s:wrapreg('"',char,"",linemode)
	if linemode && match(getreg('"'),'^\n\s*\zs.*') == 0
		call setreg('"',matchstr(getreg('"'),'^\n\s*\zs.*'),getregtype('"'))
	en
	if exists("g:surround_insert_tail")
		call setreg('"',g:surround_insert_tail,"a".getregtype('"'))
	en
	if &ve != 'all' && col('.') >= col('$')
		if &ve == 'insert'
			let extra_cols = virtcol('.') - virtcol('$')
			if extra_cols > 0
				let [regval,regtype] = [getreg('"',1,1),getregtype('"')]
				call setreg('"',join(map(range(extra_cols),'" "'),''),'v')
				norm! ""p
				call setreg('"',regval,regtype)
			en
		en
		norm! ""p
	el
		norm! ""P
	en
	if linemode
		call s:reindent()
	en
	norm! `]
	call search('\r','bW')
	let @@ = reg_save
	let &clipboard = cb_save
	return "\<Del>"
endf

fu! s:reindent() " {{{1
	if exists("b:surround_indent") ? b:surround_indent : (!exists("g:surround_indent") || g:surround_indent)
		silent norm! '[=']
	en
endf

fu! s:dosurround(...) " {{{1
	let scount = v:count1
	let char = (a:0 ? a:1 : s:inputtarget())
	let spc = ""
	if char =~ '^\d\+'
		let scount = scount * matchstr(char,'^\d\+')
		let char = substitute(char,'^\d\+','','')
	en
	if char =~ '^ '
		let char = strpart(char,1)
		let spc = 1
	en
	if char == 'a'
		let char = '>'
	en
	if char == 'r'
		let char = ']'
	en
	let newchar = ""
	if a:0 > 1
		let newchar = a:2
		if newchar == "\<Esc>" || newchar == "\<C-C>" || newchar == ""
			return s:beep()
		en
	en
	let cb_save = &clipboard
	set clipboard-=unnamed clipboard-=unnamedplus
	let append = ""
	let original = getreg('"')
	let otype = getregtype('"')
	call setreg('"',"")
	let strcount = (scount == 1 ? "" : scount)
	if char == '/'
		exe 'norm! '.strcount.'[/d'.strcount.']/'
	elseif char =~# '[[:punct:][:space:]]' && char !~# '[][(){}<>"''`]'
		exe 'norm! T'.char
		if getline('.')[col('.')-1] == char
			exe 'norm! l'
		en
			exe 'norm! dt'.char
	el
		exe 'norm! d'.strcount.'i'.char
	en
	let keeper = getreg('"')
	let okeeper = keeper " for reindent below
	if keeper == ""
		call setreg('"',original,otype)
		let &clipboard = cb_save
		return ""
	en
	let oldline = getline('.')
	let oldlnum = line('.')
	if char ==# "p"
		call setreg('"','','V')
	elseif char ==# "s" || char ==# "w" || char ==# "W"
		call setreg('"','')
	elseif char =~ "[\"'`]"
		exe "norm! i \<Esc>d2i".char
		call setreg('"',substitute(getreg('"'),' ','',''))
	elseif char == '/'
		norm! "_x
		call setreg('"','/**/',"c")
		let keeper = substitute(substitute(keeper,'^/\*\s\=','',''),'\s\=\*$','','')
	elseif char =~# '[[:punct:][:space:]]' && char !~# '[][(){}<>]'
		exe 'norm! F'.char
		exe 'norm! df'.char
	el
		call search('\m.', 'bW')
		exe "norm! da".char
	en
	let removed = getreg('"')
	let rem2 = substitute(removed,'\n.*','','')
	let oldhead = strpart(oldline,0,strlen(oldline)-strlen(rem2))
	let oldtail = strpart(oldline,  strlen(oldline)-strlen(rem2))
	let regtype = getregtype('"')
	if char =~# '[\[({<T]' || spc
		let keeper = substitute(keeper,'^\s\+','','')
		let keeper = substitute(keeper,'\s\+$','','')
	en
	if col("']") == col("$") && virtcol('.') + 1 == virtcol('$')
		if oldhead =~# '^\s*$' && a:0 < 2
			let keeper = substitute(keeper,'\%^\n'.oldhead.'\(\s*.\{-\}\)\n\s*\%$','\1','')
		en
		let pcmd = "p"
	el
		let pcmd = "P"
	en
	if line('.') + 1 < oldlnum && regtype ==# "V"
		let pcmd = "p"
	en
	call setreg('"',keeper,regtype)
	if newchar != ""
		let special = a:0 > 2 ? a:3 : 0
		call s:wrapreg('"',newchar,removed,special)
	en
	silent exe 'norm! ""'.pcmd.'`['
	if removed =~ '\n' || okeeper =~ '\n' || getreg('"') =~ '\n'
		call s:reindent()
	en
	if getline('.') =~ '^\s\+$' && keeper =~ '^\s*\n'
		silent norm! cc
	en
	call setreg('"',original,otype)
	let s:lastdel = removed
	let &clipboard = cb_save
	if newchar == ""
		silent! call repeat#set("\<Plug>Dsurround".char,scount)
	el
		silent! call repeat#set("\<Plug>C".(a:0 > 2 && a:3 ? "S" : "s")."urround".char.newchar.s:input,scount)
	en
endf

fu! s:changesurround(...) " {{{1
	let a = s:inputtarget()
	if a == ""
		return s:beep()
	en
	let b = s:inputreplacement()
	if b == ""
		return s:beep()
	en
	call s:dosurround(a,b,a:0 && a:1)
endf

fu! s:opfunc(type, ...) abort " {{{1
	if a:type ==# 'setup'
		let &opfunc = matchstr(expand('<sfile>'), '<SNR>\w\+$')
		return 'g@'
	en
	let char = s:inputreplacement()
	if char == ""
		return s:beep()
	en
	let reg = '"'
	let sel_save = &selection
	let &selection = "inclusive"
	let cb_save	= &clipboard
	set clipboard-=unnamed clipboard-=unnamedplus
	let reg_save = getreg(reg)
	let reg_type = getregtype(reg)
	let type = a:type
	if a:type == "char"
		silent exe 'norm! v`[o`]"'.reg.'y'
		let type = 'v'
	elseif a:type == "line"
		silent exe 'norm! `[V`]"'.reg.'y'
		let type = 'V'
	elseif a:type ==# "v" || a:type ==# "V" || a:type ==# "\<C-V>"
		let &selection = sel_save
		let ve = &virtualedit
		if !(a:0 && a:1)
			set virtualedit=
		en
		silent exe 'norm! gv"'.reg.'y'
		let &virtualedit = ve
	elseif a:type =~ '^\d\+$'
		let type = 'v'
		silent exe 'norm! ^v'.a:type.'$h"'.reg.'y'
		if mode() ==# 'v'
			norm! v
			return s:beep()
		en
	el
		let &selection = sel_save
		let &clipboard = cb_save
		return s:beep()
	en
	let keeper = getreg(reg)
	if type ==# "v" && a:type !=# "v"
		let append = matchstr(keeper,'\_s\@<!\s*$')
		let keeper = substitute(keeper,'\_s\@<!\s*$','','')
	en
	call setreg(reg,keeper,type)
	call s:wrapreg(reg,char,"",a:0 && a:1)
	if type ==# "v" && a:type !=# "v" && append != ""
		call setreg(reg,append,"ac")
	en
	silent exe 'norm! gv'.(reg == '"' ? '' : '"' . reg).'p`['
	if type ==# 'V' || (getreg(reg) =~ '\n' && type ==# 'v')
		call s:reindent()
	en
	call setreg(reg,reg_save,reg_type)
	let &selection = sel_save
	let &clipboard = cb_save
	if a:type =~ '^\d\+$'
		silent! call repeat#set("\<Plug>Y".(a:0 && a:1 ? "S" : "s")."surround".char.s:input,a:type)
	el
		silent! call repeat#set("\<Plug>SurroundRepeat".char.s:input)
	en
endf

fu! s:opfunc2(...) abort
	if !a:0 || a:1 ==# 'setup'
		let &opfunc = matchstr(expand('<sfile>'), '<SNR>\w\+$')
		return 'g@'
	en
	call s:opfunc(a:1, 1)
endf

fu! s:closematch(str) " {{{1
	let tail = matchstr(a:str,'.[^\[\](){}<>]*$')
	if tail =~ '^\[.\+'
		return "]"
	elseif tail =~ '^(.\+'
		return ")"
	elseif tail =~ '^{.\+'
		return "}"
	elseif tail =~ '^<.+'
		return ">"
	el
		return ""
	en
endf

nn  <silent> <Plug>SurroundRepeat .
nn  <silent> <Plug>Dsurround	:<C-U>call <SID>dosurround(<SID>inputtarget())<CR>
nn  <silent> <Plug>Csurround	:<C-U>call <SID>changesurround()<CR>
nn  <silent> <Plug>CSurround	:<C-U>call <SID>changesurround(1)<CR>
nn  <expr>	 <Plug>Yssurround '^'.v:count1.<SID>opfunc('setup').'g_'
nn  <expr>	 <Plug>YSsurround <SID>opfunc2('setup').'_'
nn  <expr>	 <Plug>Ysurround	<SID>opfunc('setup')
nn  <expr>	 <Plug>YSurround	<SID>opfunc2('setup')
vn  <silent> <Plug>VSurround	:<C-U>call <SID>opfunc(visualmode(),visualmode() ==# 'V' ? 1 : 0)<CR>
vn  <silent> <Plug>VgSurround :<C-U>call <SID>opfunc(visualmode(),visualmode() ==# 'V' ? 0 : 1)<CR>
ino <silent> <Plug>Isurround	<C-R>=<SID>insert()<CR>
ino <silent> <Plug>ISurround	<C-R>=<SID>insert(1)<CR>

if !exists("g:surround_no_mappings") || ! g:surround_no_mappings
	nm ds	<Plug>Dsurround
	nm cs	<Plug>Csurround
	nm cS	<Plug>CSurround
	nm ys	<Plug>Ysurround
	nm yS	<Plug>YSurround
	nm yss <Plug>Yssurround
	nm ySs <Plug>YSsurround
	nm ySS <Plug>YSsurround
	xm S	<Plug>VSurround
	xm gS	<Plug>VgSurround
	if !exists("g:surround_no_insert_mappings") || ! g:surround_no_insert_mappings
		if !hasmapto("<Plug>Isurround","i") && "" == mapcheck("<C-S>","i")
			im		<C-S> <Plug>Isurround
		en
			im		<C-G>s <Plug>Isurround
			im		<C-G>S <Plug>ISurround
	en
en
