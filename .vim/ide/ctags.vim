if exists('g:project_ctags_loaded') | finish | en | let g:project_ctags_loaded = 1

let g:project.tags_path = g:project.folder . '/tags'

fu! CtagsCallback(...)
	echom "Ctags finished"
endf

fu! CtagsInitiate()
	if executable("ctags")
		let cmd = 'ctags -R -f ' . g:project.tags_path . '--exclude=.git -- exclude=.ide --c++-kinds=+p --fields=+iaS --extra=+q /usr/include'
		let l:job = job_start(cmd, {'callback': 'CtagsCallback'})
	en
endf

set tags=g:project.tags_path;/

exe CtagsInitiate()
