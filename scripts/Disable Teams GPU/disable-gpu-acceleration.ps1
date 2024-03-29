# PowerShell script to disable GPU acceleration in Microsoft Teams and manage cookie file, with logging.

# Define file paths
$TeamsConfigPath = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Roaming\Microsoft\Teams\desktop-config.json"
$CookieFilePath = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Roaming\Microsoft\Teams\Network\Cookies"
$LogFilePath = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Roaming\Microsoft\Teams\startup_script_log.txt"

# Function to append log
function Append-Log {
    param (
        [String]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFilePath -Value "${timestamp}: $Message"
}

# Check if Teams configuration file exists
if (Test-Path -Path $TeamsConfigPath) {
    $TeamsConfig = Get-Content -Path $TeamsConfigPath | ConvertFrom-Json
    # Check if GPU acceleration is already disabled
    if ($TeamsConfig.appPreferenceSettings.disableGpu -eq $true) {
        Append-Log -Message "GPU acceleration already disabled in Teams. No changes made."
    } else {
        # Update configuration to disable GPU acceleration
        $TeamsConfig.appPreferenceSettings.disableGpu = $true
        $TeamsConfig | ConvertTo-Json -Compress -Depth 100 | Set-Content -Path $TeamsConfigPath
        Append-Log -Message "GPU acceleration disabled in Teams."

        # Delete Cookies file if it exists
        if (Test-Path -Path $CookieFilePath) {
            Remove-Item -Path $CookieFilePath -Force
            Append-Log -Message "Teams Cookies file deleted."
        }
    }
} else {
    Append-Log -Message "Teams configuration file not found. No changes made."
}

# Example of logging startup script completion
Append-Log -Message "Startup script execution completed."
