#!/bin/bash
# Author: nnoell <nnoell3@gmail.com>
# Depends: dzen2-xft-xpm-xinerama-svn && conky
# Desc: dzen2 bar for XMonad, ran within xmonad.hs via spawnPipe

#Layout
BAR_H=9
BIGBAR_W=65
WIDTH_L=870
WIDTH_R=1050 #WIDTH_L + WIDTH_R = 1920
HEIGHT=16
X_POS_L=0
X_POS_R=$WIDTH_L
Y_POS=0

#Colors and font
CRIT="#99cc66"
BAR_FG="#3475aa"
BAR_BG="#363636"
DZEN_FG="#9d9d9d"
DZEN_FG2="#444444"
DZEN_BG="#020202"
COLOR_SEP=$DZEN_FG2
FONT="-*-montecarlo-medium-r-normal-*-11-*-*-*-*-*-*-*"

#Conky
CONKYFILE="${HOME}/.config/conky/conkyrc"
IFS='|'
INTERVAL=1
CPUTemp=0
GPUTemp=0
CPULoad0=0
CPULoad1=0
MpdInfo=0
MpdRandom="Off"
MpdRepeat="Off"

#clickable areas
VOL_MUTE_CMD="sh /home/nnoell/bin/volosd.sh mute"
VOL_UP_CMD="sh /home/nnoell/bin/volosd.sh up"
VOL_DOWN_CMD="sh /home/nnoell/bin/volosd.sh down"
DROP_START_CMD="dropbox start"
DROP_STOP_CMD="dropbox stop"
MPD_REP_CMD="mpc -h 127.0.0.1 repeat"
MPD_RAND_CMD="mpc -h 127.0.0.1 random"
MPD_TOGGLE_CMD="ncmpcpp toggle"
MPD_NEXT_CMD="ncmpcpp next"
MPD_PREV_CMD="ncmpcpp prev"
CAL_CMD="sh ${HOME}/bin/dzencal.sh"


printVolInfo() {
	Perc=$(amixer get Master | grep "Mono:" | awk '{print $4}' | tr -d '[]%')
	Mute=$(amixer get Master | grep "Mono:" | awk '{print $6}')
	echo -n "^fg($DZEN_FG2) ^ca(1,$VOL_MUTE_CMD)^ca(4,$VOL_UP_CMD)^ca(5,$VOL_DOWN_CMD)VOL^ca()^ca()^ca() "
	if [[ $Mute == "[off]" ]]; then
		echo -n "$(echo $Perc | gdbar -fg $CRIT -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -s o -ss 1 -sw 2 -nonl) "
		echo -n "^fg()off"
	else
		echo -n "$(echo $Perc | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -s o -ss 1 -sw 2 -nonl) "
		echo -n "^fg()${Perc}%"
	fi
	return
}

printCPUInfo() {
	[[ $CPULoad0 -gt 70 ]] && CPULoad0="^fg($CRIT)$CPULoad0^fg()"
	[[ $CPULoad1 -gt 70 ]] && CPULoad1="^fg($CRIT)$CPULoad1^fg()"
	echo -n " ^fg($DZEN_FG2)CPU ^fg($BAR_FG)${CPULoad0}%^fg($DZEN_FG2)/^fg($BAR_FG)${CPULoad1}%"
	return
}

printTempInfo() {
	CPUTemp=$(acpi --thermal | awk '{print substr($4,0,2)}')
	GPUTemp=$(nvidia-settings -q gpucoretemp | grep 'Attribute' | awk '{print $4}' | tr -d '.')
	[[ $CPUTemp -gt 70 ]] && CPUTemp="^fg($CRIT)$CPUTemp^fg()"
	[[ $GPUTemp -gt 70 ]] && GPUTemp="^fg($CRIT)$GPUTemp^fg()"
	echo -n "^fg($DZEN_FG2)TEMP ^fg($BAR_FG)${CPUTemp}°^fg($DZEN_FG2)/^fg($BAR_FG)${GPUTemp}°"
	return
}

printMemInfo() {
	[[ $MemPerc -gt 70 ]] && CPUTemp="^fg($CRIT)$MemPerc^fg()"
	echo -n "^fg($DZEN_FG2)MEM ^fg($BAR_FG)${MemPerc}%"
	return
}

printDropBoxInfo() {
	DropboxON=$(ps -A | grep -c dropbox)
	if [[ $DropboxON == "0" ]]; then
		echo -n "^fg($DZEN_FG2)^ca(1,$DROP_START_CMD)DROPBOX^ca() ^fg()Off"
	else
		echo -n "^fg($DZEN_FG2)^ca(1,$DROP_STOP_CMD)DROPBOX^ca() ^fg($CRIT)On"
	fi
	return
}

printMpdInfo() {
	MPDON=$(ps -A | grep -c mpd)
	if [[ $MPDON == "0" ]]; then
		echo -n "^fg($DZEN_FG2)^ca(1,mpd)MPD^ca() ^fg()Off"
	else
		[[ $MpdRepeat == "On" ]] && MpdRepeat="^fg($CRIT)$MpdRepeat^fg()"
		[[ $MpdRandom == "On" ]] && MpdRandom="^fg($CRIT)$MpdRandom^fg()"
		echo -n "^fg($DZEN_FG2)^ca(1,$MPD_REP_CMD)REPEAT^ca() ^fg()$MpdRepeat "
		echo -n "^fg($DZEN_FG2)| ^ca(1,$MPD_RAND_CMD)RANDOM^ca() ^fg()$MpdRandom "
		echo -n "^fg($DZEN_FG2)| ^ca(1,$MPD_TOGGLE_CMD)^ca(4,$MPD_NEXT_CMD)^ca(5,$MPD_PREV_CMD)MPD^ca()^ca()^ca() $MpdInfo"
	fi
	return
}

printDateInfo() {
	echo -n "^ca(1,$CAL_CMD)^fg()$(date '+%Y^fg(#444).^fg()%m^fg(#444).^fg()%d^fg(#3475aa)/^fg(#444444)%a ^fg(#363636)| ^fg()%H^fg(#444):^fg()%M^fg(#444):^fg()%S')^ca() "
	return
}

printSpace() {
	echo -n " ^fg($COLOR_SEP)|^fg() "
	return
}

printLeft() {
	while true; do
		read CPULoad0 CPULoad1 CPUFreq MemUsed MemPerc MpdInfo MpdRandom MpdRepeat
		printVolInfo
		printSpace
		printDropBoxInfo
		printSpace
		printMpdInfo
		echo -n " ^fg()>^fg($BAR_FG)>^fg($DZEN_FG2)>"
		echo
	done
	return
}

printRight() {
	while true; do
		read CPULoad0 CPULoad1 CPUFreq MemUsed MemPerc MpdInfo MpdRandom MpdRepeat
		printCPUInfo
		printSpace
		printMemInfo
		printSpace
		printTempInfo
		printSpace
		printDateInfo
		echo
	done
	return
}

#Print all and pipe into dzen
conky -c $CONKYFILE -u $INTERVAL | printLeft | dzen2 -x $X_POS_L -y $Y_POS -w $WIDTH_L -h $HEIGHT -fn $FONT -ta 'l' -bg $DZEN_BG -fg $DZEN_FG -p -e '' &
conky -c $CONKYFILE -u $INTERVAL | printRight | dzen2 -x $X_POS_R -y $Y_POS -w $WIDTH_R -h $HEIGHT -fn $FONT -ta 'r' -bg $DZEN_BG -fg $DZEN_FG -p -e ''
