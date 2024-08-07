# Function to download a GitHub directory
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
$path = "scripts/task-scheduler" # Ensure this exactly matches the GitHub path without leading or trailing slashes
$localDir = "C:\install" # This is the base directory where files will be downloaded

Download-GitHubDirectory -RepoOwner $repoOwner -RepoName $repoName -Path $path -LocalDir $localDir

Import-Module ScheduledTasks

# Adjusted to the correct path
$xmlFilePath = Join-Path -Path $localDir -ChildPath "Speed Start New Teams\Speed Start New Teams.xml"
$taskName = "Speed Start New Teams"

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
