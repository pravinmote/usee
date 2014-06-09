#!/bin/sh
##
# Find location of bcompare*.deb and see if BC3Key.txt is there.  If
# so install it
##
parent_env=`ps -p $PPID e`
cmd_line=`echo $parent_env | sed 's/ /\n/g' | grep --max-count=1 "bcompare-.*\.deb$"`
cmd_path=${cmd_line%bcompare*.deb}
work_dir=$PWD
slash_pos=`expr index "$cmd_path" /`
if [ "$slash_pos" = "1" ]; then
	full_path=$cmd_path
else
	full_path=$work_dir/$cmd_path
fi
if [ -f $full_path/BC3Key.txt ]; then
	cp $full_path/BC3Key.txt /usr/lib/beyondcompare
	chmod a+r /usr/lib/beyondcompare/BC3Key.txt
fi

##
# Add our repository to the repository list
# PL: Commented out for UbuntuSEE package to keep version updates
#     in control
##
#if [ -d /etc/apt/sources.list.d ]; then
#	cp /usr/lib/beyondcompare/scootersoftware.list /etc/apt/#sources.list.d/
#fi

##
# Remove existing scripts
##
for i in /home/* /root; do
	if [ -d "$i/.gnome2/nautilus-scripts" ]; then
		rm -f "$i/.gnome2/nautilus-scripts/compare"
		rm -f "$i/.gnome2/nautilus-scripts/compare_to_selected"
		rm -f "$i/.gnome2/nautilus-scripts/select_for_compare"
	fi
	if [ -d "$i/.kde4/share/kde4/services/ServiceMenus" ]; then
		rm -f "$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare.desktop"
		rm -f "$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare_compare.desktop"
		rm -f "$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare_more.desktop"
		rm -f "$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare_select.desktop"
	fi
	if [ -d "$i/.kde/share/kde4/services/ServiceMenus" ]; then
		rm -f "$i/.kde/share/kde4/services/ServiceMenus/beyondcompare.desktop"
		rm -f "$i/.kde/share/kde4/services/ServiceMenus/beyondcompare_compare.desktop"
		rm -f "$i/.kde/share/kde4/services/ServiceMenus/beyondcompare_more.desktop"
		rm -f "$i/.kde/share/kde4/services/ServiceMenus/beyondcompare_select.desktop"
	fi
	if [ -d "$i/.kde/share/apps/konqueror/servicemenus" ]; then
		rm -f "$i/.kde/share/apps/konqueror/servicemenus/beyondcompare.desktop"
		rm -f "$i/.kde/share/apps/konqueror/servicemenus/beyondcompare_compare.desktop"
		rm -f "$i/.kde/share/apps/konqueror/servicemenus/beyondcompare_more.desktop"
		rm -f "$i/.kde/share/apps/konqueror/servicemenus/beyondcompare_select.desktop"
	fi
done

##
# Put in new Context Menu Script on anything that isn't KDE 3.5.  For that
# one the bcompare.sh script will install scripts.
##
for EXT_LIB in /usr/lib /usr/lib64
do
	if [ -d "$EXT_LIB/kde4" ]; then
		testver="4.6.1"
		fullver=`kde4-config -v`
		kver=`echo ${fullver} | 		/usr/bin/awk 'BEGIN { FS = "latform: " } ; { print $2 }' | 		/usr/bin/awk 'BEGIN { FS = "(" } ; { print $1 }' | 		/usr/bin/awk 'BEGIN { FS = "." } ; { printf("%03d.%03d.%03d", $1, $2, $3) }'`
		smaller=`/bin/echo -e "$kver\n$testver" | /usr/bin/sort -V | /usr/bin/head -1`
		if [ "$smaller" = "$testver" ]; then
			cp /usr/lib/beyondcompare/ext/bcompare_ext_kde.i386.so 				$EXT_LIB/kde4/bcompare_ext_kde.so
			cp /usr/lib/beyondcompare/ext/bcompare_ext_kde.desktop /usr/share/kde4/services/
		else
			cp /usr/lib/beyondcompare/ext/bcompare_ext_konq.i386.so 				$EXT_LIB/kde4/bcompare_ext_konq.so
			cp /usr/lib/beyondcompare/ext/bcompare_ext_konq.desktop /usr/share/kde4/services/
		fi
	fi
	if [ -d "$EXT_LIB/nautilus/extensions-3.0" ]; then
		cp /usr/lib/beyondcompare/ext/bcompare-ext-nautilus.i386.so 			$EXT_LIB/nautilus/extensions-3.0/bcompare-ext-nautilus.so
	elif [ -d "$EXT_LIB/nautilus/extensions-2.0" ]; then
		cp /usr/lib/beyondcompare/ext/bcompare-ext-nautilus.i386.so 			$EXT_LIB/nautilus/extensions-2.0/bcompare-ext-nautilus.so
	elif [ -d "$EXT_LIB/nautilus/extensions-1.0" ]; then
		cp /usr/lib/beyondcompare/ext/bcompare-ext-nautilus.i386.so 			$EXT_LIB/nautilus/extensions-1.0/bcompare-ext-nautilus.so
	fi
	if [ -d "$EXT_LIB/thunarx-2" ]; then
		cp /usr/lib/beyondcompare/ext/bcompare-ext-thunarx.i386.so 			$EXT_LIB/thunarx-2/bcompare-ext-thunarx.so
	elif [ -d "$EXT_LIB/thunarx-1" ]; then
		cp /usr/lib/beyondcompare/ext/bcompare-ext-thunarx.i386.so 			$EXT_LIB/thunarx-1/bcompare-ext-thunarx.so
	fi
done

##
# Set up Beyond Compare mime types and associations
##
update-mime-database /usr/share/mime &> /dev/null
if [ -f /usr/share/applications/mimeinfo.cache ]; then
	echo "application/beyond.compare.snapshot=bcompare.desktop" >> 		/usr/share/applications/mimeinfo.cache
fi

##
# Install our signing key
##
apt-key add /usr/lib/beyondcompare/GPG-KEY-scootersoftware

ver=`dpkg-query -W -f='${Version}\n' bcompare:i386 | cut -d'-' -f1`
perl /nokia/apps/easha/ubuntusee-common/usage-logging/installation_log.pl -t "Beyond Compare" -tv "$ver"