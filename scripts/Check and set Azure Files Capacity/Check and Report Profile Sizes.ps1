# Import the required Azure modules
Import-Module Az.Accounts
Import-Module Az.Storage
Import-Module Az.Resources

# Define variables
$resourceGroupName = "oge-prod-001-vds-eastus2-rg"
$storageAccountName = "ogeprodvdsp01"
$fileShareName = "ogeprodvdsp0"
$subscriptionId = "edb20396-8056-4173-9c60-c0aa8905eeaa"

# Securely get and store storage account key1
$storageAccountKey = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName | Select-Object KeyName,Value | Where-Object { $_.KeyName -eq "key1" } | Select-Object -ExpandProperty Value

# Securely get and store storage connection string
$storageConnectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$storageAccountKey;EndpointSuffix=core.windows.net"

# Variables
$env:AZURE_STORAGE_CONNECTION_STRING = $storageConnectionString

# Authenticate to Azure
#Connect-AzAccount


$directoryPath = ""

$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$ctx = $storageAccount.Context

# Define global variable to store all files
$global:allFiles = @()

Function GetFiles {
    param (
        [string]$path
    )

    Write-Host -ForegroundColor Green "Lists directories and files under $path.."   
    $ctx = $storageAccount.Context

    $filesAndFolders = Get-AZStorageFile -Context $ctx -ShareName $fileShareName -Path $path | Get-AZStorageFile
    foreach($item in $filesAndFolders) {
        if ($item.GetType().Name -eq "AzureStorageFileDirectory") {
            Write-Host -ForegroundColor Red "Folder Name: " $item.Name 
            # Recursively call GetFiles for subdirectories
            GetFiles -path (Join-Path -Path $path -ChildPath $item.Name)
        }
    }
    foreach($item in $filesAndFolders) {
        if ($item.GetType().Name -eq "AzureStorageFile") {
            Write-Host -ForegroundColor Yellow "File Name: " $item.Name 
            # Add file to the global allFiles list
            $global:allFiles += $item
        }
    }
} 

# Call GetFiles for the root directory
GetFiles -path $directoryPath

# Filter the files to include only those ending with .VHDK
$vhdkFiles = $global:allFiles

# Loop through each .VHDK file and calculate its size
foreach ($file in $vhdkFiles) {
    $fileName = $file.Name
    $fileSizeBytes = $file.Length

    # Convert bytes to gigabytes
    $fileSizeGB = [math]::Round($fileSizeBytes / 1GB, 2)

    # Output the size of the file in a comma-separated format
    Write-Host "$fileName,$fileSizeGB"
}















<#
# Set the subscription
Select-AzSubscription -SubscriptionId $subscriptionId

# Get the storage account context using the storage account key
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Define a function to recursively get all files in a directory
function Get-AllFiles {
    param (
        [string]$shareName,
        [string]$path,
        $context
    )

    $filesAndFolders = Get-AzStorageFile -Context $context -ShareName $shareName -Path $path -WarningAction SilentlyContinue
    $allFiles = @()

    foreach ($item in $filesAndFolders) {
        if ($item.Length -eq $null -or $item.Length -eq 0) {
            $subPath = Join-Path -Path $path -ChildPath $item.Name
            $allFiles += Get-AllFiles -shareName $shareName -path $subPath -context $context
        } else {
            $allFiles += $item
        }
    }

    return $allFiles
}

# Get the list of all files in the file share recursively from the root
$allFiles = Get-AllFiles -shareName $fileShareName -path "" -context $context

# Filter the files to include only those ending with .VHDK
$vhdkFiles = $allFiles | Where-Object { $_.Name -like "*.VHDK" }

# Loop through each .VHDK file and calculate its size
foreach ($file in $vhdkFiles) {
    $fileName = $file.Name
    $fileSizeBytes = $file.Length

    # Convert bytes to gigabytes
    $fileSizeGB = [math]::Round($fileSizeBytes / 1GB, 2)

    # Output the size of the file
    Write-Host "File: $fileName"
    Write-Host "Size: $fileSizeGB GB"
    Write-Host "-----------------------------"
}

#>