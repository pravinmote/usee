#!/bin/sh
##
# Remove the Key
##
rm -f /usr/lib/beyondcompare/BC3Key.txt

##
# Look for Context Menu scripts and Extensions and remove them
##
if [ "$1" = remove ]; then

	##
	# Search standard locations for Context Menu Scripts
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
		if [ -f /usr/lib/beyondcompare/BC3Key.txt ]; then
			rm /usr/lib/beyondcompare/BC3Key.txt
		fi
	done

	##
	# Look for Context Menu extensions and remove
	##
	for EXT_LIB in /usr/lib /usr/lib64
	do
		if [ -d "$EXT_LIB/kde4" ]; then
			rm -f $EXT_LIB/kde4/bcompare_ext_kde.so
			rm -f /usr/share/kde4/services/bcompare_ext_kde.desktop
			rm -f $EXT_LIB/kde4/bcompare_ext_konq.so
			rm -f /usr/share/kde4/services/bcompare_ext_konq.desktop
		fi
		if [ -d "$EXT_LIB/nautilus/extensions-3.0" ]; then
			rm -f $EXT_LIB/nautilus/extensions-3.0/bcompare-ext-nautilus.so
		elif [ -d "$EXT_LIB/nautilus/extensions-2.0" ]; then
			rm -f $EXT_LIB/nautilus/extensions-2.0/bcompare-ext-nautilus.so
		elif [ -d "$EXT_LIB/nautilus/extensions-1.0" ]; then
			rm -f /nautilus/extensions-1.0/bcompare-ext-nautilus.so
		fi
		if [ -d "$EXT_LIB/thunarx-2" ]; then
			rm -f $EXT_LIB/thunarx-2/bcompare-ext-thunarx.so
		elif [ -d "$EXT_LIB/thunarx-1" ]; then
			rm -f $EXT_LIB/thunarx-1/bcompare-ext-thunarx.so
		fi
	done
fi

##
# Update mime types after Beyond Compare types are removed
##
update-mime-database /usr/share/mime &> /dev/null