#!/bin/sh

if [ "$(xrandr | grep "HDMI1 connected")" ]; then
  xrandr --output HDMI1 --auto --left-of eDP1
  bspc monitor HDMI1 -d I II III IV V VI VII VIII IX
  bspc monitor eDP1 -d X
else
  xrandr --output HDMI1 --off
  bspc monitor HDMI1 --remove
  bspc monitor eDP1 -d I II III IV V VI VII VIII IX X
fi

xbacklight = 100
feh --bg-fill --randomize /mnt/hdd/Pictures/wallpapers
xrdb ~/.Xresources
if ! ps cax | grep xkeysnail > /dev/null; then
  xkbcomp -I${HOME}/.xkb ${HOME}/.xkb/keymap/mykbd $DISPLAY
  xset r rate 200 50
  xset -b
fi
if ! ps cax | grep yabar > /dev/null; then
  yabar &
fi
sleep 0.2
bspc config bottom_padding 0
bspc config left_padding 0
bspc config right_padding 0

compton -b --config ~/.config/compton/compton.conf