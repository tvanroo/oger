$userExists = Get-LocalUser -Name "ITDAdmin" -ErrorAction SilentlyContinue
if ($userExists) {
    Write-Output "User exists."
    exit 1  # User exists
} else {
    Write-Output "User does not exist."
    exit 0  # User does not exist
}
