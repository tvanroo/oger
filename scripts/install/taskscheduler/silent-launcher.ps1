# Launch the first script hidden
Start-Job -ScriptBlock {
    Start-Process "powershell.exe" -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"`C:\install\UWP-Remove-Office.ps1`"" -Wait
}

# Launch the second script hidden
Start-Job -ScriptBlock {
    Start-Process "powershell.exe" -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"`C:\install\remove-old-teams.ps1`"" -Wait
}

# Wait for all jobs to complete
Get-Job | Wait-Job

# Clean up
Get-Job | Remove-Job
