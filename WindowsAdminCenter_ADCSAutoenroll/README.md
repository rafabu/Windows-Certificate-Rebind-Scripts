# Summary
Use this to create a scheduled task that triggers when Windows Certificate Autoenrollment event 1001 is recorded.

The contained PowerShell script will then do the following using "netsh http" commands:

- get the thumbprint of current certificate and compare it to the one of event 1001
- if a match is found, replace the netsh http registration with the new thumbprint
- restart the service provided by serviceName

In order to implement this script:

1. copy Update-WCFCertificateBinding.ps1 to a suitable script folder
2. if doing anything other than Windows Admin Center - change the parameter -serviceName
3. run Update-WCFCertificate-ScheduledTask.ps1 -scriptPath [full path to script]
4. new scheduled task will have been created in Microsoft\Windows\CertificateServicesClient