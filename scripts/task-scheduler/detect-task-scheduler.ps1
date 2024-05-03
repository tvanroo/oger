$xmlFilePath = "C:\install\silent-launch-export.xml"

if (-not (Test-Path -Path $xmlFilePath)) {
    Write-Host "File $xmlFilePath does not exist."
    exit 1
}

# Get the file's last write time
$fileLastWriteTime = (Get-Item -Path $xmlFilePath).LastWriteTime
$currentTime = Get-Date

# Display the current time and file's last write time for debugging
Write-Host "Current Time: $currentTime"
Write-Host "File Last Write Time: $fileLastWriteTime"

# Calculate the time difference in hours
$timeDifference = $currentTime - $fileLastWriteTime
$hoursDifference = $timeDifference.TotalHours

Write-Host "Time difference in hours: $hoursDifference"

# Check if the file is over 23 hours old
if ($hoursDifference -gt 23) {
    Write-Host "File $xmlFilePath is older than 23 hours."
    exit 2
} else {
    Write-Host "File $xmlFilePath is not older than 23 hours."
    exit 0
}
