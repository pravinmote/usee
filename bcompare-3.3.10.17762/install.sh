#!/bin/bash

workdir=`dirname $0`
cd $workdir

# Defaults
if [ $(id -u) = "0" ]; then
	PREFIX='/usr'
else #not root
	PREFIX=$HOME
fi
installverify=yes
BC='beyondcompare'
BCICON='bcompare.png'
BC_CONTEXT_FULL='bcomparefull32.png'
BC_CONTEXT_HALF='bcomparehalf32.png'

########################################
# Help information
########################################
usage()
{
	cat<<EOF
Usage: install.sh [OPTION]

Known values for OPTION are:

  --prefix[=DIR]		change install prefix [default $PREFIX]
						  common prefixes are for example:
						  /usr, /usr/local, /opt/beyondcompare, and \$HOME.
						  Files will be installed in '\$PREFIX/bin' and
						  '\$PREFIX/lib/beyondcompare'.
  --help				prints out this message
EOF
	exit $1
}


########################################
# Handle command line arguments
########################################
while test $# -gt 0 ; do
	case "$1" in
		-*=*) optarg=`echo "$1" | sed 's/[-_a-zA-Z0-9]*=//'` ;;
		*) optarg= ;;
	esac

	case $1 in
		--prefix=*)
			PREFIX=$optarg
			installverify=no
			;;
		--help)
			usage 1 1>&2
			;;
		*)
			usage 1 1>&2
			;;
	esac
	shift
done

########################################
# Query for architecture and then distill
# it down to i386 or amd64
########################################
MACH=`uname -m`
NUM=`expr match "$MACH" 'i[0-9]86'`
if [[ $NUM -ge 4 ]]; then
	MACH_ARCH=i386
else
	MACH_ARCH=amd64
fi

########################################
# Installation
########################################

if [ $installverify = "yes" ]; then
	echo
	read -p "install prefix? [$PREFIX] " udir
	if [ $udir ]; then
		PREFIX=$udir
	fi
fi

if [ ! -d "$PREFIX" ]; then
	echo "install.sh: $PREFIX does not exist"
	exit 1
elif [ ! -w "$PREFIX" ]; then
	echo "install.sh: $LOGNAME does not have write permissions to $PREFIX"
	exit 1
fi

BC_BIN=${PREFIX}/bin
BC_LIB=${PREFIX}/lib/${BC}
##
# if /lib64 exists and is a link then we are on a Debian type 64bit system
# that places 32bit libs in /lib32 and /usr/lib32
##
if [ -h /lib64 ]; then
	BC_LIB=${PREFIX}/lib32/${BC}
fi
if [ "$RPM_ARCH" = "" ]; then
	BC_PACKAGE_TYPE=archive
else
	BC_PACKAGE_TYPE=rpm
fi

##
# insert these variables in the other scripts
##
sed -i "s|^\(BC_LIB=\).*|\1$BC_LIB|" bcompare.sh
sed -i "s|^\(BC_PACKAGE_TYPE=\).*|\1$BC_PACKAGE_TYPE|" bcompare.sh
sed -i "s|^\(BC_LIB=\).*|\1$BC_LIB|" kde_context_menu.sh
sed -i "s|^\(BC_BIN=\).*|\1$BC_BIN|" kde_context_menu.sh
sed -i "s|^\(BC_LIB=\).*|\1$BC_LIB|" uninstall.sh
sed -i "s|^\(BC_BIN=\).*|\1$BC_BIN|" uninstall.sh
sed -i "s|^\(PREFIX=\).*|\1$PREFIX|" uninstall.sh


##
# Copy the files
##
mkdir -p ${BC_BIN}
mkdir -p ${BC_LIB}
mkdir -p ${BC_LIB}/help
mkdir -p ${BC_LIB}/ext

install bcompare.sh						$BC_BIN/bcompare
install BCompare						$BC_LIB
install libqtc.so.1						$BC_LIB
install libqt-mt.so.3					$BC_LIB
install qtrc							$BC_LIB
install kde_context_menu.sh				$BC_LIB/kde_context_menu
install help/*							$BC_LIB/help/
install RPM-GPG-KEY-scootersoftware		$BC_LIB
install scootersoftware.repo			$BC_LIB
install ext/*							$BC_LIB/ext/
install README							$BC_LIB

if [ -f ../BC3Key.txt ]; then
	cp ../BC3Key.txt $BC_LIB
	chmod a+r $BC_LIB/BC3Key.txt
elif [ -f BC3Key.txt ]; then
	cp BC3Key.txt $BC_LIB
	chmod a+r $BC_LIB/BC3Key.txt
fi

chmod a+x $BC_BIN/bcompare
chmod a+x $BC_LIB/BCompare
chmod a+x $BC_LIB/kde_context_menu
chmod a+x $BC_LIB/libqtc.so.1
chmod a+x $BC_LIB/libqt-mt.so.3
chmod a+x $BC_LIB/ext/*.so
chmod 644 $BC_LIB/ext/bcompare_ext_konq.desktop
chmod 644 $BC_LIB/qtrc
chmod 644 $BC_LIB/RPM-GPG-KEY-scootersoftware
chmod 644 $BC_LIB/scootersoftware.repo
chmod 644 $BC_LIB/README

function konq_ver_gt() 
{ 
testver=$1
fullver=`kde4-config -v`
kver=`echo ${fullver} | \
awk 'BEGIN { FS = "latform: " } ; { print $2 }' | \
awk 'BEGIN { FS = "(" } ; { print $1 }' | \
awk 'BEGIN { FS = "." } ; { printf("%03d.%03d.%03d", $1, $2, $3) }'`
smaller=`echo -e "$kver\n$testver" | sort --version-sort | head -1`
if [ "$smaller" = "$testver" ]; then return 1; else return 0; fi
}


##
# Create desktop entry and place Context Menu extensions, if root
##
if [ $(id -u) = "0" ]; then
	cp bcompare.desktop /usr/share/applications
	cp bcompare.xml /usr/share/mime/packages
	update-mime-database /usr/share/mime &> /dev/null
	if [ -f /usr/share/applications/mimeinfo.cache ]; then
		echo "application/beyond.compare.snapshot=bcompare.desktop" >> \
			/usr/share/applications/mimeinfo.cache
	fi
	cp $BCICON /usr/share/pixmaps
	cp $BC_CONTEXT_FULL /usr/share/pixmaps
	cp $BC_CONTEXT_HALF /usr/share/pixmaps
	echo "rm -f /usr/share/applications/bcompare.desktop" >> uninstall.sh
	echo "rm -f /usr/share/mime/packages/bcompare.xml" >> uninstall.sh
	echo "update-mime-database /usr/share/mime &> /dev/null" >> uninstall.sh
	echo "rm -f /usr/share/pixmaps/$BCICON" >> uninstall.sh
	echo "rm -f /usr/share/pixmaps/$BC_CONTEXT_FULL" >> uninstall.sh
	echo "rm -f /usr/share/pixmaps/$BC_CONTEXT_HALF" >> uninstall.sh

	##
	# Remove existing scripts before installing new
	##
	for i in /home/* /root; do
		if [ -d "\$i/.gnome2/nautilus-scripts" ]; then
			rm -f "\$i/.gnome2/nautilus-scripts/compare"
			rm -f "\$i/.gnome2/nautilus-scripts/compare_to_selected"
			rm -f "\$i/.gnome2/nautilus-scripts/select_for_compare"
		fi
		if [ -d "\$i/.kde4/share/kde4/services/ServiceMenus" ]; then
			rm -f "\$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare.desktop"
			rm -f "\$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare_compare.desktop"
			rm -f "\$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare_more.desktop"
			rm -f "\$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare_select.desktop"
		fi
		if [ -d "\$i/.kde/share/kde4/services/ServiceMenus" ]; then
			rm -f "\$i/.kde/share/kde4/services/ServiceMenus/beyondcompare.desktop"
			rm -f "\$i/.kde/share/kde4/services/ServiceMenus/beyondcompare_compare.desktop"
			rm -f "\$i/.kde/share/kde4/services/ServiceMenus/beyondcompare_more.desktop"
			rm -f "\$i/.kde/share/kde4/services/ServiceMenus/beyondcompare_select.desktop"
		fi
		if [ -d "\$i/.kde/share/apps/konqueror/servicemenus" ]; then
			rm -f "\$i/.kde/share/apps/konqueror/servicemenus/beyondcompare.desktop"
			rm -f "\$i/.kde/share/apps/konqueror/servicemenus/beyondcompare_compare.desktop"
			rm -f "\$i/.kde/share/apps/konqueror/servicemenus/beyondcompare_more.desktop"
			rm -f "\$i/.kde/share/apps/konqueror/servicemenus/beyondcompare_select.desktop"
		fi
	done

	##
	# Now install appropriate ContextMenu Extension or wait and let bcompare.sh
	# install scripts on KDE 3.5
	##
	for EXT_LIB in /usr/lib /usr/lib64
	do
		if [ -d "$EXT_LIB/kde4" ]; then
			konq_ver_gt 4.6.1
			ver_result=$?
			if [ ${ver_result} -eq 1 ]; then
				cp $BC_LIB/ext/bcompare_ext_kde.$MACH_ARCH.so \
					$EXT_LIB/kde4/bcompare_ext_kde.so
				cp $BC_LIB/ext/bcompare_ext_kde.desktop /usr/share/kde4/services/
				echo "rm -f $EXT_LIB/kde4/bcompare_ext_kde.so" >> uninstall.sh
				echo "rm -f /usr/share/kde4/services/bcompare_ext_kde.desktop" >> uninstall.sh
			else 
				cp $BC_LIB/ext/bcompare_ext_konq.$MACH_ARCH.so \
					$EXT_LIB/kde4/bcompare_ext_konq.so
				cp $BC_LIB/ext/bcompare_ext_konq.desktop /usr/share/kde4/services/
				echo "rm -f $EXT_LIB/kde4/bcompare_ext_konq.so" >> uninstall.sh
				echo "rm -f /usr/share/kde4/services/bcompare_ext_konq.desktop" >> uninstall.sh
			fi
		fi
		if [ -d "$EXT_LIB/nautilus/extensions-3.0" ]; then
			cp $BC_LIB/ext/bcompare-ext-nautilus.$MACH_ARCH.so \
				$EXT_LIB/nautilus/extensions-3.0/bcompare-ext-nautilus.so
			echo "rm -f $EXT_LIB/nautilus/extensions-3.0/bcompare-ext-nautilus.so" >> uninstall.sh
		elif [ -d "$EXT_LIB/nautilus/extensions-2.0" ]; then
			cp $BC_LIB/ext/bcompare-ext-nautilus.$MACH_ARCH.so \
				$EXT_LIB/nautilus/extensions-2.0/bcompare-ext-nautilus.so
			echo "rm -f $EXT_LIB/nautilus/extensions-2.0/bcompare-ext-nautilus.so" >> uninstall.sh
		elif [ -d "$EXT_LIB/nautilus/extensions-1.0" ]; then
			cp $BC_LIB/ext/bcompare-ext-nautilus.$MACH_ARCH.so \
				$EXT_LIB/nautilus/extensions-1.0/bcompare-ext-nautilus.so
			echo "rm -f $EXT_LIB/nautilus/extensions-1.0/bcompare-ext-nautilus.so" >> uninstall.sh
		fi
		if [ -d "$EXT_LIB/thunarx-2" ]; then
			cp $BC_LIB/ext/bcompare-ext-thunarx.$MACH_ARCH.so \
				$EXT_LIB/thunarx-2/bcompare-ext-thunars.so
			echo "rm -f $EXT_LIB/thunarx-2/bcompare-ext-thunarx.so" >> uninstall.sh
		elif [ -d "$EXT_LIB/thunarx-1" ]; then
			cp $BC_LIB/ext/bcompare-ext-thunarx.$MACH_ARCH.so \
				$EXT_LIB/thunarx-1/bcompare-ext-thunars.so
			echo "rm -f $EXT_LIB/thunarx-1/bcompare-ext-thunarx.so" >> uninstall.sh
		fi
	done
fi

cp uninstall.sh	$BC_LIB

which bcompare &> /dev/null
if [ $? != "0" ]; then
	export PATH=$BC_BIN:$PATH
	echo "======================================"
	echo "Please place the following in your .bashrc or .cshrc (etc.)"
	echo "export PATH=$BC_BIN:\$PATH"
	echo "======================================"
	echo "Executable is $BC_BIN/bcompare"
fi
