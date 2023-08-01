#!/bin/pwsh

. /var/run/config/vcenter/variables.ps1
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false | Out-Null

$cihash = ConvertFrom-Json -InputObject $ci -AsHashtable

$errmessage = @"
vCenter: {0}
Error: {1}
Hostname: $($Env:HOSTNAME)
Twingate restarted
"@

$fileNumber = Get-Random -Minimum 1 -Maximum 16

twingate --version
twingate setup --headless "/secret/credentials$($fileNumber).json"
twingate config log-level debug
twingate start

# run forever
while ($true) {
    Start-Sleep -Seconds 60
    # Only check ibmc
#    $key = "ibm8"
#
#    try {
#        Connect-VIServer -Server $cihash[$key].vcenter -Credential (Import-Clixml $cihash[$key].secret) | Out-Null
#        $vm = Get-VM
#        $vm.Count
#    }
#    catch {
#        $caught = Get-Error
#        $errStr = $caught.ToString()
#
#        Send-SlackMessage -Uri $Env:SLACK_WEBHOOK_URI -Text ($errmessage -f $cihash[$key].vcenter, $errStr)
#
#        twingate stop
#        twingate report
#        Start-Sleep -Seconds 10
#        twingate start
#
#    }
#    finally {
#        Disconnect-VIServer -Server * -Force:$true -Confirm:$false
#    }
}

exit 0
