" =============================================================================
" File: plugin/move.vim
" Description: Move lines and selections up and even down.
" Author: Matthias Vogelgesang <github.com/matze>
" =============================================================================

if exists('g:loaded_move') || &compatible
	finish
en

let g:loaded_move = 1

if !exists('g:move_map_keys')
	let g:move_map_keys = 1
en

if !exists('g:move_auto_indent')
	let g:move_auto_indent = 1
en

if !exists('g:move_past_end_of_line')
	let g:move_past_end_of_line = 1
en

fu s:MoveVertically(first, last, distance)
	if !&modifiable || a:distance == 0
		return
	en

	let l:first = line(a:first)
	let l:last  = line(a:last)

	let l:old_pos = getcurpos()
	if a:distance < 0
		call cursor(l:first, 1)
		exe 'normal!' (-a:distance).'k'
		let l:after = line('.') - 1
	el
		call cursor(l:last, 1)
		exe 'normal!' a:distance.'j'
		let l:after = (foldclosedend('.') == -1 ? line('.') : foldclosedend('.'))
	en

	call setpos('.', l:old_pos)

	exe l:first ',' l:last 'move' l:after

	if g:move_auto_indent
		let l:first = line("'[")
		let l:last  = line("']")

		call cursor(l:first, 1)
		normal! ^
		let l:old_indent = virtcol('.')
		normal! ==
		let l:new_indent = virtcol('.')

		if l:first < l:last && l:old_indent != l:new_indent
			let l:op = (l:old_indent < l:new_indent
						\  ? repeat('>', l:new_indent - l:old_indent)
						\  : repeat('<', l:old_indent - l:new_indent))
			let l:old_sw = &shiftwidth
			let &shiftwidth = 1
			exe l:first+1 ',' l:last l:op
			let &shiftwidth = l:old_sw
		en

		call cursor(l:first, 1)
		normal! 0m[
		call cursor(l:last, 1)
		normal! $m]
	en
endf

fu s:MoveLineVertically(distance)
	let l:old_col = col('.')
	normal! ^
	let l:old_indent = col('.')

	call s:MoveVertically('.', '.', a:distance)

	normal! ^
	let l:new_indent = col('.')
	call cursor(line('.'), max([1, l:old_col - l:old_indent + l:new_indent]))
endf

fu s:MoveBlockVertically(distance)
	call s:MoveVertically("'<", "'>", a:distance)
	normal! gv
endf

fu s:MoveHorizontally(corner_start, corner_end, distance)
	if !&modifiable || a:distance == 0
		return 0
	en

	let l:cols = [col(a:corner_start), col(a:corner_end)]
	let l:first = min(l:cols)
	let l:last  = max(l:cols)
	let l:width = l:last - l:first + 1

	let l:before = max([1, l:first + a:distance])
	if a:distance > 0 && !g:move_past_end_of_line
		let l:lines = getline(a:corner_start, a:corner_end)
		let l:shortest = min(map(l:lines, 'strwidth(v:val)'))
		if l:last < l:shortest
			let l:before = min([l:before, l:shortest - l:width + 1])
		el
			let l:before = l:first
		en
	en

	if l:first == l:before
		return 0
	en

	let l:old_default_register = @"
	normal! x

	let l:old_virtualedit = &virtualedit
	if l:before >= col('$')
		let &virtualedit = 'all'
	el
		let &virtualedit = ''
	en

	call cursor(line('.'), l:before)
	normal! P

	let &virtualedit = l:old_virtualedit
	let @" = l:old_default_register

	return 1
endf

fu s:MoveCharHorizontally(distance)
	call s:MoveHorizontally('.', '.', a:distance)
endf

fun s:MoveBlockHorizontally(distance)
	exe "normal! g`<\<C-v>g`>"
	if s:MoveHorizontally("'<", "'>", a:distance)
		exe "normal! g`[\<C-v>g`]"
	en
endf

fu s:HalfPageSize()
	return winheight('.') / 2
endf

vn <silent> <Plug>MoveBlockDown				:<C-u> silent call <SID>MoveBlockVertically( v:count1)<CR>
vn <silent> <Plug>MoveBlockUp					:<C-u> silent call <SID>MoveBlockVertically(-v:count1)<CR>
vn <silent> <Plug>MoveBlockHalfPageDown	:<C-u> silent call <SID>MoveBlockVertically( v:count1 * <SID>HalfPageSize())<CR>
vn <silent> <Plug>MoveBlockHalfPageUp		:<C-u> silent call <SID>MoveBlockVertically(-v:count1 * <SID>HalfPageSize())<CR>
vn <silent> <Plug>MoveBlockRight				:<C-u> silent call <SID>MoveBlockHorizontally( v:count1)<CR>
vn <silent> <Plug>MoveBlockLeft				:<C-u> silent call <SID>MoveBlockHorizontally(-v:count1)<CR>

nn <silent> <Plug>MoveLineDown				:<C-u> silent call <SID>MoveLineVertically( v:count1)<CR>
nn <silent> <Plug>MoveLineUp					:<C-u> silent call <SID>MoveLineVertically(-v:count1)<CR>
nn <silent> <Plug>MoveLineHalfPageDown		:<C-u> silent call <SID>MoveLineVertically( v:count1 * <SID>HalfPageSize())<CR>
nn <silent> <Plug>MoveLineHalfPageUp		:<C-u> silent call <SID>MoveLineVertically(-v:count1 * <SID>HalfPageSize())<CR>
nn <silent> <Plug>MoveCharRight				:<C-u> silent call <SID>MoveCharHorizontally( v:count1)<CR>
nn <silent> <Plug>MoveCharLeft				:<C-u> silent call <SID>MoveCharHorizontally(-v:count1)<CR>

