#!/bin/bash

# SCRIPT POST-INSTALL PERSONALIZZATO
# Ottimizzato per Intune su macOS
# Autore: FIS & STM @ MMN Bechtle Group

logfile="/var/log/dockutil_script.log"
DOCKUTIL="/usr/local/bin/dockutil"

# Verifica esecuzione come root
if [[ $EUID -ne 0 ]]; then
    echo "$(date) - ERROR: Questo script deve essere eseguito come root. Uscita." | tee -a "$logfile"
    exit 1
fi

# Identifica l'utente attivo
LOGGED_IN_USER=$(stat -f %Su /dev/console)
USER_ID=$(id -u "$LOGGED_IN_USER")

echo "$(date) - INFO: Utente attivo rilevato: $LOGGED_IN_USER" | tee -a "$logfile"

# Funzione per il logging
log_message() {
    echo "$(date) - $1" | tee -a "$logfile"
}

# Rimuove le app dal Dock per l'utente attivo
remove_apps_from_dock() {
    if ! command -v "$DOCKUTIL" &>/dev/null; then
        log_message "ERROR: dockutil non installato. Impossibile rimuovere app dal Dock."
        return
    fi

    for app in "${apps_to_remove[@]}"; do
        log_message "INFO: Rimozione di $app dal Dock per $LOGGED_IN_USER..."
        launchctl asuser "$USER_ID" sudo -u "$LOGGED_IN_USER" "$DOCKUTIL" --remove "$app" --no-restart
    done

    # Riavvia il Dock per applicare le modifiche
    launchctl asuser "$USER_ID" sudo -u "$LOGGED_IN_USER" killall Dock
}

# Lista delle app da rimuovere dal Dock
apps_to_remove=(
    "/System/Applications/TV.app"
    "/System/Applications/FaceTime.app"
    "/System/Applications/Calendar.app"
    "/System/Applications/Messages.app"
    "/System/Applications/Maps.app"
    "/System/Applications/Photos.app"
    "/System/Applications/Launchpad.app"
    "/Applications/Safari.app"
    "/System/Applications/Mail.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Notes.app"
    "/System/Applications/Freeform.app"
    "/System/Applications/Music.app"
    "/System/Applications/App Store.app"
    "/System/Applications/Contacts.app"
)

# Avvio dello script
log_message "INFO: Script post-install avviato."
remove_apps_from_dock
log_message "INFO: Script completato con successo."
exit 0
