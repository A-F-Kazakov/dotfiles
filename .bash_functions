
pkg()
{
   case $1 in
      update)   sudo apt update ;;
      upgrade)  sudo apt upgrade ;;
      search)   sudo apt search ${@:2} ;;
      install)  sudo apt install ${@:2} ;;
      remove)   sudo apt remove ${@:2} ;;
      detail)   sudo apt show ${@:2} ;;
      *)        echo "pkg: command '$1' is unknown" ;;
   esac
}

backup()
{
   if [ "$#" -gt 1 ] ; then 
      tar --totals -czf ./$(basename ${PWD}).backup.tar.gz "$@"
   else
      if [ -d $1 ] ; then
         tar --totals -czf ./$(basename $1).backup.tar.gz $1
      else
         if [ -f $1 ] ; then
            cp $1 $(basename $1).backup
         else
            echo "'$1' is not a valid file!"
         fi
      fi
   fi
}

extract()
{
   if [ ! -f $1 ] ; then
      echo "'$1' is not a valid file!"
      return
   fi

   case $1 in
      *.tar.bz2)   tar xvjf $1    ;;
      *.tar.gz)    tar xvzf $1    ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xvf $1     ;;
      *.tbz2)      tar xvjf $1    ;;
      *.tgz)       tar xvzf $1    ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "don't know how to extract '$1'..." ;;
   esac
}

