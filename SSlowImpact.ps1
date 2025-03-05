# Low-impact SecureScore fixes
<# Fixes


#>
Import-Module .\DomainSelector.psm1
$logFile = Join-Path $PSScriptRoot "SecureScore_log.txt"
Import-Module .\fileLog.psm1

$tenant = $null
$MSP = $null
$domains = @()
$policyName = $null
$user = $env:USERNAME  # For desktop shortcuts to email filter review
function p {Start-Sleep -Seconds 1}
Write-Host "This script is used for non-federated MSP environments (environments with separate admin accounts). Recommendations are dated 2/21/25."; &p
Write-Host "This version of the script will make only low-impact changes.";  &p
$MSP = Read-Host -Prompt "Enter a company/label for policy naming. Policies will be named `"[company]`'s Standard Policy`"" 
Read-Host -Prompt "You will be asked to login to the tenant admin. Press enter to start."
# Setup connection log entry 1
Connect-ExchangeOnline;
$tenant = (Get-OrganizationConfig).Identity
$logFile = Join-Path $PSScriptRoot "$tenant-log.txt"
$global:logFile = $logFile
logMe -level "Start" -message "Connected to $tenant"
$domainsAll = (Get-AcceptedDomain).DomainName
Write-Host "You have connected to tenant $tenant, with the following domains: $($domainsAll -join ', ')"; &p #subexpression operator, anon string of domains
#$domains = $inputDomains -split ",\s*"  # regex for , with zero or more spaces. \s = any whitespace character,  * = zero or more.
Write-Host "You will be asked what domains to apply these policies to. These may be applied to all domains or only domains with email."; &p
Write-Host "Input one at a time."; &p
$domains = Select-Domains -availableDomains $domainsAll
logMe -level "1" -message "Domains selected : $domains"
<# moved to it's own module
$domains = @()
while ($true) {
    $userInput = Read-Host "Enter a domain (or type 'next' to finish)"
    if ($userInput -eq "next") {
        break
    }
    # If the user types 'all', select all domains
    if ($userInput -eq "all") {
        $domains = $domainsAll  # Add all domains
        Write-Host "You have selected all the domains."
        break  # Exit loop after selecting all domains
    }
    if ($domainsAll -contains $userInput) {
        $domains += $userInput
        Write-Host "$userInput has been added."
    } else {
        Write-Host "Invalid domain. Please enter a valid domain from the list."
    }
} #>

# Enables Mailtips Log Entry 2
Set-OrganizationConfig -MailTipsAllTipsEnabled $true -MailTipsExternalRecipientsTipsEnabled $true -MailTipsGroupMetricsEnabled $true -MailTipsLargeAudienceThreshold '25'; 
logMe -level 2 -message 'Mailtips enabled'

# Disables additional storage on OWA Log Entry 3
Set-OwaMailboxPolicy -Identity OwaMailboxPolicy-Default -AdditionalStorageProvidersAvailable $false; 
logMe -level 3 -message 'Additional storage providers limited'

# Quarantine Notifcation Log Entry 4
New-QuarantinePolicy -Identity "Allow Quarantine Release Requests" -EndUserQuarantinePermissionsValue 139 -AdminDisplayName 'Allows users to see previews and request release, sends notif to user'
-ESNEnabled $true -QuarantineRetentionDays 30 
logMe -level 4 -message "Quarantine Policy created `'Allow Quarantine Release Requests`'"

# Safe Links Policy Log Entry 5 ###################################################
$policyName = "$MSP Standard Safe Links policy";  
$params = @{  
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
logMe -level 5 -message "Recommended SafeLinks policy created, assigned to all domains - $policyName"
logMe -level 5 -message "Settings: $params"

# Malware Filter Policy Log Level 6 ###############################################
#Low-impact params
$params = @{
    QuarantineTag = 'Allow Quarantine Release Requests'
    ZapEnabled = $true
    EnableFileFilter = $true
    FileTypeAction = "Reject"  # action to take on malicious emails
    FileTypes = "ade", "adp", "app", "asp", "asx", "bas", "bat", "chm", "cmd", "com", "cpl", "crt", "csh", "der", "exe", "fxp", "gadget", "hlp", "hta", "inf", "ins", "isp", "its", "jar", "jse", "ksh", "lnk", "mad", "maf", "mag", "mam", "maq", "mar", "mas", "mat", "mau", "mav", "maw", "mda", "mdb", "mde", "mdt", "mdw", "mdz", "msc", "msh", "msh1", "msh2", "mshxml", "msh1xml", "msh2xml", "msi", "msp", "mst", "ops", "pcd", "pif", "pl", "prf", "prg", "ps1", "ps1xml", "ps2", "ps2xml", "psc1", "psc2", "reg", "scf", "scr", "sct", "shb", "shs", "url", "vb", "vbe", "vbs", "vsmacros", "vss", "vst", "vsw", "ws", "wsc", "wsf", "wsh", "xnk"
}
$malwareFilterRule = Get-MalwareFilterRule | Where-Object { $_.State -eq 'Enabled' }
if ($malwareFilterRules.Count -gt 0) {
    foreach ($rule in $malwareFilterRules) {
        # get the associated MalwareFilterPolicy
        $policyName = $rule.MalwareFilterPolicy
        $malwareFilterPolicy = Get-MalwareFilterPolicy -Identity $policyName
        # update param
        Set-MalwareFilterPolicy -Identity $policyName @params
        Set-MalwareFilterRule -Identity $rule.Name -RecipientDomainIs $domains
        logMe -level 6 -message "MalwareFilterPolicy '$policyName' updated successfully."
        logMe -level 6 -message "Settings: $params"
    }
    } else {
        $policyName = "$MSP Standard Anti-Malware Policy"
        New-MalwareFilterPolicy -Name "iSpire Standard Policy" @params
        New-MalwareFilterRule -Name "$policyName - All Domains" -MalwareFilterPolicy $policyName -RecipientDomainIs $domains
        logMe -level 6 -message "Recommended Malware Policy created, assigned to all domains - $policyName"
        logMe -level 6 -message "Settings: $params"
    }


# Safe Attachments Policy Log level 7 ################################################
$params = {
    Action = "Block"
    QuarantineFlag = "Allow Quarantine Release Requests"
    EnableRedirect = $false
    AdminDisplayName = "generated via PowerShell script."
}
$safeAttachmentRules = Get-SafeAttachmentRule | Where-Object { $_.State -eq 'Enabled' }
# Check if any rules are found
if ($safeAttachmentRules.Count -gt 0) {
    foreach ($rule in $safeAttachmentRules) {
        # Get the associated SafeAttachmentPolicy
        $policyName = $rule.SafeAttachmentPolicy
        $safeAttachmentPolicy = Get-SafeAttachmentPolicy -Identity $policyName
        # Update parameters on the SafeAttachmentPolicy using the hashtable
        Set-SafeAttachmentPolicy -Identity $policyName @params
        logMe -level 7 -message "Safe Attachments policy updated and assigned to domains - $policyName"
        logMe -level 7 -message "Settings: $params"
    }
} else {
    # Create a new SafeAttachmentPolicy if no rules are found
    $policyName = "$MSP Standard Safe Attachments Policy"
    New-SafeAttachmentPolicy -Name $policyName @params
    New-SafeAttachmentsRule -Name "$policyName - All Domains" -SafeAttachmentsPolicy $policyName -RecipientDomainIs $domains
    }


# Anti Spam INBOUND Policy Log level 7 ######################################################
params = @{
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
$AntiSpamRules = Get-HostedContentFilterRule | Where-Object ($_.State -eq 'Enabled')
if ($AntiSpamRules.Count -gt 0) {
    foreach ($rule in $AntiSpamRules) {
        $policyName = $rule.HostedContentFilterPolicy
        $AntiSpamPolicy = Get-HostedContentFilterPolicy -Identity @policyName
        Set-HostedContentFilterPolicy -Identity $policyName @params
        Write-Output "Anti Spam Filter Policy '$policyName' updated successfully" 
        logMe -level 7 -message 'Inbound Spam policy updated: $policyName'
        logMe -level 7 -settings "Settings: $params"
    }
} else {
    #Create a new Anti-Spam policy
    $policyName = "$MSP Standard Spam Policy"
    New-HostedContentFilterPolicy -Name $policyName $params
    New-HosteddContentFilterRule -Name "$policyName - All Domains" -HostedContentFilterPolicy $policyName -RecipientDomainIs $domains
    logMe -level 7 -message 'Inbound Spam policy created: $policyName'
    logMe -level 7 -settings "Settings: $params"
    }

# Anti Spam OUTBOUND Policy ##################################3
    $params = @{
    RecipientLimitExternalPerHour = 500
    RecipientLimitInternalPerHour = 500
    RecipientLimitPerDay = 1000
    ActionWhenThresholdReached = 'BlockUser'
    NotifyOutboundSpamRecipients = 'o365security@ispire.ca' 
    NotifyOutboundSpam = $true
    AutoForwardingMode = 'Off'
    }
$AntiSpamRules = Get-HostedOutboundSpamFilterRule | Where-Object ($_.State -eq 'Enabled')
if ($AntiSpamRules.Count -gt 0) {
    foreach ($rule in $AntiSpamRules) {
        $policyName = $rule.HostedOutboundSpamFilterPolicy
        $AntiSpamPolicy = Get-HostedOutboundSpamFilterPolicy -Identity @policyName
        Set-HostedOutboundSpamFilterPolicy -Identity $policyName @params
        Write-Output "Anti Spam Outbound Policy '$policyName' updated successfully" 
    }
} else {
    #Create a new Anti-Spam policy
    $policyName = "ispire Standard Outbound Spam Policy"
    New-HostedOutboundSpamFilterPolicy -Name $policyName $params
    New-HostedOutboundSpamFilterRule -Name "$policyName - All Domains" -HostedContentFilterPolicy $policyName -RecipientDomainIs $domains
    }
