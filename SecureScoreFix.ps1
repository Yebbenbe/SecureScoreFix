# Will not work in the ISE as that does not support interactive login
# For non-federated environments using separate admin accounts for each tenant
# creates new, approved policy and assigns all domains to it - if custom rules are configured, they will need to be revised after
# requires a Defender P1 and Entra P1 license (these can simply be on admin account)
# Maintenance items: Recommmendation date(7)
#############################################
# Global vars
$urls = @{
    "Quarantine (recommend review)" = "https://security.microsoft.com/quarantine"
    "Impersonation Insight" = "https://security.microsoft.com/impersonationinsight"
    "Spoof Intelligence (recommend review)" = "https://security.microsoft.com/spoofintelligence"
    "Bulk Senders Insight" = "https://security.microsoft.com/senderinsights"
  
}
$tenant = $null
$MSP = $null
$domains = @()
$policyName = $null
$user = $env:USERNAME  # For desktop shortcuts to email filter review
$desktopPath = "C:\Users\$user\Desktop"   # for above
#############################################
# Connects to ExchangeOnlineManagement
Write-Host "This script is used for non-federated MSP environments (environments with separate admin accounts). Recommendations are dated 2/21/25." 
Start-Sleep -Seconds 2
Read-Host -Prompt "You will be asked to login to the tenant admin. Press enter to start." 
Connect-ExchangeOnline; 
$tenant = (Get-OrganizationConfig).Identity
Write-Host "Connected to tenant: $tenant"
$domains = (Get-AcceptedDomain).DomainName
$MSP = Read-Host -Prompt "Enter the MSP/Management company name. Policies will be named `"(company) Standard Policy`""  
#############################################
Set-OrganizationConfig -MailTipsAllTipsEnabled $true -MailTipsExternalRecipientsTipsEnabled $true -MailTipsGroupMetricsEnabled $true -MailTipsLargeAudienceThreshold '25'; 
Write-Host "MailTips enabled"

# Disables additional storage on OWA
Set-OwaMailboxPolicy -Identity OwaMailboxPolicy-Default -AdditionalStorageProvidersAvailable $false; 
Write-Host "Additional storage providers disabled on OWA"

#############################################

# Safe Links. Creates Standard Safe Links policy with recommended values, assigns it to all domains
$policyName = "$MSP Standard Safe Links policy";  
$params = @{    # hash table of values (like a dict)
Name =  $policyName
EnableSafeLinksForEmail = $true
EnableSafeLinksForTeams = $true
EnableSafeLinksForOFfice = $true
TrackClicks = $True
AllowClickThrough = $false
EnableOrganizationBranding = $false
AdminDisplayName = "generated via PowerShell script."
}
New-SafeLinksPolicy @params
# Creates a rule assigning all owned domains to this policy
New-SafeLinksRule -Name "$policyName - All Domains" -SafeLinksPolicy $policyName -RecipientDomainIs $domains
# Assigns final elements of policy
Set-SafeLinksPolicy -Identity $policyName -EnableForInternalSenders $true -ScanUrls $true -DeliverMessageAfterScan $true
Write-Host "Recommended SafeLinks policy created, assigned to all domains - $policyName"

###############################################

# Safe Attachments. Creates a custom Safe Attachments policy and assigns the domain. 
$policyName = "$MSP Standard Safe Attachments Policy"
$params = @{
    Name = $policyName
    Action = "Block"
    QuarantineFlag = "AdminOnlyAccessPolicy"
    EnableRedirect = $false
    AdminDisplayName = "generated via PowerShell script."
}
# create new policy
New-SafeAttachmentPolicy @params
# assign the policy to all domains
New-SafeAttachmentRule -Name "$policyName - All Domains" -SafeAttachmentPolicy $policyName -RecipientDomainIs $domains
Write-Host "Custom Safe Attachments policy created and assigned to all domains: $policyName"

###############################################

# Anti-Malware policy. Create a new Malware Filter policy and assign it to all domains
$policyName = "$MSP Standard Malware Filter Policy"
$params = @{
Name = $policyName
    ZapEnabled = $true
    EnableExternalSenderAdminNotifications = $false
    EnableInternalSenderAdminNotifications = $false
    ExternalSenderAdminAddress = 'o365security@ispire.ca'
    QuarantineTag = 'AdminOnlyAccessPolicy'
    EnableFileFilter = $true
    AdminDisplayName = "generated via PowerShell script."
    FileTypeAction = "Reject"  # action to take on malicious emails
    FileTypes = "ade", "adp", "app", "asp", "asx", "bas", "bat", "chm", "cmd", "com", "cpl", "crt", "csh", "der", "exe", "fxp", "gadget", "hlp", "hta", "inf", "ins", "isp", "its", "jar", "jse", "ksh", "lnk", "mad", "maf", "mag", "mam", "maq", "mar", "mas", "mat", "mau", "mav", "maw", "mda", "mdb", "mde", "mdt", "mdw", "mdz", "msc", "msh", "msh1", "msh2", "mshxml", "msh1xml", "msh2xml", "msi", "msp", "mst", "ops", "pcd", "pif", "pl", "prf", "prg", "ps1", "ps1xml", "ps2", "ps2xml", "psc1", "psc2", "reg", "scf", "scr", "sct", "shb", "shs", "url", "vb", "vbe", "vbs", "vsmacros", "vss", "vst", "vsw", "ws", "wsc", "wsf", "wsh", "xnk"
}
# create Malware Filter Policy
New-MalwareFilterPolicy @params

# assign the policy to all domains
New-MalwareFilterRule -Name "$policyName - All Domains" -MalwareFilterPolicy $policyName -RecipientDomainIs $domains
Write-Host "Malware Filter policy created and assigned to all domains: $policyName"

############################################
# Anti-phish 
$execs = Read-Host -Prompt "Please enter any critical executive/management person's emails for impersonation protection, separated by commas "  
$execsArray = $execs -split ","

$policyName = "$MSP Standard Phishing Protection Policy"
$params = @{
    Enabled = $True
    Name = $policyName
    TargetedUsersToProtect = $execsArray
    ImpersonationProtectionState = Manual
    EnableTargetedUserProtection = $True
    EnableTargetedDomainsProtection = $True # Enables protection for custom domains, can be configured online
    EnableOrganizationDomainsProtection = $True # Protects all domains registered to this 365 Tenant
    EnableMailboxIntelligence = $True
    EnableMailboxIntelligenceProtection = $True
    EnableFirstContactSafetyTips = $True
    EnableSimilarUsersSafetyTips = $True # Warns users of potential user impersonation
    EnableSimilarDomainsSafetyTips = $True # Warns users of potential domain impersonation
    EnableUnusualCharactersSafetyTips = $True # same as above, distinction unclear
    TargetedUserProtectionAction = Quarantine  # Quarantines messages sent by impersonators ex: c1bc.com, includes top-level domains (.ca/,com)
    TargetedUserQuarantineTag = AdminOnlyAccessPolicy
    TargetedDomainProtectionAction = Quarantine # Quarantines messages sent by impersonators ex: y0urboss@domain.com
    TargetedDomainQuarantineTag= AdminOnlyAccessPolicy
    MailboxIntelligenceProtectionAction = MoveToJmf
    AuthenticationFailAction = MoveToJmf
    EnableSpoofIntelligence = $True # Enables anti-spoofing AI kit. This should be monitored via the Spoof Intelligence Insight page.
    EnableViaTag = $True
    EnableUnauthenticateddSender = $True
    HonorDmarcPolicy = $True
    DmarcRejectAction = Reject
    DmarcQuarantineAction = Quarantine
    PhishThresholdLevel = 2
    }

New-AntiPhishPolicy @params
New-AntiPhishRule -Name "$policyName - All Domains" -AntiPhishPolicy $policyName -RecipientDomainIs $domains
Read-Host -Prompt "Anti-Phishing policy created. Spoof and Impersonation protection have been enabled for the folowing users: $execs. Spoof Intelligence Insights and Quarantine should`
both be monitored to maintain email deliverability. Links will be placed on your desktop to these. Press Enter to continue process."

############################################
# Add mail security review shortcuts
$user = $env:USERNAME
$desktopPath = "C:\Users\$user\Desktop"
foreach ($name in $urls.Keys) {  # iterates over $urls.keys to get the key:value, not just the values
    $url = $urls[$name]
    $shortcutPath = "$desktopPath\$name.url"
    $shortcutContent = "[InternetShortcut]`nURL=$url"
    Set-Content -Path $shortcutPath -Value $shortcutContent
}
