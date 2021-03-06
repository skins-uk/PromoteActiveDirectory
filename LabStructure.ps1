[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $SuppliedPass,
    [Parameter()]
    [String]
    $UserNum,
    [Parameter()]
    [String]
    $SAPass    
)
#Setup Variables
$DCRoot = ([ADSI]"").distinguishedName
$DCUSERDNSDOMAIN = $env:USERDNSDOMAIN
$WVDRoot = "OU=WVD,$($DCRoot)"
$password = ConvertTo-SecureString "$($SuppliedPass)" -AsPlainText -Force
#Create Root WVD OU
New-ADOrganizationalUnit -Name "WVD" -Path "$($DCRoot)" -ProtectedFromAccidentalDeletion $False -Description "WVD Environment"
#Create Other OUs
New-ADOrganizationalUnit -Name "Users" -Path "$($WVDRoot)" -ProtectedFromAccidentalDeletion $False -Description "WVD Users"
New-ADOrganizationalUnit -Name "Service Accounts" -Path "$($WVDRoot)" -ProtectedFromAccidentalDeletion $False -Description "WVD Service Accounts"
New-ADOrganizationalUnit -Name "Servers" -Path "$($WVDRoot)" -ProtectedFromAccidentalDeletion $False -Description "WVD Servers"
New-ADOrganizationalUnit -Name "Session Hosts" -Path "$($WVDRoot)" -ProtectedFromAccidentalDeletion $False -Description "WVD WVD Session Hosts"
#Create Student Accounts within Domain
for ($User = 1; $User -le $UserNum; $User++)
{
    $User
    New-ADUser -Name "Student$($User) Account" -AccountPassword $password -DisplayName "Student$($User) Account" -Enabled $True -Path "OU=Users,$($WVDRoot)" -SamAccountName "Student$($User)" -Surname "Student$($User)" -UserPrincipalName "Student$($User)@$($DCUSERDNSDOMAIN)"    
}

.\UserMapDrive.ps1 -SuppliedPass $SuppliedPass -SAPass $SAPass
.\Config-StartVMConnect.ps1 -resourcegroupname "demolabv1-region1infra" -hostpoolname "demolab-hp1" -Tenant "c20e7f31-4c70-4ead-bbcf-f3ed7a4c7ef8" -SubscriptionId "51ab7e41-69c6-4182-b561-fd2fb2ffed1d"
