# Define the target directory and file name
$targetDir = "c:\install\installers"
$fileName = "teamsbootstrapper.exe"

# Construct the full file path
$filePath = Join-Path -Path $targetDir -ChildPath $fileName

# Check if the file already exists
if (Test-Path -Path $filePath) {
    # File exists, exit with code 0 to indicate success
    Write-Host "File exists: $filePath"
    exit 0
} else {
    # File does not exist, exit with code 1 to indicate action needed
    Write-Host "File not found: $filePath"
    exit 1
}
