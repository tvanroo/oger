# Define the task name
$taskName = "Speed Start New Teams"

# Check if the scheduled task already exists and remove it if it does
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "Existing task '$taskName' has been removed."
} else {
    Write-Host "Task '$taskName' does not exist."
}
