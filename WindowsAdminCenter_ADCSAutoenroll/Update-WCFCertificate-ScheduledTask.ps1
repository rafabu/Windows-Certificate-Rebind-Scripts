Param ([string]$scriptPath = "c:\AzureData\Update-WCFCertificateBinding.ps1",
 [string]$serviceName = "ServerManagementGateway")

# inspired by from: Microsoft\Windows\CertificateServicesClient\IIS-AutoCertRebind
$schTask = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
<Triggers>
<EventTrigger>
<Enabled>true</Enabled>
<Subscription>&lt;QueryList&gt;&lt;Query Id='0'&gt;&lt;Select Path='Microsoft-Windows-CertificateServicesClient-Lifecycle-System/Operational'&gt;*[System[EventID=1001]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
<ValueQueries>
<Value name="NewCertHash">Event/UserData/CertNotificationData/NewCertificateDetails/@Thumbprint</Value>
<Value name="OldCertHash">Event/UserData/CertNotificationData/OldCertificateDetails/@Thumbprint</Value>
</ValueQueries>
</EventTrigger>
</Triggers>
<Principals>
<Principal id="System">
<UserId>S-1-5-18</UserId>
<RunLevel>HighestAvailable</RunLevel>
</Principal>
</Principals>
<Settings>
<MultipleInstancesPolicy>Queue</MultipleInstancesPolicy>
<DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
<StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
<AllowHardTerminate>true</AllowHardTerminate>
<StartWhenAvailable>false</StartWhenAvailable>
<RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
<IdleSettings>
<StopOnIdleEnd>true</StopOnIdleEnd>
<RestartOnIdle>false</RestartOnIdle>
</IdleSettings>
<AllowStartOnDemand>true</AllowStartOnDemand>
<Enabled>true</Enabled>
<Hidden>false</Hidden>
<RunOnlyIfIdle>false</RunOnlyIfIdle>
<WakeToRun>false</WakeToRun>
<ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
<Priority>7</Priority>
<RestartOnFailure>
<Interval>PT10M</Interval>
<Count>3</Count>
</RestartOnFailure>
</Settings>
<Actions Context="System">
<Exec>
<Command>powershell.exe</Command>
<Arguments>-sta -ExecutionPolicy Unrestricted -file "$scriptPath" -serviceName "$serviceName" -IP "0.0.0.0" -Port "443" -OldCertHash `$(OldCertHash) -NewCertHash `$(NewCertHash)</Arguments>
</Exec>
</Actions>
</Task>
"@

#register scheduled task
Register-ScheduledTask -xml ($schTask | Out-String) -TaskPath "\Microsoft\Windows\CertificateServicesClient\" -TaskName "WindowsAdminCenter-AutoCertRebind" -Force
Write-Host (get-date -DisplayHint Time) registered scheduled task `"WindowsAdminCenter-AutoCertRebind`"
