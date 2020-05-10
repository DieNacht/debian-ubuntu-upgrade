#!/bin/bash
#
# https://github.com/DieNacht/debian-ubuntu-upgrade
# Author: DieNacht
#
# Thanks to amefs and Aniverse

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

OPTS=$(getopt -a -o v:m:l:,u,c --long "version:,mirror:,logbase:,upgrade,only-mirror-change,no-mirror-change" -- "$@")
eval set -- "$OPTS"

while [ -n "$1" ] ; do case "$1" in
    -v | --version  ) version="$2"  ; shift 2 ;;
    -m | --mirror   ) mirror="$2"   ; shift 2 ;;
    -l | --logbase  ) LogTimes="$2" ; shift 2 ;;
    --no-mirror-change   ) only_upgrade=1 ; shift ;;
    --only-mirror-change ) only_mirror=1  ; shift ;;
    --    ) shift ; break ;;
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

    if [[ -z $mirror ]] ; then
        echo
        echo -e  "${white}00)${normal} Change to ${cyan}Official ${normal}Mirror"        
        echo -e  "${white}01)${normal} Change to ${cyan}United States ${normal}Mirror"
        echo -e  "${white}02)${normal} Change to ${cyan}Australia ${normal}Mirror"
        echo -e  "${white}03)${normal} Change to ${cyan}China ${normal}Mirror"
        echo -e  "${white}04)${normal} Change to ${cyan}France ${normal}Mirror"
        echo -e  "${white}05)${normal} Change to ${cyan}Germeny ${normal}Mirror"
        echo -e  "${white}06)${normal} Change to ${cyan}Japan ${normal}Mirror"
        echo -e  "${white}07)${normal} Change to ${cyan}Russia ${normal}Mirror"
        echo -e  "${white}08)${normal} Change to ${cyan}United Kingdom ${normal}Mirror"
        echo -e   "${blue}11)${normal} Change to ${cyan}TUNA ${normal}Mirror"
        echo -e   "${blue}12)${normal} Change to ${cyan}USTC ${normal}Mirror"
        echo -e   "${blue}13)${normal} Change to ${cyan}MIT ${normal}Mirror"
        echo -e  "${green}21)${normal} Change to ${cyan}Netease(163) ${normal}Mirror"
        echo -e  "${green}22)${normal} Change to ${cyan}Huawei Cloud ${normal}Mirror"
        echo -e  "${green}23)${normal} Change to ${cyan}Aliyun ${normal}Mirror"
        echo -e "${yellow}31)${normal} Change to ${cyan}Hetzner ${normal}Mirror (ONLY for Hetzner Server)"
        echo -e "${yellow}32)${normal} Change to ${cyan}Online SAS ${normal}Mirror (ONLY for Online SAS Server)"
        echo -e "${yellow}33)${normal} Change to ${cyan}OVH ${normal}Mirror"
        echo -e "${yellow}34)${normal} Change to ${cyan}Leaseweb ${normal}Mirror"
        echo -e "${yellow}35)${normal} Change to ${cyan}Ikoula ${normal}Mirror"
        echo -e    "${red}99)${normal} Do NOT change the source list\n"

        echo -ne "${bold}${yellow}Would you like to change your source list?${normal} (Default ${cyan}99${normal}): " ; read -e responce

        case $responce in
            00 | 0)      mirror=official ;;
            01 | 1)      mirror=us       ;;
            02 | 2)      mirror=au       ;;
            03 | 3)      mirror=cn       ;;
            04 | 4)      mirror=fr       ;;
            05 | 5)      mirror=de       ;;
            06 | 6)      mirror=jp       ;;
            07 | 7)      mirror=ru       ;;
            08 | 8)      mirror=uk       ;;
            11)          mirror=tuna     ;;
            12)          mirror=ustc     ;;
            13)          mirror=mit      ;;
            21)          mirror=163      ;;
            22)          mirror=huawei   ;;
            23)          mirror=aliyun   ;;
            31)          mirror=hz       ;;
            32)          mirror=ol       ;;
            33)          mirror=ovh      ;;
            34)          mirror=lw       ;;
            35)          mirror=ik       ;;
            99 | "" | *) mirror=no       ;;
        esac
    fi

    official_mirror=0
    case $mirror in
        official) mirror_display="Official Mirror"        && official_mirror=1                           ;;
        us)       mirror_display="United States Mirror"   && official_mirror=2                           ;;
        au)       mirror_display="Australia Mirror"       && official_mirror=2                           ;;
        cn)       mirror_display="China Mirror"           && official_mirror=2                           ;;
        fr)       mirror_display="France Mirror"          && official_mirror=2                           ;;
        de)       mirror_display="Germeny Mirror"         && official_mirror=2                           ;;
        jp)       mirror_display="Japan Mirror"           && official_mirror=2                           ;;
        ru)       mirror_display="Russia Mirror"          && official_mirror=2                           ;;
        uk)       mirror_display="United Kingdom Mirror"  && official_mirror=2                           ;;
        tuna)     mirror_display="TUNA Mirror"            && mirror_url="mirrors.tuna.tsinghua.edu.cn"   ;;
        ustc)     mirror_display="USTC Mirror"            && mirror_url="mirrors.ustc.edu.cn"            ;;
        aliyun)   mirror_display="Alliyun Mirror"         && mirror_url="mirrors.aliyun.com"             ;;
        163)      mirror_display="Netease Mirror"         && mirror_url="mirrors.163.com"                ;;
        huawei)   mirror_display="Huawei Cloud Mirror"    && mirror_url="mirrors.huaweicloud.com"        ;;
        mit)      mirror_display="MIT Mirror"             && mirror_url="mirrors.mit.edu"                ;;
        hz)       mirror_display="Hetzner Mirror"         && mirror_url="mirror.hetzner.de"              ;;
        ol)       mirror_display="Online Mirror"          && mirror_url="mirrors.online.net"             ;;
        ovh)      mirror_display="OVH Mirror"             && mirror_url="$DISTROL.mirrors.ovh.net"       ;;
        lw)       mirror_display="Leaseweb Mirror"        && mirror_url="mirror.leaseweb.com"            ;;
        ik)       mirror_display="Ikoula Mirror"          && mirror_url="mirror.$DISTROL.ikoula.com"     ;;
    esac
    [[ $official_mirror == 1 ]] && [[ $DISTRO == Debian ]] && mirror_url="ftp.debian.org"
    [[ $official_mirror == 1 ]] && [[ $DISTRO == Ubuntu ]] && mirror_url="archive.ubuntu.com"   
    [[ $official_mirror == 2 ]] && [[ $DISTRO == Debian ]] && mirror_url="ftp.$mirror.debian.org"
    [[ $official_mirror == 2 ]] && [[ $DISTRO == Ubuntu ]] && mirror_url="$mirror.archive.ubuntu.com"

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
#                       OFFICIAL DEBIAN SNAPSHOT REPOS                         #
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
    elif [[ $DISTRO == Ubuntu ]]; then
        cat << EOF > /etc/apt/sources.list
#------------------------------------------------------------------------------#
#                            OFFICIAL UBUNTU REPOS                             #
#------------------------------------------------------------------------------#


###### Ubuntu Main Repos
deb http://$mirror_url/ubuntu/ RELEASE main restricted universe multiverse
deb-src http://$mirror_url/ubuntu/ RELEASE main restricted universe multiverse

###### Ubuntu Update Repos
deb http://$mirror_url/ubuntu/ RELEASE-security main restricted universe multiverse
deb-src http://$mirror_url/ubuntu/ RELEASE-security main restricted universe multiverse
deb http://$mirror_url/ubuntu/ RELEASE-updates main restricted universe multiverse
deb-src http://$mirror_url/ubuntu/ RELEASE-updates main restricted universe multiverse
deb http://$mirror_url/ubuntu/ RELEASE-backports main restricted universe multiverse
deb-src http://$mirror_url/ubuntu/ RELEASE-backports main restricted universe multiverse

###### Ubuntu Partner Repo
deb http://archive.canonical.com/ubuntu RELEASE partner
deb-src http://archive.canonical.com/ubuntu RELEASE partner
EOF
    elif [[ $DISTRO == Debian ]]; then
        cat << EOF > /etc/apt/sources.list
#------------------------------------------------------------------------------#
#                            OFFICIAL DEBIAN REPOS                             #
#------------------------------------------------------------------------------#

###### Debian Update Repos
deb http://$mirror_url/debian/ RELEASE main contrib non-free
#deb-src http://$mirror_url/debian/ RELEASE main contrib non-free
deb http://security.debian.org/ RELEASE/updates main contrib non-free
#deb-src http://security.debian.org/ RELEASE/updates main contrib non-free
deb http://$mirror_url/debian/ RELEASE-updates main contrib non-free
#deb-src http://$mirror_url/debian/ RELEASE-updates main contrib non-free
deb http://$mirror_url/debian RELEASE-backports main contrib non-free
#deb-src http://$mirror_url/debian RELEASE-backports main contrib non-free
EOF
    fi
    [[ $DISTROL == debian ]] && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5C808C2B65558117 >> "$OutputLOG" 2>&1 ;

}

################################################################################################ OS-Upgrade-Ralated Functions

function _ask_upgrade(){

#    ((max_version_gap = 4 - SysSupport))
    version_gap=0

    if [[ -z $upgrade_version_gap ]]; then
        echo
        while [[ $SysSupport < 4 ]]; do
#        while [[ $version_gap != $max_version_gap ]] ; do
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
        ((version_gap = 4 - SysSupport))
        SysSupport=4
    fi

    [ -z "$(echo $upgrade_version_gap | sed -n "/^[0-9]\+$/p")" ] && upgradable=0
    [[ $upgrade_version_gap == 0 ]] && upgradable=0
    [[ $upgrade_version_gap > $version_gap ]] && upgradable=0
#    [[ $upgrade_version_gap > $max_version_gap ]] && upgradable=0

    if [[ $upgradable == 0 ]]; then
        echo -e "\n${baizise}Your system will ${baihongse}not${baizise} be upgraded${normal}"
    else
#        ((SysSupport = SysSupport - max_version_gap + upgrade_version_gap))
        ((SysSupport = SysSupport - version_gap + upgrade_version_gap))
        _SysSupport_to_DisrtoCodename
        echo -e "\n${bold}${baiqingse}Your system will be upgraded to ${baizise}${UPGRADE_DISTRO}${baiqingse} after reboot${normal}"
        distro_upgrade | tee /etc/distro_upgrade.log
    fi ;
}

function _gen_apt_check() {

    status_lock=aptcheck
    echo "status_lock=$status_lock" > /tmp/Variables
    rm -f /tmp/$status_lock.1.lock /tmp/$status_lock.2.lock
    if [[ $ac == 0 ]]; then
        touch /tmp/$status_lock.1.lock
    else
        touch /tmp/$status_lock.2.lock
    fi

}

function _apt_update() { apt-get -y update >> "$OutputLOG" 2>&1 ; ac=$? ; _gen_apt_check ; }
function _apt_upgrade() { apt-get --force-yes -o Dpkg::Options::="--force-confnew" --force-yes -o Dpkg::Options::="--force-confdef" -fuy upgrade >> "$OutputLOG" 2>&1 ; ac=$? ; _gen_apt_check ; }
function _apt_full_upgrade() { apt-get --force-yes -o Dpkg::Options::="--force-confnew" --force-yes -o Dpkg::Options::="--force-confdef" -fuy full-upgrade >> "$OutputLOG" 2>&1 ; ac=$? ; _gen_apt_check ; }
function _apt_dist_upgrade() { apt-get --force-yes -o Dpkg::Options::="--force-confnew" --force-yes -o Dpkg::Options::="--force-confdef" -fuy dist-upgrade >> "$OutputLOG" 2>&1 ; ac=$? ; _gen_apt_check ; }
function _apt_remove_listchanges() { apt-get remove apt-listchanges --assume-yes --force-yes >> "$OutputLOG" 2>&1 ; ac=$? ; _gen_apt_check ; }
function _apt_autoremove() { apt-get -fuy --force-yes autoremove >> "$OutputLOG" 2>&1 ; ac=$? ; _gen_apt_check ; }
function _apt_clean() { apt-get --force-yes clean >> "$OutputLOG" 2>&1 ; ac=$? ; _gen_apt_check ; }

function distro_upgrade() {
    starttime=$(date +%s)

    # apt-get -f install

    ((SysSupport = SysSupport - upgrade_version_gap))
    [[ $CODENAME == wheezy ]] && force_change_source=yes
    if [[ $force_change_source == yes ]]; then
        echo -e "${baizise}Your apt source list will be ${baihongse}forced${baizise} to change${normal}\n"
    else
        _ask_source
    fi

    echo_task "${baihongse}Executing Pre-Upgrade Process${normal}"
    echo && echo

    echo_task "Executing Preparation"
    _apt_update & spinner $!
    check_status aptcheck

    echo_task "Executing APT Upgrade"
    _apt_upgrade & spinner $!
    check_status aptcheck

    echo_task "Executing APT-Listchanges Remove"
    _apt_remove_listchanges & spinner $!
    check_status aptcheck

    echo 'libc6 libraries/restart-without-asking boolean true' | debconf-set-selections

    rm -rf /etc/apt/sources.list.d/hetzner-mirror.list >> "$OutputLOG" 2>&1
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

        echo_task "Executing Preparation"
        sed -i "s/$UPGRADE_CODENAME_OLD/$UPGRADE_CODENAME/g" /etc/apt/sources.list >> "$OutputLOG" 2>&1
        UPGRADE_CODENAME_OLD=$UPGRADE_CODENAME
        _apt_update & spinner $!
        check_status aptcheck

        if [[ $UPGRADE_CODENAME =~ (buster|bionic|focal) ]]; then
            echo_task "Executing APT Full-Upgrade"
            _apt_full_upgrade & spinner $!
            check_status aptcheck
        else
            echo_task "Executing APT Upgrade"
            _apt_upgrade & spinner $!
            check_status aptcheck

            echo_task "Executing APT Dist-Upgrade"
            _apt_dist_upgrade & spinner $!
            check_status aptcheck
        fi

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
    _apt_autoremove & spinner $!
    echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"

    echo_task "Executing APT Clean"
    _apt_clean & spinner $!
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

function _only_source_mode() {

        _ask_source

        if [[ ! $mirror == no ]]; then
            echo_task "${baihongse}Change the Source List and Update${normal}"
            echo && echo

            echo_task "Change the Source List"
            _change_source & spinner $!
            echo -e " ${green}${bold}DONE${normal}" | tee -a "$OutputLOG"

            echo_task "Excuting Source Update"
            sed -i "s/RELEASE/$CODENAME/g" /etc/apt/sources.list >> "$OutputLOG" 2>&1
            _apt_update & spinner $!
            check_status aptcheck
            echo
        fi

        exit 0

}

function _oscheck() {
    upgradable=0
    if [[ $SysSupport == 4 ]] ; then
        echo -e "\n${green}${bold}Excited! Your operating system is already the latest version.${normal}\n" && _only_source_mode
    elif [[ $only_mirror == 1 ]] ; then
        _only_source_mode
    elif [[ $SysSupport != 0 ]]; then
        echo -e "\nYou are now running ${cyan}${bold}$DISTRO $osversion${normal}"
        upgradable=1
    else
        echo -e "\n${bold}${red}Too young too simple! Only Debian 7/8/9 and Ubuntu 14.04/16.04 is supported by this script${normal}\n"
    fi ;
}

################################################################################################ Set Variables 2

[[ $only_upgrade == 1 ]] && [[ $mirror != no ]] && [[ $mirror != "" ]] && { echo -e "\nERROR: You already choose to change mirror\n" ; exit 1 ; }
[[ $only_upgrade == 1 ]] && [[ -z $mirror ]] && mirror=no
[[ $only_mirror == 1 ]] && { echo -e "\nERROR: You already choose to upgrade to $version\n" ; exit 1 ; }

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

    [[ $upgrade_version_gap == 0 ]] && { echo -e "\nERROR: It's impossible to upgrade to $version\n" ; exit 1 ; }
    [[ ${upgrade_version_gap:0:1} == "-" ]] && { echo -e "\nERROR: It's impossible to upgrade to $version\n" ; exit 1 ; }
    [[ $DISTRO == Ubuntu ]] && [[ ! $version =~  (focal|bionic|xenial)  ]] && { echo -e "\nERROR: It's impossible to upgrade to $version\n" ; exit 1 ; }
    [[ $DISTRO == Debian ]] && [[ ! $version =~ (buster|stretch|jessie) ]] && { echo -e "\nERROR: It's impossible to upgrade to $version\n" ; exit 1 ; }
elif [[ -n $mirror ]] && [[ $mirror =~  (official|us|au|cn|fr|de|jp|ru|uk|tuna|ustc|aliyun|163|huawei|mit|hz|ol|ovh|lw|ik)  ]]; then
    [[ $CODENAME == wheezy ]] && force_change_source=yes && { echo -e "\nERROR: No mirror could be used to change\n" ; exit 1 ; }
    _only_source_mode
fi
[[ $only_upgrade != 1 ]] && [[ -n $mirror ]] && [[ ! $mirror =~  (official|us|au|cn|fr|de|jp|ru|uk|tuna|ustc|aliyun|163|huawei|mit|hz|ol|ovh|lw|ik)  ]] && { echo -e "\nERROR: No such mirror\n" ; exit 1 ; }
[[ -n $version ]] && [[ -z $mirror ]] && mirror=no

################################################################################################ Main

[[ $EUID != 0 ]] && { echo -e "\n${bold}${red}Naive! I think this young man will not be able to run this script without root privileges.${normal}\n" ; exit 1 ; }
_oscheck
[[ $upgradable == 1 ]] && _ask_upgrade

