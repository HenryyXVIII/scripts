#!/bin/bash
#
# Ersteller: Henry
#
# Prüft Nexcloud Version durch Commando um Abhängikeiten (wie Apps) zu berücksichtiegen
# Installieren
# 
# check in Verzeichnis packen und ausführungs Berechtigungen setzen
# 
# 
# =>chmod +x check_ncvshell.sh
# 
# path: /usr/lib/nagios/plugins/ext/
# 
# Permissions
# Berechtigungen für User nagios setzet
# 
# =>visudo
# 
# nagios ALL=(www-data) NOPASSWD: /usr/bin/php /var/www/nextcloud/occ update\:check
# 


#Command
OCC_OUTPUT=$(sudo -u www-data php /var/www/nextcloud/occ update:check 2>&1)

EXIT_CODE=$?

# FEHLERABFANG: Wenn der Befehl selbst fehlschlägt (z.B. wegen Sudo-Rechten)
if [ $EXIT_CODE -ne 0 ] && [[ "$OCC_OUTPUT" != *"available"* ]]; then
    echo "CRITICAL: Befehl konnte nicht ausgeführt werden! Fehler: $OCC_OUTPUT"
    exit 2 # Status 2 = CRITICAL im Monitoring
fi

#Abfrage Version
if [[ "$OCC_OUTPUT" == *"available"* ]]; then
        #Wenn Ausgabe "availblae enthält wird folgendes ausgeführt"
        VERSION=$(echo "$OCC_OUTPUT" | grep -oE "Nextcloud [0-9.]+" | awk '{print $2}')
        echo "CRITICAL: Nextcloud-Update $VERSION available"
        echo "Details: $OCC_OUTPUT"

        #Ausgabe Critical
        exit 2

else
        #Wenn nicht alles in Ordnung
        echo "OK: Nextcloud ist auf dem neuesten Stand."
        exit 0
fi
