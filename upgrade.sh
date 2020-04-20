#!/bin/bash
#
# https://github.com/DieNacht/debian-ubuntu-upgrade
# Author: DieNacht
#
# Thanks to amefs and Aniverse

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

OPTS=$(getopt -a -o v:m:l: --long version:,mirror:,logbase: -- "$@")
eval set -- "$OPTS"

while [ -n "$1" ] ; do case "$1" in
    -v | --version    ) version="$2"               ; shift 2 ;;
    -m | --mirror     ) mirror="$2" ; shift 2 ;;
    -l | --logbase    ) LogTimes="$2"                           ; shift 2 ;;
    -- ) shift ; break ;;
esac ; done

################################################################################################ Set Variables 1

if [[ -f /etc/inexistence/00.Installation/function ]]; then
    source /etc/inexistence/00.Installation/function
else
    source <(wget -qO- https://github.com/Aniverse/inexistence/raw/master/00.Installation/function)
fi

set_variables_log_location
check_var_OutputLOG
debug_log_location
cat_outputlog

################################################################################################ Set Variables 2

SysSupport=0
[[ $CODENAME  ==  focal   ]] && SysSupport=4
[[ $CODENAME  ==  bionic  ]] && SysSupport=3
[[ $CODENAME  ==  xenial  ]] && SysSupport=2
[[ $CODENAME  ==  trusty  ]] && SysSupport=1
[[ $CODENAME  ==  buster  ]] && SysSupport=4
[[ $CODENAME  ==  stretch ]] && SysSupport=3
[[ $CODENAME  ==  jessie  ]] && SysSupport=2
[[ $CODENAME  ==  wheezy  ]] && SysSupport=1

if [[ -n $version ]]; then
    count=0
    [[ $version  ==  focal   ]] && count=4
    [[ $version  ==  bionic  ]] && count=3
    [[ $version  ==  xenial  ]] && count=2
    [[ $version  ==  buster  ]] && count=4
    [[ $version  ==  stretch ]] && count=3
    [[ $version  ==  jessie  ]] && count=2

    ((upgrade_version_gap = count - SysSupport))

    [[ ! $upgrade_version_gap > 0 ]] && { echo -e "\n${baihongse}ERROR: Can't uprade to $version${normal}\n" ; exit 1 ; }
    [[ $DISTRO == Ubuntu ]] && [[ ! $version =~  (focal|bionic|xenial)  ]] && { echo -e "\n${baihongse}ERROR: Can't uprade to $version${normal}\n" ; exit 1 ; }
    [[ $DISTRO == Debian ]] && [[ ! $version =~ (buster|stretch|jessie) ]] && { echo -e "\n${baihongse}ERROR: Can't uprade to $version${normal}\n" ; exit 1 ; }
    [[ -z $mirror ]] && mirror=no ;

fi
[[ -n $mirror ]] && [[ ! $mirror =~  (us|au|cn|fr|de|jp|ru|uk|no)  ]] && { echo -e "\n${baihongse}ERROR: No such mirror${normal}\n" ; exit 1 ; }

################################################################################################ Sub Functions

function _SysSupport_to_DisrtoCodename (){
    [[ $SysSupport == 4  ]] && [[ $DISTRO == Ubuntu ]] && { UPGRADE_DISTRO="Ubuntu 20.04" ; UPGRADE_CODENAME=focal   ; }
    [[ $SysSupport == 3  ]] && [[ $DISTRO == Ubuntu ]] && { UPGRADE_DISTRO="Ubuntu 18.04" ; UPGRADE_CODENAME=bionic  ; }
    [[ $SysSupport == 2  ]] && [[ $DISTRO == Ubuntu ]] && { UPGRADE_DISTRO="Ubuntu 16.04" ; UPGRADE_CODENAME=xenial  ; }
    [[ $SysSupport == 4  ]] && [[ $DISTRO == Debian ]] && { UPGRADE_DISTRO="Debian 10"    ; UPGRADE_CODENAME=buster  ; }
    [[ $SysSupport == 3  ]] && [[ $DISTRO == Debian ]] && { UPGRADE_DISTRO="Debian 9"     ; UPGRADE_CODENAME=stretch ; }
    [[ $SysSupport == 2  ]] && [[ $DISTRO == Debian ]] && { UPGRADE_DISTRO="Debian 8"     ; UPGRADE_CODENAME=jessie  ; } ;
}

################################################################################################ APT-Source-Ralated Functions

function _ask_source(){

    if [[ -z $mirror ]]; then
        echo
        echo -e "${blue}01)${normal} Change to ${cyan}United States ${normal}Source"
        echo -e "${blue}02)${normal} Change to ${cyan}Australia ${normal}Source"
        echo -e "${blue}03)${normal} Change to ${cyan}China ${normal}Source"
        echo -e "${blue}04)${normal} Change to ${cyan}France ${normal}Source"
        echo -e "${blue}05)${normal} Change to ${cyan}Germeny ${normal}Source"
        echo -e "${blue}06)${normal} Change to ${cyan}Japan ${normal}Source"
        echo -e "${blue}07)${normal} Change to ${cyan}Russia ${normal}Source"
        echo -e "${blue}08)${normal} Change to ${cyan}United Kingdom ${normal}Source"
        echo -e  "${red}09)${normal} Do NOT change the source list\n"

        echo -ne "${bold}${yellow}Would you like to change your source list?${normal} (Default ${cyan}09${normal}): " ; read -e responce

        case $responce in
            01 | 1) mirror=us ;;
            02 | 2) mirror=au ;;
            03 | 3) mirror=cn ;;
            04 | 4) mirror=fr ;;
            05 | 5) mirror=de ;;
            06 | 6) mirror=jp ;;
            07 | 7) mirror=ru ;;
            08 | 8) mirror=uk ;;
            09 | 9) mirror=no ;;
            "" | *) mirror=no ;;
        esac
    fi

    [[ $mirror == us ]] && mirror_display="United States Source"
    [[ $mirror == au ]] && mirror_display="Australia Source"
    [[ $mirror == cn ]] && mirror_display="China Source"
    [[ $mirror == fr ]] && mirror_display="France Source"
    [[ $mirror == de ]] && mirror_display="Germeny Source"
    [[ $mirror == jp ]] && mirror_display="Japan Source"
    [[ $mirror == ru ]] && mirror_display="Russia Source"
    [[ $mirror == uk ]] && mirror_display="United Kingdom Source"

    if [[ $mirror == no ]]; then
        echo -e "\n${baizise}Your apt source list will ${baihongse}not${baizise} be changed${normal}\n"
    else
        echo -e "\n${bold}${baiqingse}Your apt source list will be changed to ${baizise}${mirror_display}${normal}\n"
    fi

}

function _change_source() {

    cp /etc/apt/sources.list /etc/apt/sources.list."$(date "+%Y.%m.%d.%H.%M.%S")".bak >> "$OutputLOG" 2>&1
    rm -rf /etc/apt/sources.list.d/hetzner-mirror.list >> "$OutputLOG" 2>&1
    if [[ $force_change_source == yes ]]; then
        cat << EOF > /etc/apt/sources.list
#------------------------------------------------------------------------------#
#                            OFFICIAL DEBIAN REPOS                             #
#------------------------------------------------------------------------------#

###### Debian Update Repos
deb http://snapshot.debian.org/archive/debian/20190321T212815Z/ RELEASE main contrib non-free
#deb-src http://snapshot.debian.org/archive/debian/20190321T212815Z/ RELEASE main contrib non-free
deb http://snapshot.debian.org/archive/debian/20190321T212815Z/ RELEASE/updates main contrib non-free
#deb-src http://snapshot.debian.org/archive/debian/20190321T212815Z/ RELEASE/updates main contrib non-free
deb http://snapshot.debian.org/archive/debian/20190321T212815Z/ RELEASE-updates main contrib non-free
#deb-src http://snapshot.debian.org/archive/debian/20190321T212815Z/ RELEASE-updates main contrib non-free
deb http://snapshot.debian.org/archive/debian/20190321T212815Z/ RELEASE-backports main contrib non-free
#deb-src http://snapshot.debian.org/archive/debian/20190321T212815Z/ RELEASE-backports main contrib non-free
EOF
        echo 'Acquire::Check-Valid-Until 0;' > /etc/apt/apt.conf.d/10-no-check-valid-until
    else
        wget --no-check-certificate -O /etc/apt/sources.list https://github.com/amefs/quickbox-lite/raw/master/setup/templates/source.list/$DISTROL.template >> "$OutputLOG" 2>&1
    	sed -i "s/COUNTRY/${mirror}/g" /etc/apt/sources.list >> "$OutputLOG" 2>&1
    fi
    [[ $DISTROL == debian ]] && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5C808C2B65558117 >> "$OutputLOG" 2>&1 ;

}

################################################################################################ OS-Upgrade-Ralated Functions

function _ask_upgrade(){

    ((max_version_gap = 4 - SysSupport))
    version_gap=0

    if [[ -z $upgrade_version_gap ]]; then
        echo
        while [[ $version_gap != $max_version_gap ]] ; do
            ((SysSupport = SysSupport + 1))
            ((version_gap = version_gap + 1))
            _SysSupport_to_DisrtoCodename
            echo -e "${green}0$version_gap)${normal} Upgrade to ${cyan}$UPGRADE_DISTRO${normal}"
        done
        ((version_gap = version_gap + 1))
        echo -e "${red}0$version_gap)${normal} Do NOT upgrade system and exit script\n"

        echo -ne "${bold}${yellow}Would you like to upgrade your system?${normal} (Default ${cyan}0$version_gap${normal}): " ; read -e responce
        ((version_gap = version_gap - 1))
        upgrade_version_gap=${responce:0-1:1}
    else
        SysSupport=4
    fi

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

function distro_upgrade() {
    starttime=$(date +%s)

    # apt-get -f install

    ((SysSupport = SysSupport - upgrade_version_gap))
    [[ $DISTRO == Debian ]] && [[ $SysSupport == 1 ]] && force_change_source=yes
    if [[ $force_change_source == yes ]]; then
        echo -e "${baizise}Your apt source list will be ${baihongse}forced${baizise} to change${normal}\n"
    else
        _ask_source
    fi

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

    if [[ $mirror == no ]]; then
        sed -i "s/$CODENAME/RELEASE/g" /etc/apt/sources.list
    else
        echo_task "Change the Source List${normal}"
        _change_source & spinner $!
        echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"
    fi

    echo
    echo_task "${baihongse}Executing Upgrade Process${normal}"
    echo

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

        if [[ $force_change_source == yes ]]; then
            echo_task "Change the Source List${normal}"
            mirror=de && force_change_source=no
            _change_source & spinner $!
            echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"
            sed -i "s/RELEASE/$UPGRADE_CODENAME/g" /etc/apt/sources.list >> "$OutputLOG" 2>&1
        fi

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

################################################################################################ Main

[[ $EUID != 0 ]] && { echo -e "\n${bold}${red}Naive! I think this young man will not be able to run this script without root privileges.${normal}\n" ; exit 1 ; }
_oscheck
[[ $upgradable == 1 ]] && _ask_upgrade

