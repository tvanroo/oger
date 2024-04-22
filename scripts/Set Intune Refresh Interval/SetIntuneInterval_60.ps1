# Define the script block as a string
$scriptBlock = @'
# Task and folder parameters
$taskName = "Schedule #1 created by enrollment client"
$intervalMinutes = 60  # Set the reoccurrence interval in minutes
$folderPath = "C:\Program Files (x86)\Microsoft Intune Management Extension"

# Retrieve the folder creation time
$folderCreationTime = (Get-Item $folderPath).CreationTime

# Calculate the exact time when the folder will be 15 minutes old
$targetTime = $folderCreationTime.AddMinutes(10329)

# Loop until the current time is greater than or equal to the target time
do {
    # Calculate the total elapsed time
    $elapsed = (Get-Date) - $folderCreationTime
    # Calculate total elapsed minutes and seconds accounting for days
    $totalMinutes = [math]::Floor($elapsed.TotalMinutes)
    $seconds = $elapsed.Seconds
    # Format the elapsed time as MM:SS
    $formattedElapsed = "{0}:{1:D2}" -f $totalMinutes, $seconds
    # Output the elapsed time
    Write-Host "$formattedElapsed elapsed"
    
    # Check if 15 minutes have passed
    if ((Get-Date) -ge $targetTime) {
        break
    }

    Start-Sleep -Seconds 10
} while ($true)

Write-Host "15 minutes have passed, script continues..."

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
        $newTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $desiredInterval -RepetitionDuration (New-TimeSpan -Days 9999)

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
'@

# Save to a temporary script file
$scriptPath = [System.IO.Path]::GetTempFileName() + ".ps1"
$scriptBlock | Out-File -FilePath $scriptPath -Encoding UTF8

# Start the new PowerShell process
Start-Process "powershell.exe" -ArgumentList "-NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -WindowStyle Hidden
