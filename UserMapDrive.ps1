
param(
    [Parameter()]
    [String]
    $SuppliedPass,
    [Parameter()]
    [String]
    $SAPass

)


[securestring]$StuPass = ConvertTo-SecureString $SuppliedPass -AsPlainText -Force

$Students=(Get-aduser -filter {name -like "Student*"} | select SamAccountName).SamAccountName
foreach($Student in $Students){
[pscredential]$StuCred = New-Object System.Management.Automation.PSCredential ($Student, $StuPass)
$wvdvms = (Get-ADComputer -Filter {name -like "wvd-vm*"}).name
Invoke-Command -ComputerName $wvdvms `
    -ScriptBlock { 
        net localgroup Administrators $using:Student /add

    }
Foreach($wvdvm in $wvdvms){
    $cimSession = New-CimSession -ComputerName $wvdvm
    # Create a scheduled task action to call the cmdkey command
    $sta = New-ScheduledTaskAction "cmdkey" `
                -Argument ("/add:trainingdatasa.file.core.windows.net /user:Azure\trainingdatasa /pass:$($SAPass)") `
                -CimSession $cimSession
    
    # Register a scheduled tasks that can be called 
    Register-ScheduledTask -TaskName "cmdKeySvcAccnt" `
        -Action $sta `
        -User "training\$($Student)" `
        -Password $SuppliedPass `
        -RunLevel Highest `
        -CimSession $cimSession
    
    # Trigger the execution of the scheduled task
    Get-ScheduledTask -TaskName "cmdKeySvcAccnt" -CimSession $cimSession | Start-ScheduledTask
     
    # Clean up the remote environment
    Get-ScheduledTask -TaskName "cmdKeySvcAccnt" -CimSession $cimSession | Unregister-ScheduledTask -Confirm:$false
}
Invoke-Command -ComputerName $wvdvms `
-ScriptBlock { 
    net localgroup Administrators $using:Student /delete
}
}
Invoke-Command -ComputerName $wvdvms -ScriptBlock { 
    $Command= '"New-PSDrive -Name Z -PSProvider FileSystem -Root \\trainingdatasa.file.core.windows.net\trainingdata -Persist"'
                set-content "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\MapDrive.bat" -Value "powershell -command $($Command)"
}
