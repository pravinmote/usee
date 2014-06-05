#!/bin/bash

# Perform Beyond Compare actions for KDE context menu
#
# Version 1.1.0
# Author: Dave Lerner <http://Dave-L.com/>
# License: GNU General Public License version 2
#
# Requirements:
#   Linux, KDE, BeyondCompare 3
#
# Documentation:
#   Tutorial by Aaron Siego
#   http://developer.kde.org/documentation/tutorials/dot/servicemenus.html
#
#	http://oreilly.com/pub/h/3156
#
# Installation:
#   Review the definitions below, and make any desired changes.
#   Place this script in the location specified by ACTIONFILE below, creating the necessary parent directories.
#   Initialize by running this script without any parameters.
#
# Parameters:
#   $1 - 'left' ($2 specifies left side), 'right' ($2 specifies right side) or '' (initialize)
#   $2 - path to directory or file

# Function to parse .ini files with sections
# e.g.
#
# [my-first-section]
# var1='hoosegow'
#
# [my-second-section]
# var2=192.168.5.5
#
cfg.parser () {
    IFS=$'\n' && ini=( $(<$1) )              # convert to line-array
    ini=( ${ini[*]//;*/} )                   # remove comments
    ini=( ${ini[*]/#[/\}$'\n'cfg.section.} ) # set section prefix
    ini=( ${ini[*]/%]/ \(} )                 # convert text2function (1)
    ini=( ${ini[*]/=/=\( } )                 # convert item to array
    ini=( ${ini[*]/%/ \)} )                  # close array parenthesis
    ini=( ${ini[*]/%\( \)/\(\) \{} )         # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} )              # remove extra parenthesis
    ini[0]=''                                # remove first element
    ini[${#ini[*]} + 1]='}'                  # add the last brace
    eval "$(echo "${ini[*]}")"               # eval the result
}

BC_LIB=/usr/lib/beyondcompare
BC_BIN=/usr/bin
BCEXEFILE="$BC_BIN/bcompare"
ACTIONFILE="$BC_LIB/kde_context_menu"
SELECTEDLEFT="$HOME/.beyondcompare/selectedleft"
SELECTEDCENTER="$HOME/.beyondcompare/selectedcenter"
DESKTOPFILE_SELECTFILE="beyondcompare_selectfile.desktop"
DESKTOPFILE_SELECTDIR="beyondcompare_selectdir.desktop"
DESKTOPFILE_COMPARETO="beyondcompare_compareto.desktop"
DESKTOPFILE_COMPAREUSING="beyondcompare_compareusing.desktop"
DESKTOPFILE_EDIT="beyondcompare_edit.desktop"
DESKTOPFILE_MERGE="beyondcompare_merge.desktop"
DESKTOPFILE_SELECTCENTER="beyondcompare_selectcenter.desktop"
DESKTOPFILE_SYNC="beyondcompare_sync.desktop"

if [ "$KDE_SESSION_VERSION" = "4" ]; then
	if [ -d "$HOME/.kde4" ]; then
		KDEBASE=$HOME/.kde4
	else
		KDEBASE=$HOME/.kde
	fi
	
	rm -f "$KDEBASE/share/kde4/services/ServiceMenus/beyondcompare.desktop"
	DESKTOPFILE_SELECTFILE="$KDEBASE/share/kde4/services/ServiceMenus/$DESKTOPFILE_SELECTFILE"
	DESKTOPFILE_SELECTDIR="$KDEBASE/share/kde4/services/ServiceMenus/$DESKTOPFILE_SELECTDIR"
	DESKTOPFILE_COMPARETO="$KDEBASE/share/kde4/services/ServiceMenus/$DESKTOPFILE_COMPARETO"
	DESKTOPFILE_COMPAREUSING="$KDEBASE/share/kde4/services/ServiceMenus/$DESKTOPFILE_COMPAREUSING"
	DESKTOPFILE_EDIT="$KDEBASE/share/kde4/services/ServiceMenus/$DESKTOPFILE_EDIT"
	DESKTOPFILE_MERGE="$KDEBASE/share/kde4/services/ServiceMenus/$DESKTOPFILE_MERGE"
	DESKTOPFILE_SELECTCENTER="$KDEBASE/share/kde4/services/ServiceMenus/$DESKTOPFILE_SELECTCENTER"
	DESKTOPFILE_SYNC="$KDEBASE/share/kde4/services/ServiceMenus/$DESKTOPFILE_SYNC"
	TYPE="Type=Service"
	SERVICETYPES="ServiceTypes=KonqPopupMenu/Plugin,"
else
	rm -f "$HOME/.kde/share/apps/konqueror/servicemenus/beyondcompare.desktop"
	DESKTOPFILE_SELECTFILE="$HOME/.kde/share/apps/konqueror/servicemenus/$DESKTOPFILE_SELECTFILE"
	DESKTOPFILE_SELECTDIR="$HOME/.kde/share/apps/konqueror/servicemenus/$DESKTOPFILE_SELECTDIR"
	DESKTOPFILE_COMPARETO="$HOME/.kde/share/apps/konqueror/servicemenus/$DESKTOPFILE_COMPARETO"
	DESKTOPFILE_COMPAREUSING="$HOME/.kde/share/apps/konqueror/servicemenus/$DESKTOPFILE_COMPAREUSING"
	DESKTOPFILE_EDIT="$HOME/.kde/share/apps/konqueror/servicemenus/$DESKTOPFILE_EDIT"
	DESKTOPFILE_MERGE="$HOME/.kde/share/apps/konqueror/servicemenus/$DESKTOPFILE_MERGE"
	DESKTOPFILE_SELECTCENTER="$HOME/.kde/share/apps/konqueror/servicemenus/$DESKTOPFILE_SELECTCENTER"
	DESKTOPFILE_SYNC="$HOME/.kde/share/apps/konqueror/servicemenus/$DESKTOPFILE_SYNC"
	TYPE=""
	SERVICETYPES="ServiceTypes="
fi

if [ -f $HOME/.beyondcompare/menu.ini ]; then
	CONFIGFILE=$HOME/.beyondcompare/menu.ini
else
	CONFIGFILE=$BC_LIB/menu.ini
fi

cfg.parser $CONFIGFILE
cfg.section.ContextMenus

# Not enabled.  Clear out all the files.  They will be regenerated
# when BcShellEx is enabled.
if [ "$Enabled" = "False" ]; then
	rm -f $DESKTOPFILE_SELECTFILE
	rm -f $DESKTOPFILE_SELECTDIR
	rm -f $DESKTOPFILE_COMPARETO
	rm -f $DESKTOPFILE_COMPAREUSING
	rm -f $DESKTOPFILE_EDIT
	rm -f $DESKTOPFILE_MERGE
	rm -f $DESKTOPFILE_SELECTCENTER
	rm -f $DESKTOPFILE_SYNC
	rm -f $SELECTEDLEFT
	rm -f $SELECTEDCENTER
	exit
fi

# If enabled then set up submenus based on app selections
BCSUBMENU='X-KDE-Submenu=&Beyond Compare'

if [ "$Compare" = 2 ]; then
	COMPARESUBMENU=$BCSUBMENU
fi

if [ "$CompareUsing" = 1 ]; then
	COMPAREUSINGSUBMENU='X-KDE-Submenu=Compare Using'
	COMPAREUSINGTEXT=""
elif [ "$CompareUsing" = 2 ]; then
	COMPAREUSINGSUBMENU=$BCSUBMENU
	COMPAREUSINGTEXT="Compare using "
fi

if [ "$Edit" = 2 ]; then
	EDITSUBMENU=$BCSUBMENU
fi

if [ "$Merge" = 2 ]; then
	MERGESUBMENU=$BCSUBMENU
fi

if [ "$Sync" = 2 ]; then
	SYNCSUBMENU=$BCSUBMENU
fi


# Now start with Base offerings

# Select Left file/folder
if [ "$Compare" = 0 ]; then
	rm -f $DESKTOPFILE_SELECTFILE
	rm -f $DESKTOPFILE_SELECTDIR
	rm -f $DESKTOPFILE_COMPARETO
else
	# Select File
	MIME="all/allfiles"
	cat <<-zz_endoftext >$DESKTOPFILE_SELECTFILE
		[Desktop Entry]
		$TYPE
		$SERVICETYPES$MIME
		X-KDE-Priority=TopLevel
		$COMPARESUBMENU
		Actions=SelectLeft

		[Desktop Action SelectLeft]
		Name=Select Left File
		Exec=$ACTIONFILE left %f
		Icon=bcomparehalf32

	zz_endoftext

	# Select Folder
	MIME="inode/directory"
	cat <<-zz_endoftext >$DESKTOPFILE_SELECTDIR
		[Desktop Entry]
		$TYPE
		$SERVICETYPES$MIME
		X-KDE-Priority=TopLevel
		$COMPARESUBMENU
		Actions=SelectLeft

		[Desktop Action SelectLeft]
		Name=Select Left Folder
		Exec=$ACTIONFILE left %f
		Icon=bcomparehalf32
	zz_endoftext
fi

# Edit with BC (file only)
if [ "$Edit" = 0 ]; then
	rm -f $DESKTOPFILE_EDIT
else
	MIME="all/allfiles"
	cat <<-zz_endoftext >$DESKTOPFILE_EDIT
		[Desktop Entry]
		$TYPE
		$SERVICETYPES$MIME
		X-KDE-Priority=TopLevel
		$EDITSUBMENU
		Actions=EditWithBC

		[Desktop Action EditWithBC]
		Name=Edit with Beyond Compare
		Exec=$BCEXEFILE -edit %f
		Icon=bcomparefull32.png

	zz_endoftext
fi

# Base set up now actions for when left or right file is selected.
case "$1" in

	'left')  # Left file was selected.

		# Clear out all left generated files and make them fresh.  This
		# handles switching from file to dir or vice versa
		rm -f $DESKTOPFILE_COMPARETO
		rm -f $DESKTOPFILE_COMPAREUSING
		rm -f $DESKTOPFILE_MERGE
		rm -f $DESKTOPFILE_SELECTCENTER
		rm -f $DESKTOPFILE_SYNC
		if [ -d $2 ]; then
			rm -f $SELECTEDCENTER
		fi

		# Save left file path/name and center if it exists
		if [ "$3" = "" ]; then
			echo "$2" >$SELECTEDLEFT
		else
			echo "$3" >$SELECTEDCENTER
		fi

		# Set up mime type to match left file.  The following actions only 
		# happen for similar left/right
		if [ -d $2 ]; then 
			MIME=inode/directory
		else
			MIME=all/allfiles
		fi
	
		# 'Compare To' menu item (goes in same submenu as selectfile/selectdir
		cat <<-zz_endoftext >$DESKTOPFILE_COMPARETO
			[Desktop Entry]
			$TYPE
			$SERVICETYPES$MIME
			X-KDE-Priority=TopLevel
			$COMPARESUBMENU
			Actions=CompareTo

			[Desktop Action CompareTo]
			Name=Compare to "$2"
			Exec=$ACTIONFILE right %f
			Icon=bcomparefull32

		zz_endoftext

		# Set up 'Compare Using' menu
		if [ $CompareUsing != 0 ]  && ! [ -d $2 ]; then
			# File Options

			ACTIONLIST="${Viewers//' '}"     # Remove spaces from list
			ACTIONLIST="${ACTIONLIST//,/;}"  # Convert ',' delimiter to ';'
			
			cat <<-zz_endoftext >$DESKTOPFILE_COMPAREUSING
				[Desktop Entry]
				$TYPE
				$SERVICETYPES$MIME
				X-KDE-Priority=TopLevel
				$COMPAREUSINGSUBMENU
				Actions=$ACTIONLIST

				zz_endoftext

			for i in $(echo $Viewers | tr "," "\n")
			do
				MENUACTION="${i//' '}"
				cat <<-zz_endoftext >>$DESKTOPFILE_COMPAREUSING
				[Desktop Action $MENUACTION]
				Name=$COMPAREUSINGTEXT$i
				Exec=$ACTIONFILE rightfv "$i" %f
				Icon=bcomparefull32

				zz_endoftext
			done 
		fi

		# Set up 'Merge with' menu
		if [ "$Merge" = 0 ]; then
			rm -f $SELECTEDCENTER
		elif ! [ -d $2 ]; then
			# File Options (only file can Merge)

			if [ -e "$SELECTEDCENTER" ]; then
				MERGEFILE=`cat $SELECTEDCENTER`
				MERGE="$2"",""$MERGEFILE"
			else
				MERGE="$2"
			fi

			# 'Merge With'
			cat <<-zz_endoftext >$DESKTOPFILE_MERGE
				[Desktop Entry]
				$TYPE
				$SERVICETYPES$MIME
				X-KDE-Priority=TopLevel
				$MERGESUBMENU
				Actions=MergeFile

				[Desktop Action MergeFile]
				Name=Merge with "$MERGE"
				Exec=$ACTIONFILE rightmerge %f
				Icon=bcomparefull32

			zz_endoftext

			# File Options (only file can Merge)
			cat <<-zz_endoftext >$DESKTOPFILE_SELECTCENTER
				[Desktop Entry]
				$TYPE
				$SERVICETYPES$MIME
				X-KDE-Priority=TopLevel
				$MERGESUBMENU
				Actions=SelectCenter

				[Desktop Action SelectCenter]
				Name=Select Center File
				Exec=$ACTIONFILE left "$2" %f
				Icon=bcomparehalf32

			zz_endoftext
		fi

		# Set up 'Sync to' menu
		if [ "$Sync" != 0 ] && [ -d $2 ]; then
			# Directory Options (only file can sync)
			cat <<-zz_endoftext >$DESKTOPFILE_SYNC
				[Desktop Entry]
				$TYPE
				$SERVICETYPES$MIME
				X-KDE-Priority=TopLevel
				$SYNCSUBMENU
				Actions=FolderSync
			
				[Desktop Action FolderSync]
				Name=Sync with "$2"
				Exec=$ACTIONFILE rightsync %f
				Icon=bcomparefull32

			zz_endoftext
		fi

		;;

	right*)
		rm -f $DESKTOPFILE_COMPARETO
		rm -f $DESKTOPFILE_COMPAREUSING
		rm -f $DESKTOPFILE_MERGE
		rm -f $DESKTOPFILE_SELECTCENTER
		rm -f $DEKSTOPFILE_SYNC

		if [ -e "$SELECTEDLEFT" ]; then
			LEFTSIDE=`cat $SELECTEDLEFT`
			rm -f $SELECTEDLEFT
		else
			LEFTSIDE=''
		fi

		if [ -e "$SELECTEDCENTER" ]; then
			CENTER=`cat $SELECTEDCENTER`
			rm -f $SELECTEDCENTER
		else
			CENTER=''
		fi

		if [ -n "$LEFTSIDE" ]; then
			case "$1" in
				right)
					"$BCEXEFILE" "$LEFTSIDE" "$2"
					;;
				rightfolder)
					"$BCEXEFILE" "$LEFTSIDE" "$2"
					;;
				rightsync)
					"$BCEXEFILE" -sync "$LEFTSIDE" "$2"
					;;
				rightmerge)
					"$BCEXEFILE" -fv="Text Merge" "$LEFTSIDE" "$2" "$CENTER"
					;;
				rightfv)
					"$BCEXEFILE" -fv="$2" "$LEFTSIDE" "$3"
					;;
				*)
					"$BCEXEFILE" "$LEFTSIDE" "$2"
					;;
			esac
		fi

		;;

	*)
		# Restore to Base state
		rm -f $DESKTOPFILE_COMPARETO
		rm -f $DESKTOPFILE_COMPAREUSING
		rm -f $DESKTOPFILE_MERGE
		rm -f $DESKTOPFILE_SELECTCENTER
		rm -f $DEKSTOPFILE_SYNC
		rm -f $SELECTEDLEFT
		rm -f $SELECTEDCENTER

		;;

esac

if [ "$KDE_SESSION_VERSION" = "4" ]; then
	kbuildsycoca4 &> /dev/null
fi
