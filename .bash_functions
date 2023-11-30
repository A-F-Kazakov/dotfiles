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
	if [ -z "$2" ]; then
		OUTPUT=.
	else
		OUTPUT="$2"
		if [ ! -d "$2" ]; then
			mkdir -p "$2"
		fi
	fi

	${HOME}/.config/vifm/scripts/extract $OUTPUT $1
}

