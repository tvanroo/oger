# Authenticate to Azure
Connect-AzAccount

# Set the desired retention period in days
$retentionInDays = 730

# Get all subscriptions
$subscriptions = Get-AzSubscription

foreach ($subscription in $subscriptions) {
	# Set the context to the current subscription
	Set-AzContext -SubscriptionId $subscription.Id

	# Get all resource groups in the current subscription
	$resourceGroups = Get-AzResourceGroup

	foreach ($resourceGroup in $resourceGroups) {
		$resourceGroupName = $resourceGroup.ResourceGroupName

		# Get all Log Analytics Workspaces in the current resource group
		$workspaces = Get-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName

		foreach ($workspace in $workspaces) {
			$workspaceName = $workspace.Name

			# Set the retention period for the current workspace
			Set-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName -Name $workspaceName -RetentionInDays $retentionInDays

			Write-Host "Set retention for workspace $workspaceName in resource group $resourceGroupName to $retentionInDays days."
		}
	}
}