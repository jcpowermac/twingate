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

$killmessage = @"
vCenter: {0}
Error: {1}
Hostname: $($Env:HOSTNAME)
Pod killed
"@

$fileNumber = Get-Random -Minimum 1 -Maximum 16
$failCount = 0

twingate --version
twingate setup --headless "/secret/credentials$($fileNumber).json"
twingate config log-level debug
twingate start

# run forever
while ($true) {
    Start-Sleep -Seconds 60
    # Only check ibmc
    $key = "devqe"

    try {
        Connect-VIServer -Server $cihash[$key].vcenter -Credential (Import-Clixml $cihash[$key].secret) | Out-Null
        $vm = Get-VM
        $vm.Count
    }
    catch {
        $failCount++
        $caught = Get-Error
        $errStr = $caught.ToString()

        if ($failCount -eq 10) {
            Send-SlackMessage -Uri $Env:SLACK_WEBHOOK_URI -Text ($killmessage -f $cihash[$key].vcenter, $errStr)
            exit 1
        }

        Send-SlackMessage -Uri $Env:SLACK_WEBHOOK_URI -Text ($errmessage -f $cihash[$key].vcenter, $errStr)

        twingate stop
        twingate report
        Start-Sleep -Seconds 10
        twingate start
    }
    finally {
        Disconnect-VIServer -Server * -Force:$true -Confirm:$false
    }
}

exit 0
