#iex (irm https://raw.githubusercontent.com/tvanroo/oger/main/scripts/M365%20Token%20Refresh%20via%20Task%20Scheduler/Deploy%20Task%20M365%20Token%20Refresh.ps1)
function Download-GitHubDirectory {
    param (
        [string]$RepoOwner,
        [string]$RepoName,
        [string]$Path,
        [string]$LocalDir
    )

    $apiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/contents/$Path"
    $items = Invoke-RestMethod -Uri $apiUrl

    foreach ($item in $items) {
        # This ensures that the relative path is correctly calculated by removing the redundant part
        $relativePath = $item.path.Replace("$Path/", "").Replace("/", "\")
        $localPath = Join-Path -Path $LocalDir -ChildPath $relativePath

        if ($item.type -eq "file") {
            $localFileDir = [System.IO.Path]::GetDirectoryName($localPath)
            if (-not (Test-Path -Path $localFileDir)) {
                New-Item -ItemType Directory -Path $localFileDir -Force | Out-Null
            }
            Write-Host "Downloading file: $($item.name) to $localPath"
            Invoke-WebRequest -Uri $item.download_url -OutFile $localPath
        } elseif ($item.type -eq "dir") {
            Write-Host "Found directory: $($item.name), exploring..."
            New-Item -ItemType Directory -Path $localPath -Force | Out-Null
            Download-GitHubDirectory -RepoOwner $RepoOwner -RepoName $RepoName -Path $item.path -LocalDir $localPath
        }
    }
}

# Example usage
$repoOwner = "tvanroo"
$repoName = "oger"
$path = "scripts/M365%20Token%20Refresh%20via%20Task%20Scheduler" # Ensure this exactly matches the GitHub path without leading or trailing slashes
$localDir = "C:\install" # This is the base directory where files will be downloaded

# Replace forward slashes with backslashes in the $path to match the local directory structure
$convertedPath = $path -replace "/", "\"

# Combine the two variables
$combinedPath = Join-Path -Path $localDir -ChildPath $convertedPath

Download-GitHubDirectory -RepoOwner $repoOwner -RepoName $repoName -Path $path -LocalDir $combinedPath

Import-Module ScheduledTasks

$xmlFilePath = Join-Path -Path $combinedPath -ChildPath "M365TokenRefreshAllUsers.xml"
$taskName = "M365 Token Refresh via Task Scheduler"

# Check if the scheduled task already exists and remove it if it does
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "Existing task '$taskName' has been removed."
}

try {
    # Import the task into Task Scheduler
    if (Test-Path -Path $xmlFilePath) {
        $task = Register-ScheduledTask -Xml (Get-Content -Path $xmlFilePath -Raw) -TaskName $taskName
        Write-Host "Task '$taskName' has been registered successfully."

        # Ensure the task is enabled
        Enable-ScheduledTask -TaskName $taskName
        Write-Host "Task '$taskName' has been enabled."
    } else {
        Write-Host "The expected XML file was not found at: $xmlFilePath"
    }
} catch {
    Write-Host "An error occurred: $_"
}
