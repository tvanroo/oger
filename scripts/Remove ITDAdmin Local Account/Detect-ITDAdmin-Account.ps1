$userExists = Get-LocalUser -Name "ITDAdmin" -ErrorAction SilentlyContinue
if ($userExists) {
    exit 1  # User exists
} else {
    exit 0  # User does not exist
}
