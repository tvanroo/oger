# Authenticate to Azure
Connect-AzAccount

# Define Resource Group
$resourceGroupName = "oge-prod-001-vds-eastus2-rg"

# Define the GPO to check
$gpoToCheck = "Win1164AVDPolicy"

# Get the list of VMs
$vms = Get-AzVM -ResourceGroupName $resourceGroupName

# Initialize the results array
$results = @()

foreach ($vm in $vms) {
    $vmName = $vm.Name
    $resourceGroupName = $vm.ResourceGroupName

    # Check the power state of the VM
    $vmStatus = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Status
    $powerState = $vmStatus.Statuses | Where-Object { $_.Code -like 'PowerState/*' } | Select-Object -ExpandProperty DisplayStatus

    if ($powerState -ne "VM running") {
        Write-Host "Skipping $vmName as it is not running (current state: $powerState)."
        continue
    }

    $commandToExecute = @"
gpresult /r /scope computer
"@

    # Execute the command on the VM using Run Command
    $params = @{
        ResourceGroupName = $resourceGroupName
        VMName            = $vmName
        CommandId         = "RunPowerShellScript"
        ScriptString      = $commandToExecute
    }

    try {
        $result = Invoke-AzVMRunCommand @params
        $output = $result.Value[0].Message

        # Parse the output to find the applied GPOs
        $appliedGPOsSection = $output -split "Applied Group Policy Objects" | Select-Object -Last 1
        $appliedGPOs = $appliedGPOsSection -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" -and $_ -notmatch "^-+$" }

        # Check if the specific GPO is applied
        $isGPOApplied = $appliedGPOs -contains $gpoToCheck

        # Store the results
        $results += [PSCustomObject]@{
            VMName        = $vmName
            ResourceGroup = $resourceGroupName
            IsGPOApplied  = $isGPOApplied
        }
    } catch {
        Write-Host "Failed to execute command on ${vmName}: $($_.Exception.Message)"
    }
}

# Output the summary
$results | Format-Table -AutoSize