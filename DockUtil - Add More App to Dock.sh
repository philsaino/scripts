#!/bin/bash

DOCKUTIL="/usr/local/bin/dockutil"
LOG_FILE="/var/log/dockutil_script.log"

# Array di percorsi delle app da aggiungere
apps_to_add=(
    "/Applications/Google Chrome.app/"
    "/Applications/Company Portal.app"
    "/Applications/Microsoft Word.app"
    "/Applications/Microsoft Excel.app"
    "/Applications/Microsoft PowerPoint.app"
    "/Applications/Microsoft Outlook.app"
    "/Applications/OneDrive.app/"
)

# Verifica esecuzione come root
if [[ $EUID -ne 0 ]]; then
    echo "Questo script deve essere eseguito come root. Uscita." | tee -a "$LOG_FILE"
    exit 1
fi

# Identifica l'utente attivo su macOS
LOGGED_IN_USER=$(stat -f %Su /dev/console)
USER_HOME="/Users/$LOGGED_IN_USER"
USER_UID=$(id -u "$LOGGED_IN_USER")

echo "Utente attivo: $LOGGED_IN_USER" | tee -a "$LOG_FILE"

# Controlla la connessione internet
check_internet() {
    if ! curl -s --head http://www.google.com | grep "200 OK" > /dev/null; then
        echo "Nessuna connessione internet. Controllare la rete." | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Aggiunge ogni app al Dock
add_apps_to_dock() {
    if ! command -v "$DOCKUTIL" &>/dev/null; then
        echo "dockutil non installato, impossibile modificare il Dock." | tee -a "$LOG_FILE"
        return
    fi

    for app_path in "${apps_to_add[@]}"; do
        if [ -d "$app_path" ]; then
            echo "Aggiunta di $app_path al Dock per $LOGGED_IN_USER..." | tee -a "$LOG_FILE"
            launchctl asuser "$USER_UID" sudo -u "$LOGGED_IN_USER" "$DOCKUTIL" --add "$app_path" --no-restart
        else
            echo "Percorso non valido: $app_path. Impossibile aggiungere al Dock." | tee -a "$LOG_FILE"
        fi
    done

    # Riavvia il Dock per applicare le modifiche
    launchctl asuser "$USER_UID" sudo -u "$LOGGED_IN_USER" killall Dock
}

# Avvio dello script
echo "Script avviato: $(date)" | tee -a "$LOG_FILE"

check_internet
echo "Connessione internet OK." | tee -a "$LOG_FILE"

echo "Aggiunta delle app al Dock..." | tee -a "$LOG_FILE"
add_apps_to_dock

echo "Script completato: $(date)" | tee -a "$LOG_FILE"
exit 0
