<#  Main.ps1  ######################################################
The main script. Run this, not others. (WIP)
Goal: have this execute all changes as moddules/functions.
Goal: Have external variables file that includes all params, for easy tweaking..




####################################################################>
Import-Module .\DomainSelector.psm1
Import-Module .\QuarantineSetup.psm1
$logFile = Join-Path $PSScriptRoot "SecureScore_log.txt"
Import-Module .\fileLog.psm1
function p {Start-Sleep -Seconds 1}
 
# $tenant = $null
# $MSP = $null
$domains = @()
$policyName = $null
$user = $env:USERNAME

Write-Host "This script is used for non-federated MSP environments (environments with separate admin accounts). Recommendations are dated 2/21/25."; &p
Write-Host "For items that get quarantined, users will get a daily notification and will be able to request the item's release.";  &p
$MSP = Read-Host -Prompt "Enter a company/label for policy naming. Policies will be named `"[company]`'s Standard Policy`""
$qSender = Read-Host -Prompt "Specify an email to send quarantine notices to users FROM. This must be an existing internal sender. If input is blank, will default to 'quarantine@messaging.microsoft.com.'"
$qAdmin = Read-Host -Prompt "Specify an email to send Quarantine Release Requests TO. This can be configured with a shared mailbox or ticketing endpoint."
Read-Host -Prompt "You will be asked to login to the tenant admin. Press enter to start."
logMe -level "info" -message "Launching login window."
# Setup connection log entry 1
Connect-ExchangeOnline;
$tenant = (Get-OrganizationConfig).Identity
$domainsAll = (Get-AcceptedDomain).DomainName
$logFile = Join-Path $PSScriptRoot "$tenant-log.txt"
    $global:logFile = $logFile
    logMe -level "Start" -message "Connected to $tenant"
Write-Host "You have connected to tenant $tenant, with the following domains: $($domainsAll -join ', ')"; &p
Write-Host "Please input domains to target. Type the domain from the list above, and press enter to include it."; &p
    $domains = Select-Domains -availableDomains $domainsAll
    logMe -level "Info" -message "Domains selected : $domains"
Write-Host "Getting params from Variables.ps1"
try {
    . ./Variables.ps1
    logMe -level "Info" -message "Successfully imported Variables.ps1"
} catch {
    logMe -level "Error" -message "Error importing Variables.ps1: $_"
}

try {
    # Attempt to run the Set-OrganizationConfig command
    Set-OrganizationConfig @paramsMailTips 
    logMe -level "Info" -message 'Mailtips enabled'
} catch { 
    logMe -level "Error" -message "Error enabling MailTips: $_"
    }







# Prompt for $msp, $tenant, $domains, BEFORE immporting Variables.
# This is because althought $MSP from Variables will update
# the hash table that uses $MSP will not.