# PowerShell script to adjust triggers for a specified task
# Task and folder parameters
$taskName = "Schedule #1 created by enrollment client"
$intervalMinutes = 60  # Set the reoccurrence interval in minutes


# Get the current time
$currentTime = Get-Date

# Set the start time to the next minute of the current hour
$startTime = Get-Date -Year $currentTime.Year -Month $currentTime.Month -Day $currentTime.Day -Hour $currentTime.Hour -Minute $currentTime.Minute -Second 0

# Add a minute to ensure it's in the future
$startTime = $startTime.AddMinutes(1)

## Now create the trigger with the calculated start time
#$newTrigger = New-ScheduledTaskTrigger -Once -At $startTime -RepetitionInterval $desiredInterval -RepetitionDuration ([timespan]::MaxValue)




# Convert interval to a TimeSpan
$desiredInterval = New-TimeSpan -Minutes $intervalMinutes

# Get all tasks with the specified name, regardless of their folder location
$allMatchingTasks = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName }

foreach ($task in $allMatchingTasks) {
    # Skip tasks that don't match the expected folder pattern
    if ($task.TaskPath -notmatch 'EnterpriseMgmt') {
        continue
    }

    # Get existing triggers
    $existingTriggers = $task.Triggers

    # Check if an hourly trigger already exists
    $hourlyTriggerExists = $existingTriggers | Where-Object {
        $_.Repetition -and
        $_.Repetition.Interval -eq $desiredInterval
    }

    if (-not $hourlyTriggerExists) {
        # Define a new hourly trigger with the indefinite repetition duration
        $newTrigger = New-ScheduledTaskTrigger -Once -At $startTime -RepetitionInterval $desiredInterval -RepetitionDuration (New-TimeSpan -Days 9999)

        # Filter out unwanted triggers
        $existingTriggers = $existingTriggers | Where-Object {
            $_.TriggerType -eq 'Time' -and
            (
                $_.Repetition.Interval -eq $desiredInterval -or
                $_.Repetition.Interval -eq (New-TimeSpan -Hours 8)
            )
        }

        # Add new trigger if a custom interval is set
        if ($intervalMinutes -ne 480) {
            $existingTriggers += $newTrigger
        }
    }

    # Update the task with the new set of triggers if changes were made
    if ($hourlyTriggerExists -or $intervalMinutes -ne 480) {
        Set-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Trigger $existingTriggers
        Write-Output "Triggers updated for the task: $($task.TaskName) in $($task.TaskPath)"
    } else {
        Write-Output "No changes made to the task: $($task.TaskName) in $($task.TaskPath)"
    }
}
