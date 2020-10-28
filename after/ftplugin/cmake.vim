setl fdm=manual	
setl noic		
setl list	
setl lcs=tab:·\ ,trail:-

if filereadable(".ide/config")
	so .ide/config
en
