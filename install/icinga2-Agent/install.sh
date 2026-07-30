#!/bin/bash

## Autor 

set -Eeuo pipefail

# sudo? #
#sudo -n true
#test $? -eq 0 || {
#    echo "you should have sudo privilege to run this script"
#    exit 1
#    }

# test if runn as root #
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#VARS
DATE=$(date '+%F_%H-%M-%S')
LOGFILE="/var/log/icinga2-install-${DATE}.log"



log() {
    echo "=> [$(date '+%F %T')] $*" | tee -a "$LOGFILE"
}





source /etc/os-release

log "OS detektion"
log "detect $NAME"
log "Install for $ID"


##ALT
#source /etc/os-release && distro=$NAME
#DIST=$(echo "$VERSION" | awk -F"[()]" '{print $2}')
#DIST=$(awk -F"[)(]+" '/VERSION=/ {print $2}' /etc/os-release)



##Distro Wahl


log "Distro Wahl"
if [ "$ID" = "debian" ]

# DEBIAN #

then

    log "$ID"
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

    



elif [ "$ID" = "ubuntu" ]

# UBUNTU #

then

    log "$ID"
    log "Paketlisten Aktualisieren"
    log "Abhängikeiten installieren"
    apt update && apt -y install apt-transport-https wget

    wget -O icinga-archive-keyring.deb "https://packages.icinga.com/icinga-archive-keyring_latest+ubuntu$VERSION_ID.deb"
    log "icinga2 key downloaden"

    apt -y install ./icinga-archive-keyring.deb
    log "installation key"

    . /etc/os-release
    if [ ! -z ${UBUNTU_CODENAME+x} ]
    
    then DIST="${UBUNTU_CODENAME}"
    else DIST="$(lsb_release -c| awk '{print $2}')"
    fi
 
    echo "deb [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/ubuntu icinga-${DIST} main" > \
    /etc/apt/sources.list.d/${DIST}-icinga.list
 
    echo "deb-src [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/ubuntu icinga-${DIST} main" >> \
    /etc/apt/sources.list.d/${DIST}-icinga.list
    log "add sourcelist"

    apt install icinga2 monitoring-plugins
    log "install icinga and monitoring Plugins"

    icinga2 daemon -C
    rm ./icinga-archive-keyring.deb
    log "löschen des keys"



elif [ "$ID" = "rhel" ]

# RHEL #

then

    log "$ID"
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

    log "$ID"
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

   log "install for $ID"
    #Pakete
   echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
   echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
   log "update repositories"
   
   apk update
   log "update apk"
   
   #Installation
   apk add icinga2 monitoring-plugins icinga2-vim
   log "add packages"

# FEHLER #

else
    log "$ID"
    exit 1
    log "fehlgeschlagen"
    log "distro not found"

fi

#log "Installation fertig, bitte starte den Nodewizard 'icinga2 node Wizard' oder konfiguriere selbst unter /etc/icinga2/" 
log "erfolgreich"
log "installation done, choose how to proceed"



while true
do
    read -p " - expermimental - Do you want configure Agent (Yes,Wizard,No)? (Y/w/n) " RETURN < /dev/tty
    case "$RETURN" in
        [Yy][Jj]|[Yy]|[Jj]|"")
        
            #konfiguration
            log "konfiguartion"
            log "start konfiguration"

            AGENTCN=$(hostname -f 2>/dev/null || cat /etc/hostname 2>/dev/null || hostname)
            PARENTCN=satelite.locales.lab
            PARENTIP="192.168.69.42"
            PARENTPORT="5665"
            PARENTZONE="Entenhausen"

            #test mit Nodewizard (schmutzig)
            : '
            # Start NodeWizard #
            icinga2 node Wizard
            echo "n\$HOSTFQDN\$ENDPOINTIP\$ICINGAENPOINT\Y"
            '
            
            : '           
            icinga2 node setup \
                --ticket "$TICKET" \
                --endpoint $ICINGAENPOINT,$ENDPOINTIP,$ICINGAPORT \
                --zone satellite-zone \
                --parent_zone $CLUSTERZONE \
                --parent_host $ENDPOINTIP \
                --trustedcert /etc/icinga2/pki/trusted-parent.crt \
                --cn "$HOSTFQDN" \
                --accept-config \
                --accept-commands
            '
            
            icinga2 node setup \
              --cn "$AGENTCN" \
              --endpoint "$PARENTCN","$PARENTIP","$PARENTPORT" \
              --zone "$AGENTCN" \
              --parent_zone "$PARENTZONE" \
              --parent_host "$PARENTCN" \
              --accept-commands \
              --accept-config \
              --disable-confd \
              --global_zones "global-templates" "director-global"
            
            break
            ;;
         [Ww])
            #keine konfig
            log "start nodewizard"
            icinga2 node wizard
            break
            ;;    
        [Nn])
            #keine konfig
            log "keine weiteren konfigurationen nötig"

            break
            ;;
        *)
            #falsche eingabe
          
            log "eingabe ungültig"
            ;;
    esac
done
exit
