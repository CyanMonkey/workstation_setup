#!/bin/bash
#checks if the monitor is in fullscreen. Disables screen timeout if true
export DISPLAY=:0
gRoot=$(xdotool search --maxdepth 0 '.*' getwindowgeometry | grep 'Geometry:')
gActive=$(xdotool getactivewindow getwindowgeometry | grep 'Geometry:')
if [ "$gRoot" = "$gActive" ]; then
	xset s 0
else
	xset s 59 59
fi
