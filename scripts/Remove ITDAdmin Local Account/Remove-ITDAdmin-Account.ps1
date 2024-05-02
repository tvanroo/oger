$userExists = Get-LocalUser -Name "ITDAdmin" -ErrorAction SilentlyContinue
if ($userExists) {
    Remove-LocalUser -Name "ITDAdmin"
    Write-Output "ITDAdmin has been removed."
} else {
    Write-Output "ITDAdmin not found. No action needed."
}
