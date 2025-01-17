#!/bin/bash

script_version="1.0"

# macOS Installation Timestamp
os_installation_timestamp=$(system_profiler SPSoftwareDataType | awk -F ": " '/Install Date/ {print $2}')
# macOS-formatierte Zeit konvertieren
install_date=$(date -j -f "%b %d, %Y %H:%M:%S" "$os_installation_timestamp" +"%s")

# Aktuelles Datum in Sekunden
current_date=$(date +"%s")

# Systemalter in Jahren berechnen
age_in_years=$(echo "scale=2; ($current_date - $install_date) / 31556926" | bc)

# Benutzereingabe: E-Mail-Adresse
echo "Please enter your email address:"
read -r user_email

# Daten sammeln
data=$(cat <<EOF
{
    "script_version": "$script_version",
    "user": "$user_email",
    "minimum_age_in_years": "$age_in_years",
    "operating_system": "$(sw_vers -productName)",
    "os_version": "$(sw_vers -productVersion)",
    "os_build": "$(sw_vers -buildVersion)",
    "device_name": "$(scutil --get ComputerName)",
    "system_uuid": "$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/ { print $4 }' | tr -d '"')",
    "serial_number": "$(ioreg -l | awk '/IOPlatformSerialNumber/ {print $4}' | tr -d '"')",
    "disk_drive": "$(diskutil list | grep -A 1 "Apple_APFS" | tail -n 1 | awk '{print $3}')",
    "memory": "$(sysctl hw.memsize | awk '{printf "%.2f GB", $2/1024/1024/1024}')",
    "processor": "$(sysctl -n machdep.cpu.brand_string)",
    "graphics_cards": "$(system_profiler SPDisplaysDataType | awk -F ": " '/Chipset Model|VRAM/ {print $2}' | paste - - | sed 's/\t/, VRAM: /g')"
}
EOF
)

# Timestamp für Dateiname generieren
timestamp=$(date +"%Y-%m-%d_%H%M%S")

# Exportiere die Daten als JSON
output_path="$HOME/Documents/${timestamp}-${user_email}-client-info.json"
echo "$data" > "$output_path"

# Erfolgsmeldung
echo "The data has been successfully exported as a JSON file:"
echo "$output_path"
