[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $resourcegroupname,
    [Parameter()]
    [String]
    $hostpoolname,
    [Parameter()]
    [String]
    $Tenant,
    [Parameter()]
    [String]
    $SubscriptionId
)
Connect-AzAccount -Tenant $Tenant
Select-AzSubscription -SubscriptionId $SubscriptionId
Import-Module -Name Az.DesktopVirtualization
Update-AzWvdHostPool -ResourceGroupName $resourcegroupname -Name $hostpoolname -StartVMOnConnect:$true
