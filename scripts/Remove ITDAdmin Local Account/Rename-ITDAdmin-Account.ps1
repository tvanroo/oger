# New name to assign
$newName = "ITDAdmins"

# Check if the target new name already exists
$existingUser = Get-LocalUser -Name $newName -ErrorAction SilentlyContinue
if ($existingUser) {
    Write-Output "A user with the name '$newName' already exists. Please choose a different name."
} else {
    # Check if the current user exists
    $currentUser = Get-LocalUser -Name "ITDAdmin" -ErrorAction SilentlyContinue
    if ($currentUser) {
        try {
            # Attempt to rename the user
            Rename-LocalUser -Name "ITDAdmin" -NewName $newName
            Write-Output "User 'ITDAdmin' has been successfully renamed to '$newName'."
        } catch {
            Write-Error "Failed to rename 'ITDAdmin'. Error: $_"
        }
    } else {
        Write-Output "'ITDAdmin' user not found. No action needed."
    }
}
