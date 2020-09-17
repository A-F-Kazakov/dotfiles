if exists('g:loaded_statusline')
	finish
en
let g:loaded_statusline = 1

set stl=%#StatusLineNormal#%{(mode()=='n')?'\ \ N\ ':''}
set stl+=%#StatusLineInsert#%{(mode()=='i')?'\ \ I\ ':''}
set stl+=%#StatusLineReplace#%{(mode()=='R')?'\ \ R\ ':''}
set stl+=%#StatusLineVisual#%{(mode()=='v')?'\ \ V\ ':''}%*
set stl+=\ %<%f%#StatusLineAlert#%{&modified?'\ +':''}%{&readonly?'\ !':''}\ 
set stl+=%#StatusLineDelimeter#%{'│'}%*%=
set stl+=%#StatusLineDelimeter#%{'│'}%*
set stl+=\ %{&filetype}\ 
set stl+=%#StatusLineDelimeter#%{'│'}%*
set stl+=\ %{&fileencoding?&fileencoding:&encoding}\ (%{&fileformat})\ 
set stl+=%#StatusLineDelimeter#%{'│'}%*
set stl+=\ %v:%l/%L\ 
