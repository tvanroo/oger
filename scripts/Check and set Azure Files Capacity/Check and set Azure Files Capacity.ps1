
# Import the required Azure modules
Import-Module Az.Accounts
Import-Module Az.Storage
Import-Module Az.Resources

# Define variables
$resourceGroupName = "oge-prod-001-vds-eastus2-rg"
$storageAccountName = "ogeprodvdsp01"
$fileShareName = "ogeprodvdsp0"
$subscriptionId = "edb20396-8056-4173-9c60-c0aa8905eeaa"

#securely get and store storage account key1

$storageAccountKey = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName | Select-Object KeyName,Value | Where-Object { $_.KeyName -eq "key1" } | Select-Object -ExpandProperty Value

#securely get and store storage connection string
$storageConnectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$storageAccountKey;EndpointSuffix=core.windows.net"

# Variables
$env:AZURE_STORAGE_CONNECTION_STRING = $storageConnectionString

# Authenticate to Azure
Connect-AzAccount

# Set the subscription
Select-AzSubscription -SubscriptionId $subscriptionId


# Get the storage account context using the storage account key
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName)[0].Value
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Get the file share properties
$fileShare = Get-AzStorageShare -Name $fileShareName -Context $context

# Output the quota (size) of the file share
Write-Host "The quota (size) of the file share '$fileShareName' is $($fileShare.Quota) GB."
$capacityInGB = $fileShare.Quota

# Manage identity check
$connectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$storageAccountKey;EndpointSuffix=core.windows.net"


# Get the storage account context
$storageAccount = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$ctx = $storageAccount.Context

# Get the list of file shares
$fileShares = az storage share list --account-name $storageAccountName --query "[].name" -o tsv


# Loop through each file share and retrieve quota and usage
foreach ($shareName in $fileShares) {

    $usage = Get-AzRmStorageShare -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -Name $shareName -GetShareUsage 
    Write-Output  $usage
    Write-Output "-----------------------------"

    
    # Check if usage data is returned
    if ($usage -ne $null) {
        # Extract the ShareUsageBytes property (update the property name if necessary)
        $usageInBytes = $usage.ShareUsageBytes  # Adjust property name as needed

        # Convert bytes to gigabytes
        $usageInGB = $usageInBytes / 1GB

        # Format and output the result
        Write-Output "File Share: $shareName"
        Write-Output "Usage: $([math]::Round($usageInGB, 2)) GB"
        Write-Output "-----------------------------"
    } else {
        Write-Output "No usage data found for file share: $shareName"
    }


}

$usageInGB
$capacityInGB

#calculate usage percentage
$usagePercentage = ($usageInGB / $capacityInGB) * 100

Write-host "Usage Percentage: $usagePercentage"

#increase storae capacity if usage is greater than 80%
if ($usagePercentage -gt 90) {
    $newCapacity = [math]::Ceiling($capacityInGB * 1.1)  # Increase the capacity by 10%
    Set-AzStorageShareQuota -ShareName $fileShareName -Quota $newCapacity
    Write-Host "Increased the capacity of the file share '$fileShareName' to $newCapacity GB."
} else {
    Write-Host "The usage of the file share '$fileShareName' is below 90%."
}