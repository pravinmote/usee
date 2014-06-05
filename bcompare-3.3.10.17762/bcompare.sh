#!/bin/sh

BC_LIB=/usr/lib/beyondcompare
export BC_LIB

BC_PACKAGE_TYPE=archive
export BC_PACKAGE_TYPE

EXEC=$BC_LIB/BCompare

if [ -n "$LD_LIBRARY_PATH" ]; then
export LD_LIBRARY_PATH="$BC_LIB:$LD_LIBRARY_PATH"
else
export LD_LIBRARY_PATH="$BC_LIB"
fi

#check to see if we have all of the shared libraries.
CHECK=`ldd $EXEC | grep "not found" | wc -l`

if [ "$CHECK" -ne  "0" ]; then
   echo Some Shared Libraries were not found
   ldd $EXEC
   exit 1
fi

########################################
# initialize context menu action scripts for KDE 3.5
if [ "$KDE_FULL_SESSION" = "true" ]; then
	if [ "$KDE_SESSION_VERSION" != "4" ]; then
		mkdir -p $HOME/.beyondcompare
		if [ -d "$HOME/.kde/share/apps/konqueror" ]; then
			mkdir -p $HOME/.kde/share/apps/konqueror/servicemenus
		fi
		$BC_LIB/kde_context_menu
	fi
fi

########################################
# execute the program
ARGS="";
while [ "$#" -gt 0 ]; do
	ARGS=$ARGS" '$1'"
	shift 1
done
/bin/bash -c "exec -a $0 $EXEC $ARGS" $0

########################################
# set exit code / wait on existing instance
EXIT=$?
if [ $EXIT = 99 ]; then
	# detected existing instance of Beyond Compare
	EXIT=`cat /tmp/BC3_.$$`
	rm -f /tmp/BC3_.$$
fi
exit $EXIT
