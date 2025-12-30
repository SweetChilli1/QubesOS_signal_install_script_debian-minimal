#!/bin/bash

# Überprüfen der Root-Rechte
if [ "$EUID" -ne 0 ]; then
    echo "Bitte als Root oder mit sudo ausführen."
    exit 1
fi

# Fehlerarray für Fehlermeldungen
errors=()

# Überprüfen, ob wget installiert ist, falls nicht, installieren
if ! command -v wget &> /dev/null; then
    echo "Wget ist nicht installiert. Installiere wget..."
    if output=$(apt-get update 2>&1); then
        : # Nichts tun
    else
        errors+=("Fehler beim Aktualisieren der Paketdatenbank: $output")
    fi
    if output=$(apt-get install -y wget 2>&1); then
        : # Nichts tun
    else
        errors+=("Fehler beim Installieren von wget: $output")
    fi
fi

# Überprüfen, ob gpg installiert ist
if ! command -v gpg &> /dev/null; then
    errors+=("GPG ist nicht installiert.")
fi

# Proxy für wget konfigurieren
export http_proxy="http://127.0.0.1:8082"
export https_proxy="http://127.0.0.1:8082"

# 1. Installiere den offiziellen Software-Signaturschlüssel
echo "Installiere den offiziellen Software-Signaturschlüssel..."
if output=$(wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg 2>&1); then
    : # Nichts tun
else
    errors+=("Fehler beim Herunterladen des Software-Signaturschlüssels: $output")
fi
if output=$(cat signal-desktop-keyring.gpg | tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null 2>&1); then
    : # Nichts tun
else
    errors+=("Fehler beim Speichern des Signaturschlüssels: $output")
fi

# 2. Füge das Repository deiner Liste der Repositories hinzu
if output=$(wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources 2>&1); then
    : # Nichts tun
else
    errors+=("Fehler beim Herunterladen des Repositories: $output")
fi
if output=$(cat signal-desktop.sources | tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null 2>&1); then
    : # Nichts tun
else
    errors+=("Fehler beim Hinzufügen des Repositories zur Liste: $output")
fi

# 3. Aktualisiere die Paketdatenbank und installiere Signal
PACKAGES=(
  "signal-desktop"
  "qubes-core-agent-networking"
  "dunst"
  "fonts-noto-color-emoji"
)

PACKAGES_NO_INSTALL_RECOMMENDS=(
  "pipewire-pulse"
  "wireplumber"
)

echo "Aktualisiere die Paketdatenbank und installiere Pakete..."
if output=$(apt-get update 2>&1); then
    : # Nichts tun
else
    errors+=("Fehler beim Aktualisieren der Paketdatenbank: $output")
fi
if output=$(apt-get install -y "${PACKAGES[@]}" 2>&1); then
    : # Nichts tun
else
    errors+=("Fehler beim Installieren der Pakete: $output")
fi
if output=$(apt-get install -y --no-install-recommends "${PACKAGES_NO_INSTALL_RECOMMENDS[@]}" 2>&1); then
    : # Nichts tun
else
    errors+=("Fehler beim Installieren der optionalen Pakete: $output")
fi

# Überprüfen, ob Fehler aufgetreten sind und entsprechende Meldungen ausgeben
if [ ${#errors[@]} -gt 0 ]; then
    echo "Die folgenden Fehler sind aufgetreten:"
    for error in "${errors[@]}"; do
        echo "- $error"
    done
else
    # Fertigstellungsmeldung
    echo "Alle Pakete wurden erfolgreich installiert!"
fi

