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
    fi ;
}

function _colors() {
    red=$(tput setaf 1)          ; green=$(tput setaf 2)        ; yellow=$(tput setaf 3)  ; bold=$(tput bold)
    magenta=$(tput setaf 5)      ; cyan=$(tput setaf 6)         ; white=$(tput setaf 7)   ; normal=$(tput sgr0)
    on_red=$(tput setab 1)       ; on_magenta=$(tput setab 5)   ; on_cyan=$(tput setab 6) ; shanshuo=$(tput blink)
    baiqingse=${white}${on_cyan} ; baihongse=${white}${on_red}  ; baizise=${white}${on_magenta}
}
_colors

SysSupport=0
DISTRO=$(awk -F'[= "]' '/PRETTY_NAME/{print $3}' /etc/os-release)
DISTROL=$(echo $DISTRO | tr 'A-Z' 'a-z')
CODENAME=$(cat /etc/os-release | grep VERSION= | tr '[A-Z]' '[a-z]' | sed 's/\"\|(\|)\|[0-9.,]\|version\|lts//g' | awk '{print $2}')
grep buster /etc/os-release -q && CODENAME=buster
[[ $DISTRO == Ubuntu ]] && osversion=$(grep Ubuntu /etc/issue | head -1 | grep -oE  "[0-9.]+")
[[ $DISTRO == Debian ]] && osversion=$(cat /etc/debian_version)
[[ $CODENAME  ==  xenial  ]] && SysSupport=13
[[ $CODENAME  ==  trusty  ]] && SysSupport=12
[[ $CODENAME  ==  stretch ]] && SysSupport=23
[[ $CODENAME  ==  jessie  ]] && SysSupport=22
[[ $CODENAME  ==  wheezy  ]] && SysSupport=21


function distrocode (){
    [[ $SysSupport == 14  ]] && { UPGRADE_DISTRO="Ubuntu 18.04" ; UPGRADE_CODENAME=bionic ; }
    [[ $SysSupport == 13  ]] && { UPGRADE_DISTRO="Ubuntu 16.04" ; UPGRADE_CODENAME=xenial ; }
    [[ $SysSupport == 24  ]] && { UPGRADE_DISTRO="Debian 10" ; UPGRADE_CODENAME=buster ; }
    [[ $SysSupport == 23  ]] && { UPGRADE_DISTRO="Debian 9" ; UPGRADE_CODENAME=stretch ; }
    [[ $SysSupport == 22  ]] && { UPGRADE_DISTRO="Debian 8" ; UPGRADE_CODENAME=jessie ; } ;
}

function upgrade(){
    echo -e "\nYou are now running ${cyan}${bold}$DISTRO $osversion${normal}"
    count=${SysSupport:0-1:1}
    ((max_version_gap = 4 - count))
    version_gap=0
    echo
    echo -e "${green}00)${normal} Do NOT upgrade system and exit script"
    while [[ $version_gap != $max_version_gap ]] ; do
       ((SysSupport = SysSupport + 1))
       ((version_gap = version_gap + 1))
       distrocode
       echo -e "${green}0$version_gap)${normal} Upgrade to ${cyan}$UPGRADE_DISTRO${normal}"
    done
    count=${SysSupport:0-1:1}
    echo -ne "${bold}${yellow}Would you like to upgrade your system?${normal} (Default ${cyan}00${normal}): " ; read -e responce
    upgrade_version_gap=${responce:0-1:1}
    if [[ $upgrade_version_gap < 1 ]]; then
        echo -e "\n${baizise}Your system will ${baihongse}not${baizise} be upgraded${normal}"
    elif [[ $upgrade_version_gap < $max_version_gap ]]; then
        ((SysSupport = SysSupport - max_version_gap + upgrade_version_gap))
        distrocode
        echo -e "\n${bold}${baiqingse}Your system will be upgraded to ${baizise}${UPGRADE_DISTRO}${baiqingse} after reboot${normal}"
        distro_upgrade | tee /etc/distro_upgrade.log
    elif [[ $upgrade_version_gap = $max_version_gap ]]; then
        echo -e "\n${bold}${baiqingse}Your system will be upgraded to ${baizise}${UPGRADE_DISTRO}${baiqingse} after reboot${normal}"
        distro_upgrade | tee /etc/distro_upgrade.log
    else
        echo -e "\n${baizise}Your system will ${baihongse}not${baizise} be upgraded${normal}"
    fi ;
}

function changesource() {
    echo -ne "${bold}${yellow}Would you like to change your apt source list?${normal} (Default ${cyan}No${normal}): " ; read -e responce
    case $responce in
        Yes | Y | yes | y      ) _change_aptlist=Yes                 ;;
        No  | N | no  | n | "" ) _change_aptlist=No                  ;;
        *                      ) _change_aptlist=No                  ;;
    esac

    if [[ $_change_aptlist == Yes ]]; then
        echo -e "\n${bold}${baiqingse}Your apt source list will be changed${normal}"
    else
        echo -e "\n${baizise}Your apt source list will ${baihongse}not${baizise} be changed${normal}"
    fi

    echo ;
}

function distro_upgrade() {
    export DEBIAN_FRONTEND=noninteractive
    export APT_LISTCHANGES_FRONTEND=none
    starttime=$(date +%s)

    # apt-get -f install
    changesource
    apt-get -y update
    apt-get --force-yes -o Dpkg::Options::="--force-confnew" --force-yes -o Dpkg::Options::="--force-confdef" -fuy upgrade
    echo -e "\n\n\n${baihongse}executing apt-listchanges remove${normal}\n\n\n"
    apt-get remove apt-listchanges --assume-yes --force-yes
    echo 'libc6 libraries/restart-without-asking boolean true' | debconf-set-selections
    if [[ $_change_aptlist == Yes ]]; then
        echo -e "\n\n\n${baihongse}executing apt sources change${normal}\n\n\n"
        cp /etc/apt/sources.list /etc/apt/sources.list."$(date "+%Y.%m.%d.%H.%M.%S")".bak
        wget --no-check-certificate -O /etc/apt/sources.list https://github.com/Aniverse/inexistence/raw/master/00.Installation/template/$DISTROL.apt.sources
        [[ $DISTROL == debian ]] && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5C808C2B65558117
    else
        sed -i "s/$CODENAME/RELEASE/g" /etc/apt/sources.list
    fi
    echo -e "\n${baihongse}executing update${normal}\n"

    ((SysSupport = SysSupport - upgrade_version_gap))
    UPGRADE_CODENAME_OLD=RELEASE
    while [[ $upgrade_version_gap != 0 ]] ; do
        ((SysSupport = SysSupport + 1))
        ((upgrade_version_gap = upgrade_version_gap - 1))
        distrocode
        sed -i "s/$UPGRADE_CODENAME_OLD/$UPGRADE_CODENAME/g" /etc/apt/sources.list
        UPGRADE_CODENAME_OLD=$UPGRADE_CODENAME
        apt-get -y update
        echo -e "\n\n\n${baihongse}executing upgrade${normal}\n\n\n"
        apt-get --force-yes -o Dpkg::Options::="--force-confnew" --force-yes -o Dpkg::Options::="--force-confdef" -fuy upgrade
        echo -e "\n\n\n${baihongse}executing dist-upgrade${normal}\n\n\n"
        apt-get --force-yes -o Dpkg::Options::="--force-confnew" --force-yes -o Dpkg::Options::="--force-confdef" -fuy dist-upgrade
    done
    echo -e "\n\n\n${baihongse}executing autoremove${normal}\n\n\n"
    apt-get -fuy --force-yes autoremove
    echo -e "\n\n\n${baihongse}executing clean${normal}\n\n\n"
    apt-get --force-yes clean

    timeWORK=upgradation
    echo -e "\n\n\n" ; _time

    echo -e "\n\n ${shanshuo}${baihongse}Reboot system now. You need to rerun this script after reboot${normal}\n\n\n\n\n"

    sleep 5
    reboot -f
    init 6

    sleep 5
    kill -s TERM $TOP_PID
    exit 0 ;
}

function _oscheck() {
    if [[ $CODENAME =~ (bionic|buster) ]]; then
        echo -e "\n${green}${bold}Excited! Your operating system is already the latest version. Let's make some big news ... ${normal}\n"
    elif [[ $SysSupport != 0 ]]; then
        upgrade
    else
        echo -e "\n${bold}${red}Too young too simple! Only Debian 7/8/9 and Ubuntu 14.04/16.04 is supported by this script${normal}\n"
    fi ;
}

if [[ $EUID != 0 ]]; then
    echo -e "\n${bold}${red}Naive! I think this young man will not be able to run this script without root privileges.${normal}\n"
else
    _oscheck
fi
