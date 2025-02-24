# Will not work in the ISE as that does not support interactive login
# For non-federated environments using separate admin accounts for each tenant
# Maintenance items: Recommmendation date(7)

# Connects to ExchangeOnlineManagement
Write-Host "This script is used for non-federated MSP environments (environments with separate admin accounts). Recommendations are dated 2/21/25." 
Start-Sleep -Seconds 2
Read-Host -Prompt "You will be asked to login to the tenant admin. Press enter to start." 
Connect-ExchangeOnline; 
$tenant = (Get-OrganizationConfig).Identity
Write-Host "Connected to tenant: $tenant"
$MSP = Read-Host -Prompt "Enter the MSP/Management company name. Policies will be named (company) Standard Policy".  
# Get tenant domains, get just the DomainName
$domains = Get-AcceptedDomain | Select-Object DomainName; $domains 

# Enables Mailtips
Set-OrganizationConfig -MailTipsAllTipsEnabled $true -MailTipsExternalRecipientsTipsEnabled $true -MailTipsGroupMetricsEnabled $true -MailTipsLargeAudienceThreshold '25'; 
Write-Host "MailTips enabled"

# Disables additional storage on OWA
Set-OwaMailboxPolicy -Identity OwaMailboxPolicy-Default -AdditionalStorageProvidersAvailable $false; 
Write-Host "Additional storage providers disabled on OWA"

<#############################################>
# Safe Links. Creates Standard Safe Links policy with recommended values, assigns it to all domains
$policyName = "$MSP Standard Safe Links policy";  
$params = @{    # hash table of values (like a dict)
Name =  $policyName
EnableForEmail = $true
EnableForTeams = $true
EnableForOFficeApps = $true
TrackClicks = $True
DoNotAllowClickThrough = $true
DoNotDisplayBranding = $true
}
# New-SafeLinksPolicy -Name $policyName -EnableforEmail $true
New-SafeLinksPolicy @params
# Creates a rule assigning all owned domains to this policy
New-SafeLinksRule -Name "$policyName - All Domains" SafeLinksPolicy $policyName -RecipientDomainIs $domains
# Assigns final elements of policy
Set-SafeLinksPolicy -Identity $policyName -EnableForInternalEmail $true -EnableRealTimeScanning $true -WaitForURLScanning $true
Write-Host "Recommended SafeLinks policy created, assigned to all domains - $policyName
<###############################################>
# Safe Attachments. Creates a custom Safe Attachments policy and assigns the domain. 
$policyName = "$MSP Standard Safe Attachments Policy"
$params = @{
    Name = $policyName
    Action = "Block"
    QuarantinePolicy = "AdminOnlyAccessPolicy"
    EnableRedirect = $false
}
New-SafeAttachmentPolicy @params
# Assign the policy to all domains
New-SafeAttachmentRule -Name "$policyName - All Domains" -SafeAttachmentPolicy $policyName -RecipientDomainIs $domains
Write-Host "Custom Safe Attachments policy created and assigned to all domains: $policyName"
<###############################################>
# Anti-Malware policy. Create a new Malware Filter policy and assign it to all domains
$policyName = "$MSP Standard Malware Filter Policy"
$params = @{
    Name = $policyName
    EnableFileFilter = $true
    Action = "Reject"  # Action to take on malicious emails
    FileTypes = "ade", "adp", "app", "asp", "asx", "bas", "bat", "chm", "cmd", "com", "cpl", "crt", "csh", "der", "exe", "fxp", "gadget", "hlp", "hta", "inf", "ins", "isp", "its", "jar", "jse", "ksh", "lnk", "mad", "maf", "mag", "mam", "maq", "mar", "mas", "mat", "mau", "mav", "maw", "mda", "mdb", "mde", "mdt", "mdw", "mdz", "msc", "msh", "msh1", "msh2", "mshxml", "msh1xml", "msh2xml", "msi", "msp", "mst", "ops", "pcd", "pif", "pl", "prf", "prg", "ps1", "ps1xml", "ps2", "ps2xml", "psc1", "psc2", "reg", "scf", "scr", "sct", "shb", "shs", "url", "vb", "vbe", "vbs", "vsmacros", "vss", "vst", "vsw", "ws", "wsc", "wsf", "wsh", "xnk"
}

# Create Malware Filter Policy
New-MalwareFilterPolicy @params

# Assign the policy to all domains
New-MalwareFilterRule -Name "$policyName - All Domains" MalwareFilterPolicy $policyName -RecipientDomainIs $domains
Write-Host "Malware Filter policy created and assigned to all domains: $policyName"
<###############################################>


<###############################################>
