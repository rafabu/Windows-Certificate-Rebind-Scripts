# Update-WCFCertificateBinding.ps1 -serviceName "ServerManagementGateway" -IP "0.0.0.0" -Port "443" -NewCertHash "b249c55bbddfe62849c1ffb8bca38897afc311bc" -oldCertHash "EA1F3532F41B7A3B0582FA78C53E3C46DE741919"

Param ([string]$NewCertHash = "",
    [string]$OldCertHash = "",
    [string]$IP = "0.0.0.0",
    [string]$Port = "443",
    [string]$serviceName = "ServerManagementGateway"
)

Start-Transcript -Path "C:\AzureData\WCFCertificateBinding.Log"

$netshShowCommand = 'netsh http show sslcert ipport={0}:{1}' -f $IP, $Port
$currentBinding = (Invoke-Expression -Command $netshShowCommand) -split '\r?\n' | ConvertFrom-String -Delimiter " : " -PropertyName Property, Value
$currentCertHash = ($currentBinding | where Property -imatch "Certificate Hash").Value.Trim()
$currentAppID = ($currentBinding | where Property -imatch "Application ID").Value.Trim()

if ($OldCertHash -imatch $currentCertHash) {
    Write-Host (get-date -DisplayHint Time) replacing TLS cert binding for $($IP):$($Port)
    Write-Host (get-date -DisplayHint Time) old thumbprint: $currentCertHash / new thumbprint $NewCertHash

    #check if new certificate is available
    if (Get-ChildItem Cert:\LocalMachine\My | where Thumbprint -eq $NewCertHash) {
        #remove old binding
        $netshDeleteCommand = 'netsh http delete sslcert ipport={0}:{1}' -f $IP, $Port
        Invoke-Expression -Command $netshDeleteCommand
        #add new binding, maintaining previous appid
        $netshAddCommand = 'netsh http add sslcert ipport={0}:{1} certhash={2} appid="{3}"' -f $IP, $Port, $newCertHash, $currentAppID
        Invoke-Expression -Command $netshAddCommand
        #restart service
        $winService= Get-Service -Name $serviceName
        if ($winService) {
            Restart-Service -Name $serviceName
            Write-Host (get-date -DisplayHint Time) Restarted $serviceName to use TLS certificate $NewCertHash
        }
    }
    else {
        Write-Warning (get-date -DisplayHint Time) new certificate with hash $NewCertHash was not found
    }
}
else {
    Write-Host (get-date -DisplayHint Time) no need to replace TLS cert binding for $($IP):$($Port)
    Write-Host (get-date -DisplayHint Time) replaced hash $OldCertHash and current certificate hash $currentCertHash do not match
}

Stop-Transcript
