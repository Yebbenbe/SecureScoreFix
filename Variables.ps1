# Variables.ps1
# contains parameters used for configuration, excluding any requiring user input
# Not recommmended to change these values, but if tweaks are needed, should be done here. 

$MailTipsParams = @{
    MailTipsAllTipsEnabled = $true
    MailTipsExternalRecipientsTipsEnabled = $true
    MailTipsGroupMetricsEnabled = $true
    MailTipsLargeAudienceThreshold = '25'
    }

$QuarantineParams = @{
Name = "$MSP Quarantine Release policy" # $MSP is from Main.ps1, do not change
EndUserQuarantinePermissionsValue = 139
AdminDisplayName = 'Allows users to see previews and request release, sends notif to user'
IncludeMessagesFromBlockedSenderAddress = $false
ESNEnabled = $true
QuarantineRetentionDays = 30
# EndUserSpamNotificationCustomFromAddress = $qSender #can only be set on global.
EndUserSpamNotificationFrequency = "1.00:00:00"
}

$AlertParams = @{
AggregationType = "None"
Operation = "QuarantineRequestReleaseMessage"
Category = "ThreatManagement"
name = "$MSP Release Request Notifications"  # $MSP from Main, do not change.
NotifyUser = $qAdmin #from Main, do not change.
ThreatType = "Activity"
Description = "Created by script. Notifies $qAdmin when someone has requested Quarantine Release"
}

$SafeLinksParams = @{  
Name =  "$MSP Safe Links policy"
EnableSafeLinksForEmail = $true
EnableSafeLinksForTeams = $true
EnableSafeLinksForOFfice = $true
TrackClicks = $True
AllowClickThrough = $false
EnableOrganizationBranding = $false
AdminDisplayName = "generated via PowerShell script."
}

$MalwareFilterParams = @{
    Name = "$MSP Malware Filter Policy"
    ZapEnabled = $true
    EnableExternalSenderAdminNotifications = $false
    EnableInternalSenderAdminNotifications = $false
    ExternalSenderAdminAddress = 'o365security@ispire.ca'
    
    EnableFileFilter = $true
    AdminDisplayName = "generated via PowerShell script."
    FileTypeAction = "Reject" 
    FileTypes = "ade", "adp", "app", "asp", "asx", "bas", "bat", "chm", "cmd", "com", "cpl", "crt", "csh", "der", "exe", "fxp", "gadget", "hlp", "hta", "inf", "ins", "isp", "its", "jar", "jse", "ksh", "lnk", "mad", "maf", "mag", "mam", "maq", "mar", "mas", "mat", "mau", "mav", "maw", "mda", "mdb", "mde", "mdt", "mdw", "mdz", "msc", "msh", "msh1", "msh2", "mshxml", "msh1xml", "msh2xml", "msi", "msp", "mst", "ops", "pcd", "pif", "pl", "prf", "prg", "ps1", "ps1xml", "ps2", "ps2xml", "psc1", "psc2", "reg", "scf", "scr", "sct", "shb", "shs", "url", "vb", "vbe", "vbs", "vsmacros", "vss", "vst", "vsw", "ws", "wsc", "wsf", "wsh", "xnk"
}

$SafeAttachmentsParams= @{
    Name = "$MSP Safe Attachments policy"
    Action = "Block"
    QuarantineFlag = "$qPolicy"
    EnableRedirect = $false
    AdminDisplayName = "generated via PowerShell script."
}

$InboundSpamParams = @{
    QuarantineRetentionPeriod = 30
    SpamAction = "MoveToJmf"
    BulkSpamAction = "MoveToJmf"
    PhishSpamAction = "MoveToJmf"
    BulkThreshold = 6
    ZapEnabled = $true
    InlineSafetyTipsEnabled = $true
    PhishZapEnable = "True" 
    HighConfidencePhishAction = "Quarantine"
    HighConfidenceSpamAction = "Quarantine" 
    HighConfidenceSpamQuarantineTag = "Allow Quarantine Release Requests"
    HighConfidencePhishQuarantineTag = "Allow Quarantine Release Requests"
}

$OutboundSpamParams = @{
    RecipientLimitExternalPerHour = 500
    RecipientLimitInternalPerHour = 500
    RecipientLimitPerDay = 1000
    ActionWhenThresholdReached = 'BlockUser'
    NotifyOutboundSpamRecipients = 'o365security@ispire.ca' 
    NotifyOutboundSpam = $true
    AutoForwardingMode = 'Off'
    }

# Mail Tips params
# original -MailTipsAllTipsEnabled $true -MailTipsExternalRecipientsTipsEnabled $true -MailTipsGroupMetricsEnabled $true -MailTipsLargeAudienceThreshold '25'; 
