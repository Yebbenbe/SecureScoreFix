
<#   QuarantineSetup.psm1 #####################################
Module used by Main
Configures a quarantine policy to send user quarantine notifs.
Grants perms to view preview, delete, or request release.
Configures release requests to go to desired email. 

###############################################################>

function QuarantineSetup {
    param(
        
        [string]$MSP = $null,
        [string]$level = "Info")

paramsQuarantine = @{
Name = "$MSP Quarantine Release policy"
EndUserQuarantinePermissionsValue = 139
AdminDisplayName = 'Allows users to see previews and request release, sends notif to user'
IncludeMessagesFromBlockedSenderAddress = $false
ESNEnabled = $true
QuarantineRetentionDays = 30
EndUserSpamNotificationCustomFromAddress = $sender
EndUserSpamNotificationFrequency = "1.00:00:00"
}

paramsAlert = @{
AggregationType = None
Operation = QuarantineRequestReleaseMessage
Category = ThreatManagement
name = "$MSP Release Request Notifications"
NotifyUser = $admin
ThreatType = Activity
Description = "Created by script. Notifies $admin when someone has requested Quarantine Release"
}

Write-Host "Users will be alerted when an item has been quarantined."
$sender = Read-Host -Prompt "Specify an email to send quarantine notices to users FROM. This must be an existing internal sender. If no input is given, will default to 'quarantine@messaging.microsoft.com.'"
$admin = Read-Host -Prompt "Specify an email to send Quarantine Release Requests TO. This can be configured with a shared mailbox or ticketing endpoint."

New-QuarantinePolicy @paramsQuarantine

New-ProtectionAlert @paramsAlert