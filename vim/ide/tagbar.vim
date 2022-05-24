scriptencoding utf-8

if &cp || exists('g:loaded_tagbar')
	 finish
en

fu! s:init_var(var, value) abort
	if !exists('g:tagbar_' . a:var)
		exe 'let g:tagbar_' . a:var . ' = ' . string(a:value)
	en
endfu

fu! s:setup_options() abort
	if !exists('g:tagbar_vertical') || g:tagbar_vertical == 0
		let previewwin_pos = 'topleft'
	el
		let previewwin_pos = 'rightbelow vertical'
	en
	let options = [
		\ ['autoclose', 0],
		\ ['autofocus', 0],
		\ ['autopreview', 0],
		\ ['autoshowtag', 0],
		\ ['case_insensitive', 0],
		\ ['compact', 0],
		\ ['expand', 0],
		\ ['foldlevel', 99],
		\ ['hide_nonpublic', 0],
		\ ['indent', 2],
		\ ['left', 0],
		\ ['previewwin_pos', previewwin_pos],
		\ ['show_visibility', 1],
		\ ['show_linenumbers', 0],
		\ ['singleclick', 0],
		\ ['sort', 1],
		\ ['systemenc', &encoding],
		\ ['vertical', 0],
		\ ['width', 40],
		\ ['zoomwidth', 1],
		\ ['silent', 0],
		\ ]

	for [opt, val] in options
		call s:init_var(opt, val)
	endfor
endf
call s:setup_options()

if !exists('g:tagbar_iconchars')
	if has('multi_byte') && has('unix') && &encoding == 'utf-8' && (empty(&termencoding) || &termencoding == 'utf-8')
		let g:tagbar_iconchars = ['▶', '▼']
	el
		let g:tagbar_iconchars = ['+', '-']
	en
en

fu! s:setup_keymaps() abort
	let keymaps = [
		\ ['jump',				'<CR>'],
		\ ['preview',			'p'],
		\ ['previewwin',		'P'],
		\ ['nexttag',			'<C-N>'],
		\ ['prevtag',			'<C-P>'],
		\ ['showproto',		'<Space>'],
		\ ['hidenonpublic',	'v'],
		\
		\ ['openfold',			['+', '<kPlus>', 'zo']],
		\ ['closefold',		['-', '<kMinus>', 'zc']],
		\ ['togglefold',		['o', 'za']],
		\ ['openallfolds',	['*', '<kMultiply>', 'zR']],
		\ ['closeallfolds',	['=', 'zM']],
		\ ['nextfold',			'zj'],
		\ ['prevfold',			'zk'],
		\
		\ ['togglesort',					's'],
		\ ['togglecaseinsensitive',	'i'],
		\ ['toggleautoclose',			'c'],
		\ ['zoomwin',						'x'],
		\ ['close',							'q'],
		\ ['help',				['<F1>', '?']],
		\ ]

	for [map, key] in keymaps
		call s:init_var('map_' . map, key)
		unlet key
	endfor
endf
call s:setup_keymaps()

aug TagbarSession
	au!
	au SessionLoadPost * nested call tagbar#RestoreSession()
aug END

com! -nargs=0 Tagbar							call tagbar#ToggleWindow()
com! -nargs=0 TagbarToggle					call tagbar#ToggleWindow()
com! -nargs=? TagbarOpen					call tagbar#OpenWindow(<f-args>)
com! -nargs=0 TagbarOpenAutoClose		call tagbar#OpenWindow('fcj')
com! -nargs=0 TagbarClose					call tagbar#CloseWindow()
com! -nargs=1 -bang TagbarSetFoldlevel	call tagbar#SetFoldLevel(<args>, <bang>0)
com! -nargs=0 TagbarShowTag				call tagbar#highlighttag(1, 1)
com! -nargs=? TagbarCurrentTag			echo tagbar#currenttag('%s', 'No current tag', <f-args>)
com! -nargs=1 TagbarGetTypeConfig		call tagbar#gettypeconfig(<f-args>)
com! -nargs=0 TagbarTogglePause			call tagbar#toggle_pause()

