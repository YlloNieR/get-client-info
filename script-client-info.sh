#!/bin/bash

script_version="1.0"

# Get current timestamp
os_installation_timestamp=$(system_profiler SPSoftwareDataType | grep "Install Date" | awk -F ": " '{print $2}')
system_uuid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/ { print $4 }' | tr -d '"')

# Calculate system age in years
install_date=$(date -j -f "%B %d, %Y" "$os_installation_timestamp" +"%s")
current_date=$(date +"%s")
age_in_years=$(echo "scale=2; ($current_date - $install_date) / 31556926" | bc)

# Prompt user for email address
echo "Please enter your email address:"
read -r user_email

# Collect data
data=$(cat <<EOF
{
    "script_version": "$script_version",
    "user": "$user_email",
    "minimum_age_in_years": "$age_in_years",
    "operating_system": "$(sw_vers -productName)",
    "os_version": "$(sw_vers -productVersion)",
    "os_build": "$(sw_vers -buildVersion)",
    "device_name": "$(scutil --get ComputerName)",
    "system_uuid": "$system_uuid",
    "serial_number": "$(ioreg -l | grep IOPlatformSerialNumber | awk -F '"' '{print $4}')",
    "disk_drives": "$(diskutil list | grep -A 1 "Apple_APFS" | tail -n 1 | awk '{print $3}')",
    "memory": "$(sysctl hw.memsize | awk '{printf "%.2f GB", $2/1024/1024/1024}')",
    "processor": "$(sysctl -n machdep.cpu.brand_string)",
    "graphics_cards": "$(system_profiler SPDisplaysDataType | grep -E 'Chipset Model|VRAM' | awk -F ': ' '{print $2}' | paste - - | sed 's/\t/, VRAM: /g')"
}
EOF
)

# Export to JSON
timestamp=$(date +"%Y-%m-%d_%H%M%S")
output_path="$HOME/Documents/${timestamp}-${user_email}-${system_uuid}-client-info.json"

echo "$data" | jq . > "$output_path"

echo "The data has been successfully exported as a JSON file:"
echo "$output_path"
