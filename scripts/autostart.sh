#!/bin/sh

# Input Method
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
fcitx-autostart

# web browser
sh /etc/scripts/surf-loop &


# wallpaper
WALLPAPER=/srv/data/wallpaper.png
if [ -e $WALLPAPER ]
then
	feh --bg-scale $WALLPAPER
else
	xsetroot -solid SteelBlue
fi

# status bar
while xsetroot -name "`date` `uptime | sed 's/.*,//'`"
do
	sleep 1
done &
