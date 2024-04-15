$AppInstallDelay = New-TimeSpan -Days 0 -Hours 1 -Minutes 0

$ime = Get-Item "C:\Program Files (x86)\Microsoft Intune Management Extension"  | select Name,CreationTime 
$EnrolmentDate = $ime.creationtime

$futuredate = $EnrolmentDate + $AppInstallDelay


#checking date and futuredate
$outcome = ((Get-Date) -ge ($futuredate))  
$outcome