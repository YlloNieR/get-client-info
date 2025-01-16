$ps1ScriptVersion = "1.0"

$OsInstallationTimestamp = (Get-CimInstance -ClassName Win32_OperatingSystem).InstallDate | Get-Date -Format "yyyy-MM-dd HH:mm"

# Get the SystemUUID installation date
$SystemUUID = (Get-CimInstance -ClassName Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID)

# Get the Windows installation date
$installDate = (Get-CimInstance -ClassName Win32_OperatingSystem).InstallDate

# Get the current date
$today = Get-Date

# Calculate the age in years (difference in days divided by 365)
$ageInYears = ($today - $installDate).Days / 365

# Format the age as a two-decimal number and output the result
$ageInYearsFormatted = "{0:N2}" -f $ageInYears

# Prompt user for email address
Write-Host "✎ Please enter your email address ✎" -ForegroundColor Yellow
$userEmail = Read-Host

# set timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"


# Collect data without admin rights
$data = @{
    "ps1_Script_Version" = $ps1ScriptVersion
    "User" = $userEmail
    "Minimum_Age_in_y" = $ageInYearsFormatted
    "Operating_System" = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty Caption)
    "OS_Version" = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty Version)
    "OS_Architecture" = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty OSArchitecture)
    "OS_Installation_Timestamp" = $OsInstallationTimestamp
    "Device_Name" = $env:COMPUTERNAME
    "BIOS_Serial_Number" = (Get-CimInstance -ClassName Win32_BIOS | Select-Object -ExpandProperty SerialNumber)
    "System_Model" = (Get-CimInstance -ClassName Win32_ComputerSystem | ForEach-Object {
        [PSCustomObject]@{
            "Manufacturer" = $_.Manufacturer
            "Model" = $_.Model
        }
    })
    "MAC_Addresses" = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } | Select-Object Description, MACAddress | ForEach-Object {
        [PSCustomObject]@{
            "Adapter" = $_.Description
            "MAC_Address" = $_.MACAddress
        }
    })
    "Processor_ID" = (Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty ProcessorId)
    "Disk_Drives" = (Get-CimInstance -ClassName Win32_DiskDrive | ForEach-Object {
        [PSCustomObject]@{
            "Model" = $_.Model
            "Size" = "{0:N2} GB" -f ($_.Size / 1GB)
        }
    })
    "Memory" = (Get-CimInstance -ClassName Win32_PhysicalMemory | ForEach-Object {
        [PSCustomObject]@{
            "Manufacturer" = $_.Manufacturer
            "Capacity" = "{0:N2} GB" -f ($_.Capacity / 1GB)
        }
    })
    "System_UUID" = (Get-CimInstance -ClassName Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID)
    "Graphics_Cards" = (Get-CimInstance -ClassName Win32_VideoController | ForEach-Object {
        [PSCustomObject]@{
            "Name" = $_.Name
            "Driver_Version" = $_.DriverVersion
        }
    })
}

# Export data to JSON file
$jsonFilePath = "$env:USERPROFILE\Desktop\"+$timestamp+"-"+$userEmail+"-"+$SystemUUID+"-client-info.json"
$data | ConvertTo-Json -Depth 3 | Set-Content -Path $jsonFilePath

Write-Host "✌ The data has been successfully exported as a JSON file: $jsonFilePath" -ForegroundColor Green