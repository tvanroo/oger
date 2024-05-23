Import-Module ScheduledTasks

$taskName = "FedScale Login Script Launcher"

# Check if the scheduled task exists
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($task) {
    try {
        # Disable the scheduled task
        Disable-ScheduledTask -TaskName $taskName
        Write-Host "Task '$taskName' has been disabled."

        # Remove the scheduled task
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Task '$taskName' has been removed."
    } catch {
        Write-Host "An error occurred: $_"
    }
} else {
    Write-Host "Task '$taskName' does not exist."
}
