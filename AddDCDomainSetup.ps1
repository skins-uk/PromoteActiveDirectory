[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $DomainPass,
    [Parameter()]
    [String]
    $DomainFQDN,
    [String]
    $DomainAcc
)
do {
  Write-Host "waiting..."
  sleep 3
} until(Test-NetConnection $DomainFQDN | ? PingSucceeded )

$DomainNB=$DomainFQDN.split(".")[0]

write-output $DomainPass
write-output $DomainFQDN
write-output $DomainAcc
write-output $DomainNB

$password = ConvertTo-SecureString $DomainPass -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ("$($DomainNB)\$($DomainAcc)", $password)

write-output $credObject.GetNetworkCredential().username
write-output $credObject.GetNetworkCredential().password


Import-Module ADDSDeployment
Install-ADDSDomainController `
-DomainName $DomainFQDN `
-SafeModeAdministratorPassword: $password `
-CreateDnsDelegation:$false `
-Credential $credObject `
-DatabasePath "E:\windows\NTDS" `
-InstallDns:$true `
-LogPath "E:\windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "E:\windows\SYSVOL" `
-SiteName "Default-First-Site-Name" `
-Force:$true
