# New name to assign
$newName = "ITDAdmins"

# Check if the target new name already exists
$existingUser = Get-LocalUser -Name $newName -ErrorAction SilentlyContinue
if ($existingUser) {
    Write-Output "A user with the name '$newName' already exists. No action needed."
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
        try {
            # Create the new user if neither exists
            New-LocalUser -Name $newName -Description "Local Administrator" -Password (ConvertTo-SecureString "TemporaryPassword123" -AsPlainText -Force)
            Add-LocalGroupMember -Group "Administrators" -Member $newName
            Write-Output "User '$newName' has been created and added to the Administrators group."
        } catch {
            Write-Error "Failed to create '$newName'. Error: $_"
        }
    }
}
