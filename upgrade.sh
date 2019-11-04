#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

function _time() {
endtime=$(date +%s)
timeused=$(( $endtime - $starttime ))
if [[ $timeused -gt 60 && $timeused -lt 3600 ]]; then
    timeusedmin=$(expr $timeused / 60)
    timeusedsec=$(expr $timeused % 60)
    echo -e " ${baiqingse}${bold}The $timeWORK took about ${timeusedmin} min ${timeusedsec} sec${normal}"
elif [[ $timeused -ge 3600 ]]; then
    timeusedhour=$(expr $timeused / 3600)
    timeusedmin=$(expr $(expr $timeused % 3600) / 60)
    timeusedsec=$(expr $timeused % 60)
    echo -e " ${baiqingse}${bold}The $timeWORK took about ${timeusedhour} hour ${timeusedmin} min ${timeusedsec} sec${normal}"
else
    echo -e " ${baiqingse}${bold}The $timeWORK took about ${timeused} sec${normal}"
fi ; }

function _colors() {
black=$(tput setaf 0)   ; red=$(tput setaf 1)          ; green=$(tput setaf 2)   ; yellow=$(tput setaf 3);  bold=$(tput bold)
blue=$(tput setaf 4)    ; magenta=$(tput setaf 5)      ; cyan=$(tput setaf 6)    ; white=$(tput setaf 7) ;  normal=$(tput sgr0)
on_black=$(tput setab 0); on_red=$(tput setab 1)       ; on_green=$(tput setab 2); on_yellow=$(tput setab 3)
on_blue=$(tput setab 4) ; on_magenta=$(tput setab 5)   ; on_cyan=$(tput setab 6) ; on_white=$(tput setab 7)
shanshuo=$(tput blink)  ; wuguangbiao=$(tput civis)    ; guangbiao=$(tput cnorm) ; jiacu=${normal}${bold}
underline=$(tput smul)  ; reset_underline=$(tput rmul) ; dim=$(tput dim)
standout=$(tput smso)   ; reset_standout=$(tput rmso)  ; title=${standout}
baihuangse=${white}${on_yellow}; bailanse=${white}${on_blue} ; bailvse=${white}${on_green}
baiqingse=${white}${on_cyan}   ; baihongse=${white}${on_red} ; baizise=${white}${on_magenta}
heibaise=${black}${on_white}   ; heihuangse=${on_yellow}${black}
CW="${bold}${baihongse} ERROR ${jiacu}";ZY="${baihongse}${bold} ATTENTION ${jiacu}";JG="${baihongse}${bold} WARNING ${jiacu}" ; }
_colors

SysSupport=0
DISTRO=$(awk -F'[= "]' '/PRETTY_NAME/{print $3}' /etc/os-release)
DISTROL=$(echo $DISTRO | tr 'A-Z' 'a-z')
CODENAME=$(cat /etc/os-release | grep VERSION= | tr '[A-Z]' '[a-z]' | sed 's/\"\|(\|)\|[0-9.,]\|version\|lts//g' | awk '{print $2}')
grep buster /etc/os-release -q && CODENAME=buster
[[ $DISTRO == Ubuntu ]] && osversion=$(grep Ubuntu /etc/issue | head -1 | grep -oE  "[0-9.]+")
[[ $DISTRO == Debian ]] && osversion=$(cat /etc/debian_version)
[[ $CODENAME =~        (bionic|buster)         ]] && SysSupport=1
[[ $CODENAME ==        trusty         ]] && SysSupport=2
[[ $CODENAME ==        wheezy         ]] && SysSupport=3
[[ $CODENAME =~        (xenial|stretch)        ]] && SysSupport=4
[[ $CODENAME ==        jessie         ]] && SysSupport=5

function upgradeA() {

[[ $CODENAME == trusty ]] && echo -e "\nYou are now running ${cyan}${bold}$DISTRO $osversion${normal}"
[[ $CODENAME == trusty ]] && { UPGRADE_DISTRO_1="Ubuntu 16.04" ; UPGRADE_DISTRO_2="Ubuntu 18.04" ; UPGRADE_CODENAME_1=xenial ; UPGRADE_CODENAME_2=bionic  ; }
echo
echo -e "${green}01)${normal} Upgrade to ${cyan}$UPGRADE_DISTRO_1${normal}"
echo -e "${green}02)${normal} Upgrade to ${cyan}$UPGRADE_DISTRO_2${normal}"
echo -e "${green}03)${normal} Do NOT upgrade system and exit script"
echo -ne "${bold}${yellow}Would you like to upgrade your system?${normal} (Default ${cyan}03${normal}): " ; read -e responce

case $responce in
    01 | 1     ) distro_up=Yes && UPGRADE_CODENAME=$UPGRADE_CODENAME_1  && UPGRADE_DISTRO=$UPGRADE_DISTRO_1                 ;;
    02 | 2     ) distro_up=Yes && UPGRADE_CODENAME=$UPGRADE_CODENAME_2  && UPGRADE_DISTRO=$UPGRADE_DISTRO_2 && UPGRDAE2=Yes ;;
    03 | 3 | "") distro_up=No                                                                                               ;;
    *          ) distro_up=No                                                                                               ;;
esac

if [[ $distro_up == Yes ]]; then
    echo -e "\n${bold}${baiqingse}Your system will be upgraded to ${baizise}${UPGRADE_DISTRO}${baiqingse} after reboot${normal}"
    _distro_upgrade | tee /etc/distro_upgrade.log
else
    echo -e "\n${baizise}Your system will ${baihongse}not${baizise} be upgraded${normal}"
fi

echo ; }

function upgradeB() {

[[ $CODENAME == wheezy ]] && echo -e "\nYou are now running ${cyan}${bold}$DISTRO $osversion${normal}"
[[ $CODENAME == wheezy ]] && { UPGRADE_DISTRO_1="Debian 8"     ; UPGRADE_DISTRO_2="Debian 9"     ; UPGRADE_DISTRO_3="Debian 10"     ; UPGRADE_CODENAME_1=jessie ; UPGRADE_CODENAME_2=stretch ; UPGRADE_CODENAME_3=buster ; }
echo
echo -e "${green}01)${normal} Upgrade to ${cyan}$UPGRADE_DISTRO_1${normal}"
echo -e "${green}02)${normal} Upgrade to ${cyan}$UPGRADE_DISTRO_2${normal}"
echo -e "${green}03)${normal} Upgrade to ${cyan}$UPGRADE_DISTRO_3${normal}"
echo -e "${green}04)${normal} Do NOT upgrade system and exit script"
echo -ne "${bold}${yellow}Would you like to upgrade your system?${normal} (Default ${cyan}04${normal}): " ; read -e responce

case $responce in
    01 | 1     ) distro_up=Yes && UPGRADE_CODENAME=$UPGRADE_CODENAME_1  && UPGRADE_DISTRO=$UPGRADE_DISTRO_1                 ;;
    02 | 2     ) distro_up=Yes && UPGRADE_CODENAME=$UPGRADE_CODENAME_2  && UPGRADE_DISTRO=$UPGRADE_DISTRO_2 && UPGRDAE2=Yes ;;
    03 | 3     ) distro_up=Yes && UPGRADE_CODENAME=$UPGRADE_CODENAME_3  && UPGRADE_DISTRO=$UPGRADE_DISTRO_3 && UPGRDAE3=Yes ;;
    04 | 4 | "") distro_up=No                                                                                               ;;
    *          ) distro_up=No                                                                                               ;;
esac

if [[ $distro_up == Yes ]]; then
    echo -e "\n${bold}${baiqingse}Your system will be upgraded to ${baizise}${UPGRADE_DISTRO}${baiqingse} after reboot${normal}"
    _distro_upgrade | tee /etc/distro_upgrade.log
elsea
    echo -e "\n${baizise}Your system will ${baihongse}not${baizise} be upgraded${normal}"
fi

echo ; }

function upgradeC() {

[[ $CODENAME == stretch || $CODENAME == xenial ]] && echo -e "\nYou are now running ${cyan}${bold}$DISTRO $osversion${normal}"
[[ $CODENAME == stretch ]] && { UPGRADE_DISTRO_1="Debian 10"     ; UPGRADE_CODENAME_1=buster ; }
[[ $CODENAME == xenial ]] && { UPGRADE_DISTRO_1="Ubuntu 18.04" ; UPGRADE_CODENAME_1=bionic  ; }
echo
echo -e "${green}01)${normal} Upgrade to ${cyan}$UPGRADE_DISTRO_1${normal}"
echo -e "${green}02)${normal} Do NOT upgrade system and exit script"
echo -ne "${bold}${yellow}Would you like to upgrade your system?${normal} (Default ${cyan}02${normal}): " ; read -e responce

case $responce in
    01 | 1     ) distro_up=Yes && UPGRADE_CODENAME=$UPGRADE_CODENAME_1  && UPGRADE_DISTRO=$UPGRADE_DISTRO_1                 ;;
    02 | 2 | "") distro_up=No                                                                                               ;;
    *          ) distro_up=No                                                                                               ;;
esac

if [[ $distro_up == Yes ]]; then
    echo -e "\n${bold}${baiqingse}Your system will be upgraded to ${baizise}${UPGRADE_DISTRO}${baiqingse} after reboot${normal}"
    _distro_upgrade | tee /etc/distro_upgrade.log
else
    echo -e "\n${baizise}Your system will ${baihongse}not${baizise} be upgraded${normal}"
fi

echo ; }

function upgradeD() {

[[ $CODENAME == jessie ]] && echo -e "\nYou are now running ${cyan}${bold}$DISTRO $osversion${normal}, which can be updated"
[[ $CODENAME == jessie ]] && { UPGRADE_DISTRO_1="Debian 9" ; UPGRADE_DISTRO_2="Debian 10" ; UPGRADE_CODENAME_1=stretch ; UPGRADE_CODENAME_2=buster  ; }
echo
echo -e "${green}01)${normal} Upgrade to ${cyan}$UPGRADE_DISTRO_1${normal}"
echo -e "${green}02)${normal} Upgrade to ${cyan}$UPGRADE_DISTRO_2${normal}"
echo -e "${green}03)${normal} Do NOT upgrade system and exit script"
echo -ne "${bold}${yellow}Would you like to upgrade your system?${normal} (Default ${cyan}03${normal}): " ; read -e responce

case $responce in
    01 | 1     ) distro_up=Yes && UPGRADE_CODENAME=$UPGRADE_CODENAME_1  && UPGRADE_DISTRO=$UPGRADE_DISTRO_1                 ;;
    02 | 2     ) distro_up=Yes && UPGRADE_CODENAME=$UPGRADE_CODENAME_2  && UPGRADE_DISTRO=$UPGRADE_DISTRO_2 && UPGRDAE2=Yes ;;
    03 | 3 | "") distro_up=No                                                                                               ;;
    *          ) distro_up=No                                                                                               ;;
esac

if [[ $distro_up == Yes ]]; then
    echo -e "\n${bold}${baiqingse}Your system will be upgraded to ${baizise}${UPGRADE_DISTRO}${baiqingse} after reboot${normal}"
    _distro_upgrade | tee /etc/distro_upgrade.log
else
    echo -e "\n${baizise}Your system will ${baihongse}not${baizise} be upgraded${normal}"
fi

echo ; }

function _distro_upgrade_upgrade() {
echo -e "\n\n\n${baihongse}executing upgrade${normal}\n\n\n"
apt-get --force-yes -o Dpkg::Options::="--force-confnew" --force-yes -o Dpkg::Options::="--force-confdef" -fuy upgrade

echo -e "\n\n\n${baihongse}executing dist-upgrade${normal}\n\n\n"
apt-get --force-yes -o Dpkg::Options::="--force-confnew" --force-yes -o Dpkg::Options::="--force-confdef" -fuy dist-upgrade ; }

function _distro_upgrade() {
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
starttime=$(date +%s)

# apt-get -f install
echo -e "\n${baihongse}executing apt-listchanges remove${normal}\n"
apt-get remove apt-listchanges --assume-yes --force-yes
echo 'libc6 libraries/restart-without-asking boolean true' | debconf-set-selections
echo -e "${baihongse}executing apt sources change${normal}\n"
sed -i "s/$CODENAME/$UPGRADE_CODENAME/g" /etc/apt/sources.list
echo -e "${baihongse}executing autoremove${normal}\n"
apt-get -fuy --force-yes autoremove
echo -e "${baihongse}executing clean${normal}\n"
apt-get --force-yes clean

echo -e "${baihongse}executing update${normal}\n"
cp /etc/apt/sources.list /etc/apt/sources.list."$(date "+%Y.%m.%d.%H.%M.%S")".bak
wget --no-check-certificate -O /etc/apt/sources.list https://github.com/Aniverse/inexistence/raw/master/00.Installation/template/$DISTROL.apt.sources
[[ $DISTROL == debian ]] && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5C808C2B65558117

if [[ $UPGRDAE3 == Yes ]]; then
    sed -i "s/RELEASE/${UPGRADE_CODENAME_1}/g" /etc/apt/sources.list
    apt-get -y update
    _distro_upgrade_upgrade
    sed -i "s/${UPGRADE_CODENAME_1}/${UPGRADE_CODENAME_2}/g" /etc/apt/sources.list
    apt-get -y update
    _distro_upgrade_upgrade
    sed -i "s/${UPGRADE_CODENAME_2}/${UPGRADE_CODENAME_3}/g" /etc/apt/sources.list
    apt-get -y update
elif [[ $UPGRDAE2 == Yes ]]; then
    sed -i "s/RELEASE/${UPGRADE_CODENAME_1}/g" /etc/apt/sources.list
    apt-get -y update
    _distro_upgrade_upgrade
    sed -i "s/${UPGRADE_CODENAME_1}/${UPGRADE_CODENAME_2}/g" /etc/apt/sources.list
    apt-get -y update
else
    sed -i "s/RELEASE/${UPGRADE_CODENAME}/g" /etc/apt/sources.list
    apt-get -y update
fi

_distro_upgrade_upgrade

timeWORK=upgradation
echo -e "\n\n\n" ; _time

echo -e "\n\n ${shanshuo}${baihongse}Reboot system now. You need to rerun this script after reboot${normal}\n\n\n\n\n"

sleep 5
reboot -f
init 6

sleep 5
kill -s TERM $TOP_PID
exit 0 ; }

function _oscheck() {
if [[ $SysSupport == 1 ]]; then
    echo -e "\n${green}${bold}Excited! Your operating system is already the latest version. Let's make some big news ... ${normal}"
elif [[ $SysSupport =~ (2|3|4|5) ]]; then
    [[ $SysSupport == 2 ]] && upgradeA
    [[ $SysSupport == 3 ]] && upgradeB
    [[ $SysSupport == 4 ]] && upgradeC
    [[ $SysSupport == 5 ]] && upgradeD
else
    echo -e "\n${bold}${red}Too young too simple! Only Debian 7/8/9 and Ubuntu 14.04/16.04 is supported by this script${normal}"
fi ; }
_oscheck
