# File path of the silent-launch-export.xml file
$xmlFilePath = "C:\install\silent-launch-export.xml"

if (-not (Test-Path -Path $xmlFilePath)) {
    Write-Host "File $xmlFilePath does not exist."
    exit 1
}

# Get the file's last write time
$fileLastWriteTime = (Get-Item -Path $xmlFilePath).LastWriteTime

# Calculate the time difference in hours
$timeDifference = (Get-Date) - $fileLastWriteTime
$hoursDifference = $timeDifference.TotalHours

# Check if the file is over 23 hours old
if ($hoursDifference > 23) {
    Write-Host "File $xmlFilePath is older than 23 hours."
    exit 2  # Use an exit code to trigger remediation
} else {
    Write-Host "File $xmlFilePath is not older than 23 hours."
    exit 0  # Use an exit code to indicate no remediation is needed
}
