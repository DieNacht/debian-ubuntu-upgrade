#!/bin/bash
#
# https://github.com/DieNacht/debian-ubuntu-upgrade
# Author: DieNacht
#
# Thanks to amefs and Aniverse

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

if [[ -f /etc/inexistence/00.Installation/function ]]; then
    source /etc/inexistence/00.Installation/function
else
    source <(wget -qO- https://github.com/Aniverse/inexistence/raw/master/00.Installation/function)
fi

set_variables_log_location
check_var_OutputLOG
debug_log_location
cat_outputlog

SysSupport=0
[[ $CODENAME  ==  bionic  ]] && SysSupport=3
[[ $CODENAME  ==  xenial  ]] && SysSupport=2
[[ $CODENAME  ==  trusty  ]] && SysSupport=1
[[ $CODENAME  ==  stretch ]] && SysSupport=3
[[ $CODENAME  ==  jessie  ]] && SysSupport=2
[[ $CODENAME  ==  wheezy  ]] && SysSupport=1


function _SysSupport_to_DisrtoCodename (){
    [[ $SysSupport == 4  ]] && [[ $DISTRO == Ubuntu ]] && { UPGRADE_DISTRO="Ubuntu 20.04" ; UPGRADE_CODENAME=focal   ; }
    [[ $SysSupport == 3  ]] && [[ $DISTRO == Ubuntu ]] && { UPGRADE_DISTRO="Ubuntu 18.04" ; UPGRADE_CODENAME=bionic  ; }
    [[ $SysSupport == 2  ]] && [[ $DISTRO == Ubuntu ]] && { UPGRADE_DISTRO="Ubuntu 16.04" ; UPGRADE_CODENAME=xenial  ; }
    [[ $SysSupport == 4  ]] && [[ $DISTRO == Debian ]] && { UPGRADE_DISTRO="Debian 10"    ; UPGRADE_CODENAME=buster  ; }
    [[ $SysSupport == 3  ]] && [[ $DISTRO == Debian ]] && { UPGRADE_DISTRO="Debian 9"     ; UPGRADE_CODENAME=stretch ; }
    [[ $SysSupport == 2  ]] && [[ $DISTRO == Debian ]] && { UPGRADE_DISTRO="Debian 8"     ; UPGRADE_CODENAME=jessie  ; } ;
}

function _ask_upgrade(){

    count=$SysSupport
    ((max_version_gap = 4 - count))
    version_gap=0
    echo

    while [[ $version_gap != $max_version_gap ]] ; do
       ((SysSupport = SysSupport + 1))
       ((version_gap = version_gap + 1))
       _SysSupport_to_DisrtoCodename
       echo -e "${green}0$version_gap)${normal} Upgrade to ${cyan}$UPGRADE_DISTRO${normal}"
    done
    ((version_gap = version_gap + 1))
    echo -e "${green}0$version_gap)${normal} Do NOT upgrade system and exit script\n"

    count=$SysSupport
    echo -ne "${bold}${yellow}Would you like to upgrade your system?${normal} (Default ${cyan}0$version_gap${normal}): " ; read -e responce
    ((version_gap = version_gap - 1))
    upgrade_version_gap=${responce:0-1:1}

#    if [[ $upgrade_version_gap < 1 ]]; then
#        echo -e "\n${baizise}Your system will ${baihongse}not${baizise} be upgraded${normal}"
#    elif [[ $upgrade_version_gap < $max_version_gap ]]; then
#        ((SysSupport = SysSupport - max_version_gap + upgrade_version_gap))
#        _SysSupport_to_DisrtoCodename
#        echo -e "\n${bold}${baiqingse}Your system will be upgraded to ${baizise}${UPGRADE_DISTRO}${baiqingse} after reboot${normal}"
#        distro_upgrade | tee /etc/distro_upgrade.log
#    elif [[ $upgrade_version_gap = $max_version_gap ]]; then
#        echo -e "\n${bold}${baiqingse}Your system will be upgraded to ${baizise}${UPGRADE_DISTRO}${baiqingse} after reboot${normal}"
#        distro_upgrade | tee /etc/distro_upgrade.log
#    else
#        echo -e "\n${baizise}Your system will ${baihongse}not${baizise} be upgraded${normal}"
#    fi

    [ -z "$(echo $upgrade_version_gap | sed -n "/^[0-9]\+$/p")" ] && upgradable=0
    [[ $upgrade_version_gap == 0 ]] && upgradable=0
    [[ $upgrade_version_gap > $max_version_gap ]] && upgradable=0

    if [[ $upgradable == 0 ]]; then
        echo -e "\n${baizise}Your system will ${baihongse}not${baizise} be upgraded${normal}"
    else
        ((SysSupport = SysSupport - max_version_gap + upgrade_version_gap))
        _SysSupport_to_DisrtoCodename
        echo -e "\n${bold}${baiqingse}Your system will be upgraded to ${baizise}${UPGRADE_DISTRO}${baiqingse} after reboot${normal}"
        distro_upgrade | tee /etc/distro_upgrade.log
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

    echo_task "${baihongse}Executing Pre-Upgrade Process${normal}"
    echo && echo

    echo_task "Preparation"
    apt-get -y update >> "$OutputLOG" 2>&1 & spinner $!
    echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"

    echo_task "Executing APT Upgrade"
    apt-get --force-yes -o Dpkg::Options::="--force-confnew" --force-yes -o Dpkg::Options::="--force-confdef" -fuy upgrade >> "$OutputLOG" 2>&1 & spinner $!
    echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"

    echo_task "Executing APT-Listchanges Remove"
    apt-get remove apt-listchanges --assume-yes --force-yes >> "$OutputLOG" 2>&1 & spinner $!
    echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"

    echo 'libc6 libraries/restart-without-asking boolean true' | debconf-set-selections
    if [[ $_change_aptlist == Yes ]]; then
        echo -e "\n\n\n${baihongse}executing apt sources change${normal}\n\n\n"
        cp /etc/apt/sources.list /etc/apt/sources.list."$(date "+%Y.%m.%d.%H.%M.%S")".bak
        wget --no-check-certificate -O /etc/apt/sources.list https://github.com/Aniverse/inexistence/raw/master/00.Installation/template/$DISTROL.apt.sources
        [[ $DISTROL == debian ]] && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5C808C2B65558117
    else
        sed -i "s/$CODENAME/RELEASE/g" /etc/apt/sources.list
    fi

    echo
    echo_task "${baihongse}Executing Upgrade Process${normal}"
    echo

    ((SysSupport = SysSupport - upgrade_version_gap))
    UPGRADE_CODENAME_OLD=RELEASE
    while [[ $upgrade_version_gap != 0 ]] ; do

        ((SysSupport = SysSupport + 1))
        ((upgrade_version_gap = upgrade_version_gap - 1))
        _SysSupport_to_DisrtoCodename

        echo
        echo_task "Upgrade to ${cyan}${bold}${UPGRADE_DISTRO}${normal}"
        echo

        echo_task "Preparation"
        sed -i "s/$UPGRADE_CODENAME_OLD/$UPGRADE_CODENAME/g" /etc/apt/sources.list >> "$OutputLOG" 2>&1
        UPGRADE_CODENAME_OLD=$UPGRADE_CODENAME
        apt-get -y update >> "$OutputLOG" 2>&1 & spinner $!
        echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"

        echo_task "Executing APT Upgrade"
        apt-get --force-yes -o Dpkg::Options::="--force-confnew" --force-yes -o Dpkg::Options::="--force-confdef" -fuy upgrade >> "$OutputLOG" 2>&1 & spinner $!
        echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"

        echo_task "Executing APT Dist-Upgrade"
        apt-get --force-yes -o Dpkg::Options::="--force-confnew" --force-yes -o Dpkg::Options::="--force-confdef" -fuy dist-upgrade >> "$OutputLOG" 2>&1 & spinner $!
        echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"

    done

    echo
    echo_task "${baihongse}Executing Post-Upgrade Process${normal}"
    echo

    echo
    echo_task "Executing APT Autoremove"
    apt-get -fuy --force-yes autoremove >> "$OutputLOG" 2>&1 & spinner $!
    echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"

    echo_task "Executing APT Clean"
    apt-get --force-yes clean >> "$OutputLOG" 2>&1 & spinner $!
    echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"

    echo && _time upgradation

    echo -e "\n${shanshuo}${baihongse}Reboot system now. You need to rerun this script after reboot${normal}\n"

    sleep 5
    reboot -f
    init 6

    sleep 5
    kill -s TERM $TOP_PID
    exit 0 ;
}

function _oscheck() {
    upgradable=0
    if [[ $SysSupport == 4 ]]; then
        echo -e "\n${green}${bold}Excited! Your operating system is already the latest version.${normal}\n"
    elif [[ $SysSupport != 0 ]]; then
        echo -e "\nYou are now running ${cyan}${bold}$DISTRO $osversion${normal}"
        upgradable=1
    else
        echo -e "\n${bold}${red}Too young too simple! Only Debian 7/8/9 and Ubuntu 14.04/16.04 is supported by this script${normal}\n"
    fi ;
}

if [[ $EUID != 0 ]]; then
    echo -e "\n${bold}${red}Naive! I think this young man will not be able to run this script without root privileges.${normal}\n"
else
    _oscheck
    [[ $upgradable == 1 ]] && _ask_upgrade
fi
