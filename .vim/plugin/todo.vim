" MIT License
"
" Copyright (c) 2020 Alexander Serebryakov (alex.serebr@gmail.com)
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.


fu! VimTodoListsInit()
	set filetype=todo

  " Keep the same indent as on the current line or always makes a root item
	if !exists('g:VimTodoListsKeepSameIndent')
		let g:VimTodoListsKeepSameIndent = 1
	en

	if !exists('g:VimTodoListsDatesEnabled')
		let g:VimTodoListsDatesEnabled = 0
	en

	if !exists('g:VimTodoListsDatesFormat')
		let g:VimTodoListsDatesFormat = "%X, %d %b %Y"
	en

	setlo tabstop=2
	setlo shiftwidth=2 expandtab
	setlo cursorline
	setlo noautoindent

	call VimTodoListsInitializeTokens()
	call VimTodoListsInitializeSyntax()

	if exists('g:VimTodoListsCustomKeyMapper')
		try
			call call(g:VimTodoListsCustomKeyMapper, [])
		catch
			echo 'VimTodoLists: Error in custom key mapper. Falling back to default mappings'
		call VimTodoListsSetItemMode()
		endtry
	el
		call VimTodoListsSetItemMode()
	en
endfu

fu! VimTodoListsInitializeTokens()
	let g:VimTodoListsEscaped = '*[]'

	if !exists('g:VimTodoListsUndoneItem')
		let g:VimTodoListsUndoneItem = '- [ ]'
	en

	if !exists('g:VimTodoListsDoneItem')
		let g:VimTodoListsDoneItem = '- [X]'
	en

	let g:VimTodoListsDoneItemEscaped = escape(g:VimTodoListsDoneItem, g:VimTodoListsEscaped)
	let g:VimTodoListsUndoneItemEscaped = escape(g:VimTodoListsUndoneItem, g:VimTodoListsEscaped)
endfu

fu! VimTodoListsInitializeSyntax()
	exe("syntax match vimTodoListsDone '^\\s*".g:VimTodoListsDoneItemEscaped.".*'")
	exe("syntax match vimTodoListsNormal '^\\s*".g:VimTodoListsUndoneItemEscaped.".*'")
	exe("syntax match vimTodoListsImportant '^\\s*".g:VimTodoListsUndoneItemEscaped."\\s*!.*'")

	hi link vimTodoListsDone Comment
	hi link vimTodoListsNormal Normal
	hi link vimTodoListsImportant Underlined
endfu

fu! VimTodoListsSetItemDone(lineno)
	let l:line = getline(a:lineno)
	call setline(a:lineno, substitute(l:line, '^\(\s*\)'.g:VimTodoListsUndoneItemEscaped, '\1'.g:VimTodoListsDoneItem, ''))
endfu

fu! VimTodoListsSetItemNotDone(lineno)
  let l:line = getline(a:lineno)
  call setline(a:lineno, substitute(l:line, '^\(\s*\)'.g:VimTodoListsDoneItemEscaped, '\1'.g:VimTodoListsUndoneItem, ''))
endfu

fu! VimTodoListsLineIsItem(line)
	if match(a:line, '^\s*\('.g:VimTodoListsDoneItemEscaped.'\|'.g:VimTodoListsUndoneItemEscaped.'\).*') != -1
		return 1
	en
	return 0
endfu

fu! VimTodoListsItemIsNotDone(line)
	if match(a:line, '^\s*'.g:VimTodoListsUndoneItemEscaped.'.*') != -1
		return 1
	en
	return 0
endfu

fu! VimTodoListsItemIsDone(line)
	if match(a:line, '^\s*'.g:VimTodoListsDoneItemEscaped.'.*') != -1
		return 1
	en
	return 0
endfu

fu! VimTodoListsBrotherItemInRange(line, range)
	let l:indent = VimTodoListsCountLeadingSpaces(getline(a:line))
	let l:result = -1

	for current_line in a:range
		if VimTodoListsLineIsItem(getline(current_line)) == 0
			break
		en

		if (VimTodoListsCountLeadingSpaces(getline(current_line)) == l:indent)
			let l:result = current_line
			break
		elseif (VimTodoListsCountLeadingSpaces(getline(current_line)) > l:indent)
			continue
		el
			break
		en
	endfor
	return l:result
endfu

fu! VimTodoListsFindTargetPositionUp(lineno)
	let l:range = range(a:lineno, 1, -1)
	let l:candidate_line = VimTodoListsBrotherItemInRange(a:lineno, l:range)
	let l:target_line = -1

	wh l:candidate_line != -1
		let l:target_line = l:candidate_line
		let l:candidate_line = VimTodoListsBrotherItemInRange(l:candidate_line, range(l:candidate_line - 1, 1, -1))
		if l:candidate_line != -1 && VimTodoListsItemIsNotDone(getline(l:candidate_line)) == 1
			let l:target_line = l:candidate_line
			break
		en
	endw

	return VimTodoListsFindLastChild(l:target_line)
endfu


" Finds the insert position below the item
fu! VimTodoListsFindTargetPositionDown(line)
	let l:range = range(a:line, line('$'))
	let l:candidate_line = VimTodoListsBrotherItemInRange(a:line, l:range)
	let l:target_line = -1

	wh l:candidate_line != -1
		let l:target_line = l:candidate_line
		let l:candidate_line = VimTodoListsBrotherItemInRange(l:candidate_line, range(l:candidate_line + 1, line('$')))
	endw

	return VimTodoListsFindLastChild(l:target_line)
endfu

fu! VimTodoListsMoveSubtree(lineno, position)
	if exists('g:VimTodoListsMoveItems')
		if g:VimTodoListsMoveItems != 1
			return
		en
	en

	let l:subtree_length = VimTodoListsFindLastChild(a:lineno) - a:lineno + 1

	let l:cursor_pos = getcurpos()
	call cursor(a:lineno, l:cursor_pos[4])

	let l:cursor_pos[1] = a:lineno

	exe 'normal! ' . l:subtree_length . 'Y'
	call cursor(a:position, l:cursor_pos[4])

	if a:lineno < a:position
		exe 'normal! p'
		call cursor(l:cursor_pos[1], l:cursor_pos[4])
	el
		let l:indent = VimTodoListsCountLeadingSpaces(getline(a:lineno))

		if VimTodoListsItemIsDone(getline(a:position)) && (VimTodoListsCountLeadingSpaces(getline(a:position)) == l:indent)
			exe 'normal! P'
		el
			exe 'normal! p'
		en

		call cursor(l:cursor_pos[1] + l:subtree_length, l:cursor_pos[4])
	en

	exe 'normal! ' . l:subtree_length . 'dd'
endfu

fu! VimTodoListsMoveSubtreeUp(lineno)
	let l:move_position = VimTodoListsFindTargetPositionUp(a:lineno)

	if l:move_position != -1
		call VimTodoListsMoveSubtree(a:lineno, l:move_position)
	en
endfu

fu! VimTodoListsMoveSubtreeDown(lineno)
	let l:move_position = VimTodoListsFindTargetPositionDown(a:lineno)

	if l:move_position != -1
		call VimTodoListsMoveSubtree(a:lineno, l:move_position)
	en
endfu

fu! VimTodoListsCountLeadingSpaces(line)
	return (strlen(a:line) - strlen(substitute(a:line, '^\s*', '', '')))
endfu

fu! VimTodoListsFindParent(lineno)
	let l:indent = VimTodoListsCountLeadingSpaces(getline(a:lineno))
	let l:parent_lineno = -1

	for current_line in range(a:lineno, 1, -1)
		if (VimTodoListsLineIsItem(getline(current_line)) && VimTodoListsCountLeadingSpaces(getline(current_line)) < l:indent)
			let l:parent_lineno = current_line
			break
		en
	endfor

	return l:parent_lineno
endfu

fu! VimTodoListsFindLastChild(lineno)
	let l:indent = VimTodoListsCountLeadingSpaces(getline(a:lineno))
	let l:last_child_lineno = a:lineno

	if a:lineno == line('$')
		return l:last_child_lineno
	en

	for current_line in range (a:lineno + 1, line('$'))
		if (VimTodoListsLineIsItem(getline(current_line)) && VimTodoListsCountLeadingSpaces(getline(current_line)) > l:indent)
			let l:last_child_lineno = current_line
		el
			break
		en
	endfor

	return l:last_child_lineno
endfu

fu! VimTodoListsUpdateParent(lineno)
	let l:parent_lineno = VimTodoListsFindParent(a:lineno)

	if l:parent_lineno == -1
		return
	en

	let l:last_child_lineno = VimTodoListsFindLastChild(l:parent_lineno)

	if l:last_child_lineno == l:parent_lineno
		return
	en

	for current_line in range(l:parent_lineno + 1, l:last_child_lineno)
		if VimTodoListsItemIsNotDone(getline(current_line)) == 1
			call VimTodoListsSetItemNotDone(l:parent_lineno)
			call VimTodoListsMoveSubtreeUp(l:parent_lineno)
			call VimTodoListsUpdateParent(l:parent_lineno)
			return
		en
	endfor

	call VimTodoListsSetItemDone(l:parent_lineno)
	call VimTodoListsMoveSubtreeDown(l:parent_lineno)
	call VimTodoListsUpdateParent(l:parent_lineno)
endfu

fu! VimTodoListsForEachChild(lineno, fu)
	let l:last_child_lineno = VimTodoListsFindLastChild(a:lineno)

	for current_line in range(a:lineno, l:last_child_lineno)
		call call(a:fu, [current_line])
	endfor
endfu

fu! VimTodoListsSetNormalMode()
	nunmap <buffer> o
	nunmap <buffer> O
	nunmap <buffer> j
	nunmap <buffer> k
	iunmap <buffer> <CR>
	iunmap <buffer> <kEnter>
	nnoremap <buffer><silent> <Space> :VimTodoListsToggleItem<CR>
	vnoremap <buffer><silent> <Space> :'<,'>VimTodoListsToggleItem<CR>
	noremap <buffer><silent> <leader>e :silent call VimTodoListsSetItemMode()<CR>
endfu

fu! VimTodoListsSetItemMode()
	nnoremap <buffer><silent> o :VimTodoListsCreateNewItemBelow<CR>
	nnoremap <buffer><silent> O :VimTodoListsCreateNewItemAbove<CR>
	nnoremap <buffer><silent> j :VimTodoListsGoToNextItem<CR>
	nnoremap <buffer><silent> k :VimTodoListsGoToPreviousItem<CR>
	nnoremap <buffer><silent> <Space> :VimTodoListsToggleItem<CR>
	vnoremap <buffer><silent> <Space> :VimTodoListsToggleItem<CR>
	inoremap <buffer><silent> <CR> <ESC>:call VimTodoListsAppendDate()<CR>:silent call VimTodoListsCreateNewItemBelow()<CR>
	inoremap <buffer><silent> <kEnter> <ESC>:call VimTodoListsAppendDate()<CR>A<CR><ESC>:VimTodoListsCreateNewItem<CR>
	noremap <buffer><silent> <leader>e :silent call VimTodoListsSetNormalMode()<CR>
	nnoremap <buffer><silent> <Tab> :VimTodoListsIncreaseIndent<CR>
	nnoremap <buffer><silent> <S-Tab> :VimTodoListsDecreaseIndent<CR>
	vnoremap <buffer><silent> <Tab> :VimTodoListsIncreaseIndent<CR>
	vnoremap <buffer><silent> <S-Tab> :VimTodoListsDecreaseIndent<CR>
	inoremap <buffer><silent> <Tab> <ESC>:VimTodoListsIncreaseIndent<CR>A
	inoremap <buffer><silent> <S-Tab> <ESC>:VimTodoListsDecreaseIndent<CR>A
endfu

fu! VimTodoListsAppendDate()
	if(g:VimTodoListsDatesEnabled == 1)
		let l:date = strftime(g:VimTodoListsDatesFormat)
		exe "s/$/ (" . l:date . ")"
	en
endfu

fu! VimTodoListsCreateNewItemAbove()
	exe "normal! O" . VimTodoListsIdent() . g:VimTodoListsUndoneItem . " "
	startinsert!
endfu

fu! VimTodoListsCreateNewItemBelow()
	exe "normal! o" . VimTodoListsIdent() . g:VimTodoListsUndoneItem . " "
	startinsert!
endfu

fu! VimTodoListsIdent()
	if (g:VimTodoListsKeepSameIndent == 1)
		let l:indentline = join(map(range(1,indent(line('.'))), '" "'), '')
	el
		let l:indentline = ""
	en

	return l:indentline
endfu

fu! VimTodoListsCreateNewItem()
	exe "normal! 0i" . g:VimTodoListsUndoneItem . " "
	startinsert!
endfu

fu! VimTodoListsGoToNextItem()
	normal! $
	silent! exec '/^\s*\(' . g:VimTodoListsUndoneItemEscaped . '\|' . g:VimTodoListsDoneItemEscaped . '\)'
	silent! exec 'noh'
	normal! 6l
endfu

fu! VimTodoListsGoToPreviousItem()
	normal! 0
	silent! exec '?^\s*\(' . g:VimTodoListsUndoneItemEscaped . '\|' . g:VimTodoListsDoneItemEscaped . '\)'
	silent! exec 'noh'
	normal! 6l
endfu

fu! VimTodoListsToggleItem()
	let l:line = getline('.')
	let l:lineno = line('.')
	let l:cursor_pos = getcurpos()

	if VimTodoListsItemIsNotDone(l:line) == 1
		call VimTodoListsForEachChild(l:lineno, 'VimTodoListsSetItemDone')
		call VimTodoListsMoveSubtreeDown(l:lineno)
	elseif VimTodoListsItemIsDone(l:line) == 1
		call VimTodoListsForEachChild(l:lineno, 'VimTodoListsSetItemNotDone')
		call VimTodoListsMoveSubtreeUp(l:lineno)
	en

	call VimTodoListsUpdateParent(l:lineno)
	call cursor(l:cursor_pos[1], l:cursor_pos[4])
endfu

fu! VimTodoListsIncreaseIndent()
	normal! >>6l
endfu

fu! VimTodoListsDecreaseIndent()
	normal! <<6l
endfu

if !exists('g:vimtodolists_plugin')
	let g:vimtodolists_plugin = 1

	if exists('vimtodolists_auto_commands')
		echoerr 'VimTodoLists: vimtodolists_auto_commands group already exists'
		exit
	en

	aug vimtodolists_auto_commands
		au!
		au BufRead,BufNewFile *.todo.md call VimTodoListsInit()
		au FileType todo call VimTodoListsInit()
	aug end

	com! VimTodoListsCreateNewItemAbove silent call VimTodoListsCreateNewItemAbove()
	com! VimTodoListsCreateNewItemBelow silent call VimTodoListsCreateNewItemBelow()
	com! VimTodoListsCreateNewItem silent call VimTodoListsCreateNewItem()
	com! VimTodoListsGoToNextItem silent call VimTodoListsGoToNextItem()
	com! VimTodoListsGoToPreviousItem silent call VimTodoListsGoToPreviousItem()
	com! -range VimTodoListsToggleItem silent <line1>,<line2>call VimTodoListsToggleItem()
	com! -range VimTodoListsIncreaseIndent silent <line1>,<line2>call VimTodoListsIncreaseIndent()
	com! -range VimTodoListsDecreaseIndent silent <line1>,<line2>call VimTodoListsDecreaseIndent()
en
