# QuarantinePolicy
function Quarantine {
    param(
        [Parameter(ValueFromPipeline=$true)] [string]$message,
        [string]$level = "Info")


Write-Host "Users will be alerted when an item has been quarantined."
$sender = Read-Host -Prompt "Specify an email to send quarantine notices to users FROM. This must be a valid email on the tenant."

$admin = Read-Host -Prompt "Specify an email to send Quarantine Release Requests TO"
New-QuarantinePolicy -Identity "Allow Quarantine Release Requests" -EndUserQuarantinePermissionsValue 139 -AdminDisplayName 'Allows users to see previews and request release, sends notif to user'
-ESNEnabled $true -QuarantineRetentionDays 30 

New-ProtectionAlert -AggregationType None -Operation QuarantineRequestReleaseMessage -Category ThreatManagement -name "Notify about Quarantine Release Request" `
-NotifyUser $admin -ThreatType Activity -Description "Created by script. Notifies when someone has requested Quarantine release"