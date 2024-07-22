Import-Module ScheduledTasks

$taskName = "M365 Token Refresh via Task Scheduler"

# Check if the scheduled task exists
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($task) {
    Write-Host "Task '$taskName' is present."
    exit 1
} else {
    Write-Host "Task '$taskName' is not present."
    exit 0
}
