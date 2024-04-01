$prepPath = "c:\install\avd-prep\"

   # Define the URL of the ZIP file
   $zipUrl = "https://github.com/tvanroo/oger-vdot/archive/refs/heads/main.zip"

   # Define the local path for the downloaded ZIP file using the $prepPath variable
   $zipFilePath = Join-Path -Path $prepPath -ChildPath "downloaded.zip"

   # Download the ZIP file
   Invoke-WebRequest -Uri $zipUrl -OutFile $zipFilePath

   # Extract the ZIP file to $prepPath
   Expand-Archive -LiteralPath $zipFilePath -DestinationPath $prepPath -Force

   # Optionally, remove the ZIP file after extraction if not needed
   Remove-Item -Path $zipFilePath
   
   # Construct the full path to the Windows_VDOT.ps1 script using $prepPath
   $scriptPath = Join-Path -Path $prepPath -ChildPath "oger-vdot-main\Windows_VDOT.ps1"

   # Execute the script with arguments
   & $scriptPath -Optimizations AppxPackages, Autologgers, DefaultUserSettings, DiskCleanup, NetworkOptimizations, ScheduledTasks, Services -AdvancedOptimizations Edge, RemoveOneDrive -AcceptEULA
