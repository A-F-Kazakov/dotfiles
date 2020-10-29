" Vim indent file
" Language:     CMake (ft=cmake)
" Author:       Andy Cedilnik <andy.cedilnik@kitware.com>
" Maintainer:   Dimitri Merejkowsky <d.merej@gmail.com>
" Former Maintainer: Karthik Krishnan <karthik.krishnan@kitware.com>
" Last Change:  2017 Aug 30
"
" Licence:      The CMake license applies to this file. See
"               https://cmake.org/licensing
"               This implies that distribution with Vim is allowed

if exists("b:did_indent")
  finish
en
let b:did_indent = 1

let s:keepcpo= &cpo
set cpo&vim

setl indentexpr=CMakeGetIndent(v:lnum)
setl indentkeys+==en(,ENDFOREACH(,ENDMACRO(,ELSE(,ELSEIF(,ENDWHILE(

if exists("*CMakeGetIndent")
  finish
en

fu! CMakeGetIndent(lnum)
  let this_line = getline(a:lnum)

  let lnum = a:lnum
  let lnum = prevnonblank(lnum - 1)
  let previous_line = getline(lnum)

  if lnum == 0
    return 0
  en

  let ind = indent(lnum)

  let or = '\|'
  let cmake_regex_comment = '#.*'
  let cmake_regex_identifier = '[A-Za-z][A-Za-z0-9_]*'
  let cmake_regex_quoted = '"\([^"\\]\|\\.\)*"'
  let cmake_regex_arguments = '\(' . cmake_regex_quoted .
                    \       or . '\$(' . cmake_regex_identifier . ')' .
                    \       or . '[^()\\#"]' . or . '\\.' . '\)*'

  let cmake_indent_comment_line = '^\s*' . cmake_regex_comment
  let cmake_indent_blank_regex = '^\s*$'
  let cmake_indent_open_regex = '^\s*' . cmake_regex_identifier .
                    \           '\s*(' . cmake_regex_arguments .
                    \           '\(' . cmake_regex_comment . '\)\?$'

  let cmake_indent_close_regex = '^' . cmake_regex_arguments .
                    \            ')\s*' .
                    \            '\(' . cmake_regex_comment . '\)\?$'

  let cmake_indent_begin_regex = '^\s*\(IF\|MACRO\|FOREACH\|ELSE\|ELSEIF\|WHILE\|FUNCTION\)\s*('
  let cmake_indent_end_regex = '^\s*\(ENDIF\|ENDFOREACH\|ENDMACRO\|ELSE\|ELSEIF\|ENDWHILE\|ENDFUNCTION\)\s*('

  if previous_line =~? cmake_indent_comment_line
    let ind = ind
  el
    if previous_line =~? cmake_indent_begin_regex
      let ind = ind + shiftwidth()
    en
    if previous_line =~? cmake_indent_open_regex
      let ind = ind + shiftwidth()
    en
  en

  if this_line =~? cmake_indent_end_regex
    let ind = ind - shiftwidth()
  en
  if previous_line =~? cmake_indent_close_regex
    let ind = ind - shiftwidth()
  en

  return ind
endf

let &cpo = s:keepcpo
unlet s:keepcpo
