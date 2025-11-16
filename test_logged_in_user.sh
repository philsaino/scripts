#!/bin/bash

# Script di test per macOS
# Legge e mostra l'utente attualmente loggato

logged_in_user=$(stat -f%Su /dev/console)
echo "Logged in user: $logged_in_user"