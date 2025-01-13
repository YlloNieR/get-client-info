# Prompt user for email address
$userEmail = Read-Host -Prompt "Please enter your email address"

# set timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"


# Collect data without admin rights
$data = @{
    "User" = $userEmail
    "Operating System" = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty Caption)
    "Version" = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty Version)
    "OS Architecture" = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty OSArchitecture)
    "Device Name" = $env:COMPUTERNAME
    "BIOS Serial Number" = (Get-CimInstance -ClassName Win32_BIOS | Select-Object -ExpandProperty SerialNumber)
    "System Model" = (Get-CimInstance -ClassName Win32_ComputerSystem | ForEach-Object {
        [PSCustomObject]@{
            "Manufacturer" = $_.Manufacturer
            "Model" = $_.Model
        }
    })
    "MAC Addresses" = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } | Select-Object Description, MACAddress | ForEach-Object {
        [PSCustomObject]@{
            "Adapter" = $_.Description
            "MAC Address" = $_.MACAddress
        }
    })
    "Processor ID" = (Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty ProcessorId)
    "Disk Drives" = (Get-CimInstance -ClassName Win32_DiskDrive | ForEach-Object {
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
    "System UUID" = (Get-CimInstance -ClassName Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID)
    "Graphics Cards" = (Get-CimInstance -ClassName Win32_VideoController | ForEach-Object {
        [PSCustomObject]@{
            "Name" = $_.Name
            "Driver Version" = $_.DriverVersion
        }
    })
}

# Export data to JSON file

$jsonFilePath = "$env:USERPROFILE\Desktop\"+$timestamp+"-"+$userEmail+"-client-info.json"
$data | ConvertTo-Json -Depth 3 | Set-Content -Path $jsonFilePath

Write-Output "The data has been successfully exported as a JSON file: $jsonFilePath"
