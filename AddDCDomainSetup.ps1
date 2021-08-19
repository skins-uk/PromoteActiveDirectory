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

$password = ConvertTo-SecureString $DomainPass -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($DomainAcc, $password)
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
-Force:$true
