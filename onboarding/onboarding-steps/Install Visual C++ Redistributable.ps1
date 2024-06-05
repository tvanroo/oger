Write-Host "Starting the process to install Visual C++ Redistributable..." -ForegroundColor Green

function Install-Redistributable {
    param (
        [string]$Architecture
    )
    $redistUrl = "https://aka.ms/vs/17/release/vc_redist.$Architecture.exe"
    $redistPath = Join-Path -Path $prepPath -ChildPath "vc_redist.$Architecture.exe"

    Write-Host "Downloading Visual C++ Redistributable for $Architecture..."
    Invoke-WebRequest -Uri $redistUrl -OutFile $redistPath

    Write-Host "Installing Visual C++ Redistributable for $Architecture..."
    Start-Process -FilePath $redistPath -ArgumentList "/quiet", "/norestart" -Wait
    Write-Host "Visual C++ Redistributable for $Architecture installed successfully."
}

# Uncomment the following line to install the x86 version
Install-Redistributable -Architecture "x86"
Install-Redistributable -Architecture "x64"

Write-Host "Completed the process to install Visual C++ Redistributable." -ForegroundColor Green
