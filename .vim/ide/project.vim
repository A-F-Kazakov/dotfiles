if exists("g:project") | finish | en

" configuration
let g:project = {}
let g:project.source_dir = expand("%:p:h")
let g:project.folder = '.ide'
let g:project.config = g:project.folder . '/config'
let g:project.build_dir = g:project.folder . '/build'
let g:project.install_dir = g:project.folder . '/install'
let g:project.build_type = 'Debug'

if exists('g:project_build_dir')
	let g:project.build_dir = g:project_build_dir
en

if exists('g:project_install_dir')
	let g:project.install_dir = g:project_install_dir
en

if exists('g:project_build_type')
	let g:project.build_type = g:project_build_type
en

com ProjectConfig :exec "edit +setf\\ vim " . g:project.config

 ru! ide/session.vim
 ru! ide/ctags.vim
 ru! ide/tagbar.vim

if filereadable('.clang_format')
	" ru! ide/clang_format.vim
en

if filereadable('CMakeLists.txt')
	" ru! ide/cmake.vim

	" com ProjectConfigure CMakeConfigure
	" com ProjectClean CMakeClean
	" com ProjectBuild CMakeBuild
	" com ProjectInstall CMakeInstall
en

"echom g:project
