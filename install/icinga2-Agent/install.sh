#!/bin/bash

## Autor 

set -Eeuo pipefail
sudo -n true
test $? -eq 0 || {
    exit 1
    echo "you should have sudo privilege to run this script"
    }
    
LOGFILE="/var/log/icinga-install.log"

log() {
    echo "[$(date '+%F %T')] $*" >> tee -a "$LOGFILE"
}
#VARS




source /etc/os-release

log "OS detektion"
echo "detect $NAME"
echo "Install for $ID"


##ALT
#source /etc/os-release && distro=$NAME
#DIST=$(echo "$VERSION" | awk -F"[()]" '{print $2}')
#DIST=$(awk -F"[)(]+" '/VERSION=/ {print $2}' /etc/os-release)



##Distro Wahl


log "Distro Wahl"
if [ "$ID" = "debian" ]

# DEBIAN #

then

    echo "$ID"
    if [ -n "${VERSION_CODENAME:-}" ]
    then
    DIST="$VERSION_CODENAME"
    else
    DIST=$(awk -F"[)(]+" '/VERSION=/ {print $2}' /etc/os-release)
    fi

    #Basisprogramme
    apt update && apt -y install apt-transport-https wget
    log "Paketlisten Aktualisieren"
    log "Abhängikeiten installieren"
    #key
    wget -O ./icinga-archive-keyring.deb "https://packages.icinga.com/icinga-archive-keyring_latest+debian$VERSION_ID.deb"
    log "icinga2 key downloaden"
    #installation key
    apt -y install ./icinga-archive-keyring.deb
    log "installation key"
    
    #Icinga in die apt sourecliste
    echo "deb [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/debian icinga-${DIST} main" > \
    /etc/apt/sources.list.d/${DIST}-icinga.list

    echo "deb-src [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/debian icinga-${DIST} main" >> \
    /etc/apt/sources.list.d/${DIST}-icinga.list
    log "schreiben der source list"
    
    #installation Icinga
    echo "installation Icinga"
    apt update && apt -y install icinga2 monitoring-plugins
    log "installation icinga2 und monitoring plugins"

    #verifizierung
    icinga2 daemon -C
    
    #echo "installation Plugins"
    #apt -y install monitoring-plugins

    rm ./icinga-archive-keyring.deb
    log "löschen des keys"

    echo "Installation fertig, bitte starte den Nodewizard 'icinga2 node Wizard' oder konfiguriere selbst unter /etc/icinga2/" 



elif [ "$ID" = "ubuntu" ]

# UBUNTU #

then

    echo "$ID"
    apt update && apt -y install apt-transport-https wget

    wget -O icinga-archive-keyring.deb "https://packages.icinga.com/icinga-archive-keyring_latest+ubuntu$VERSION_ID.deb"

    apt -y install ./icinga-archive-keyring.deb


    . /etc/os-release
    if [ ! -z ${UBUNTU_CODENAME+x} ]
    
    then DIST="${UBUNTU_CODENAME}"
    else DIST="$(lsb_release -c| awk '{print $2}')"
    fi
 
    echo "deb [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/ubuntu icinga-${DIST} main" > \
    /etc/apt/sources.list.d/${DIST}-icinga.list
 
    echo "deb-src [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/ubuntu icinga-${DIST} main" >> \
    /etc/apt/sources.list.d/${DIST}-icinga.list

    apt install icinga2 monitoring-plugins

    icinga2 daemon -C



elif [ "$ID" = "rhel" ]

# RHEL #

then

    echo "$ID"
    dnf install -y curl wget
    wget https://packages.icinga.com/subscription/rhel/ICINGA-release.repo -O /etc/yum.repos.d/ICINGA-release.repo

    ARCH=$(/bin/arch)
    OSVER=$(. /etc/os-release; echo "${VERSION_ID%%.*}")

    subscription-manager repos --enable "codeready-builder-for-rhel-${OSVER}-${ARCH}-rpms"

    dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${OSVER}.noarch.rpm

    dnf install icinga2 nagios-plugins-all
    systemctl enable icinga2
    systemctl start icinga2






elif [ "$ID" = "fedora" ]

# FEDORA #

then

    echo "$ID"
    dnf install -y curl
    rpm --import https://packages.icinga.com/icinga.key
    curl -o /etc/yum.repos.d/ICINGA-release.repo https://packages.icinga.com/fedora/ICINGA-release.repo

    dnf install icinga2
    systemctl enable icinga2
    systemctl start icinga2
    icinga2 daemon -C


elif [ "$ID" = "alpine" ]
# Alpine #
then

    #Pakete
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

    apk update

    #Installation
    apk add -y icinga2 monitoring-plugins icinga2-vim


# FEHLER #

else
    echo "$ID"
    exit 1
    echo "fehlgeschlagen"
    log "fehler"

fi
echo script ist fertig
log "erfolgreich"

exit
