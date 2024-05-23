Import-Module ScheduledTasks

$taskName = "FedScale Login Script Launcher"

# Check if the scheduled task exists
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($task) {
    Write-Host "Task '$taskName' is present."
    exit 1
} else {
    Write-Host "Task '$taskName' is not present."
    exit 0
}
