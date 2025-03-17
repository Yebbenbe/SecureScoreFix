# Variables.ps1
# contains parameters used for configuration, excluding any requiring user input
# Not recommmended to change these values, but if tweaks are needed, should be done here.

#Essential params, do not modify
$execsArray = @()
$failedProcesses = @()
$domains = @()
$toFix = @(
    "MailTips",
    "Quarantine",
    "Alert",
    "SafeLinks",
    "SafeAttach",
    "MalwareFilter",
    "AntiPhish",
    "InboundSpam",
    "OutboundSpam"
)


$MailTipsParams = @{
    MailTipsAllTipsEnabled = $true
    MailTipsExternalRecipientsTipsEnabled = $true
    MailTipsGroupMetricsEnabled = $true
    MailTipsLargeAudienceThreshold = '25'
    }

$QuarantineParams = @{
Name = "AllowReleaseRequests" # use this to set elssewhere
EndUserQuarantinePermissionsValue = 139
AdminDisplayName = 'Allows users to see previews and request release, sends notif to user'
IncludeMessagesFromBlockedSenderAddress = $false
ESNEnabled = $true
QuarantineRetentionDays = 30
# EndUserSpamNotificationCustomFromAddress = $qSender #can only be set on global.
EndUserSpamNotificationFrequency = "1.00:00:00" # Once a day. May also be set to 4hrs.
}

$AlertParams = @{
AggregationType = "None"
Operation = "QuarantineRequestReleaseMessage"
Category = "ThreatManagement"
name = "$MSP Release Request Notifications"  # $MSP from Main, do not change.
NotifyUser = "$qAdmin" #from Main, do not change.
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
    EnableExternalSenderAdminNotifications = $false #optional. Notifies an admin if malware received from exeternal.
    ExternalSenderAdminAddress = $null #optional for above
    EnableInternalSenderAdminNotifications = $true #optional. Notifies admin for internal malware emails
    InternalSenderAdminAddress = "$qAdmin" # optional for above.
    QuarantineTag = "AllowReleaseRequests" # update in function
    EnableFileFilter = $true
    AdminDisplayName = "generated via PowerShell script."
    FileTypeAction = "Reject" 
    FileTypes = "ade", "adp", "app", "asp", "asx", "bas", "bat", "chm", "cmd", "com", "cpl", "crt", "csh", "der", "exe", "fxp", "gadget", "hlp", "hta", "inf", "ins", "isp", "its", "jar", "jse", "ksh", "lnk", "mad", "maf", "mag", "mam", "maq", "mar", "mas", "mat", "mau", "mav", "maw", "mda", "mdb", "mde", "mdt", "mdw", "mdz", "msc", "msh", "msh1", "msh2", "mshxml", "msh1xml", "msh2xml", "msi", "msp", "mst", "ops", "pcd", "pif", "pl", "prf", "prg", "ps1", "ps1xml", "ps2", "ps2xml", "psc1", "psc2", "reg", "scf", "scr", "sct", "shb", "shs", "url", "vb", "vbe", "vbs", "vsmacros", "vss", "vst", "vsw", "ws", "wsc", "wsf", "wsh", "xnk"
}

$SafeAttachmParams= @{
    Name = "$MSP Safe Attachments policy"
    Action = "Block"
    QuarantineFlag = $null # Update in Function.
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
    HighConfidenceSpamQuarantineTag = "AllowReleaseRequests" # update in Function
    HighConfidencePhishQuarantineTag = "AllowReleaseRequests" # update in function.
}

$OutboundSpamParams = @{
    RecipientLimitExternalPerHour = 500
    RecipientLimitInternalPerHour = 500
    RecipientLimitPerDay = 1000
    ActionWhenThresholdReached = 'BlockUser'
    NotifyOutboundSpamRecipients = "$qAdmin"  # From Main, do not change.
    NotifyOutboundSpam = $true
    AutoForwardingMode = 'Off'
    BccSuspiciousOutboundMail = $true
    BccSuspiciousOutboundAdditionalRecipients = "$qAdmin"
    }

$AntiPhishParams = @{
    Enabled = $True
    Name = "$MSP Anti-Phishing Policy"
    TargetedUsersToProtect = @() # update in function
    ImpersonationProtectionState = "Manual"
    EnableTargetedUserProtection = $True
    EnableTargetedDomainsProtection = $True # Enables protection for custom domains, can be configured online
    EnableOrganizationDomainsProtection = $True # Protects all domains registered to this 365 Tenant
    EnableMailboxIntelligence = $True
    EnableMailboxIntelligenceProtection = $True
    EnableFirstContactSafetyTips = $True
    EnableSimilarUsersSafetyTips = $True # Warns users of potential user impersonation
    EnableSimilarDomainsSafetyTips = $True # Warns users of potential domain impersonation
    EnableUnusualCharactersSafetyTips = $True # same as above, distinction unclear
    TargetedUserProtectionAction = "Quarantine"  # Quarantines messages sent by impersonators ex: c1bc.com, includes top-level domains (.ca/,com)
    TargetedUserQuarantineTag = "AllowReleaseRequests" # update in function
    TargetedDomainProtectionAction = "Quarantine" # Quarantines messages sent by impersonators ex: y0urboss@domain.com
    TargetedDomainQuarantineTag = "AllowReleaseRequests" # update in function
    MailboxIntelligenceProtectionAction = "MoveToJmf"
    AuthenticationFailAction = "MoveToJmf"
    EnableSpoofIntelligence = $True # Enables anti-spoofing AI kit. This should be monitored via the Spoof Intelligence Insight page.
    EnableViaTag = $True
    EnableUnauthenticateddSender = $True
    HonorDmarcPolicy = $True
    DmarcRejectAction = "Reject"
    DmarcQuarantineAction = "Quarantine"
    PhishThresholdLevel = 2
    }

$InboundSpamParams = @{
    Name = "$MSP Inbound Spam policy"
    QuarantineRetentionPeriod = 30
    SpamAction = "MoveToJmf"
    BulkSpamAction = "MoveToJmf"
    PhishSpamAction = "MoveToJmf"
    BulkThreshold = 6
    ZapEnabled = $true
    InlineSafetyTipsEnabled = $true
    PhishZapEnable =  $true
    HighConfidencePhishAction = "Quarantine"
    HighConfidenceSpamAction = "Quarantine" 
    HighConfidenceSpamQuarantineTag = "AllowReleaseRequests"
    HighConfidencePhishQuarantineTag = "AllowReleaseRequests"

}

$OutboundSpamParams = @{
    RecipientLimitExternalPerHour = 500
    RecipientLimitInternalPerHour = 500
    RecipientLimitPerDay = 1000
    ActionWhenThresholdReached = 'BlockUser'
    NotifyOutboundSpamRecipients = "$qAdmin"
    NotifyOutboundSpam = $true
    AutoForwardingMode = 'Off'
}