Write-Host "Starting the process to install Teams ..." -ForegroundColor Green
 # Define the download URL and target directory
 $url = "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409"
 $targetDir = "c:\install\installers"
 $fileName = "teamsbootstrapper.exe"

 # Ensure the target directory exists
 if (-not (Test-Path -Path $targetDir)) {
     New-Item -ItemType Directory -Path $targetDir -Force
 }

 # Construct the full file path
 $filePath = Join-Path -Path $targetDir -ChildPath $fileName

Write-Host "Downloading the Teams installer..."
Invoke-WebRequest -Uri $url -OutFile $filePath

Write-Host "Download completed: $filePath"

Write-Host "Installing Teams..."
Start-Process -FilePath $filePath -ArgumentList "-p" -WindowStyle Hidden -Wait

Write-Host "Completed the process to install Teams." -ForegroundColor Green