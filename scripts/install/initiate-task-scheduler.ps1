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
$path = "scripts/install" # Ensure this exactly matches the GitHub path without leading or trailing slashes
$localDir = "C:\install" # This is the base directory where files will be downloaded

Download-GitHubDirectory -RepoOwner $repoOwner -RepoName $repoName -Path $path -LocalDir $localDir

$xmlFilePath = Join-Path -Path $localDir -ChildPath "silent-launch-export.xml"
$taskName = "MyNewScheduledTask"

try {
    # Import the task into Task Scheduler
    if (Test-Path -Path $xmlFilePath) {
        Register-ScheduledTask -Xml (Get-Content -Path $xmlFilePath -Raw) -TaskName $taskName
        Write-Host "Task '$taskName' has been registered successfully."
    } else {
        Write-Host "The expected XML file was not found at: $xmlFilePath"
    }
} catch {
    Write-Host "An error occurred: $_"
}
