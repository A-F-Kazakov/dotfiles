" configuration
if !exists('g:project_config_dir')
	let g:project_config_dir = ".ide"
en

if !exists('g:project_build_dir')
	let g:project_build_dir = g:project_config_dir . '/build'
en

if !exists('g:project_install_dir')
	let g:project_install_dir = g:project_config_dir . '/install'
en

ru! ide/session.vim

if filereadable('.clang_format')
	ru! ide/clang_format.vim
en

if filereadable('CMakeLists.txt')
	ru! ide/cmake.vim
en

