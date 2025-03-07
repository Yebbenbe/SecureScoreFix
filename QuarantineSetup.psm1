<#   QuarantineSetup.psm1 #####################################
Module used by Main
Configures a quarantine policy to send user quarantine notifs.
Grants perms to view preview, delete, or request release.
Configures release requests to go to desired email. 

###############################################################>

function QuarantineSetup {
    param(
        [hashtable]$paramsQuarantine,
        [string]$level) 

        if ($paramsQuarantine -eq $null) {
        logMe -level "Quarantinesetup" -message "QuarantineSetup did not receive any QuarantineParams"
        return} # exits the function


<# Original, non-modularized code for reference
$sender = Read-Host -Prompt "Specify an email to send quarantine notices to users FROM. This must be an existing internal sender. If no input is given, will default to 'quarantine@messaging.microsoft.com.'"
$admin = Read-Host -Prompt "Specify an email to send Quarantine Release Requests TO. This can be configured with a shared mailbox or ticketing endpoint."
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
#>
# Create the Quarantine Policy
try {
    New-QuarantinePolicy @paramsQuarantine
    $qPolicy = Get-QuarantinePolicy -Identity "$($paramsQuarantine['Name'])"
    logMe -level "Info" -message "Quarantine Policy '$qPolicy' created successfully. Sends alerts from: $($paramsQuarantine['EndUserSpamNotificationCustomFromAddress'])"
} catch {
    logMe -level "QuarantineSetup" -message "Error creating Quarantine Policy: $_"
}
# Create the Protection Alert
try {
    New-ProtectionAlert @paramsAlert
    logMe -level "Info" -message "Protection alert created successfully, sends release alerts to $($paramsAlert['NotifyUser'])"
} catch {
    logMe -level "QuarantineSetup" -message "Error creating Protection Alert: $_"
}
return $qPolicy

}