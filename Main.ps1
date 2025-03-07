<#  Main.ps1  ######################################################
The main script, a WIP
Impoves on SecureScoreFix.ps1 and SSlowImpact.ps1 by modularizing different calls
Variables for configuratio are all stored in Variables.ps1 to allow for easy review.
Goal: have this execute all changes as moddules/functions.
Goal: Have external variables file that includes all params, for easy tweaking..
Goal: Notes on all variables in Variables.ps1, so people can understand what they do.



####################################################################>
Import-Module .\DomainSelection.psm1
Import-Module .\QuarantineSetup.psm1
$logFile = Join-Path $PSScriptRoot "SecureScore_log.txt"
Import-Module .\fileLog.psm1
function p {Start-Sleep -Seconds 1}
 
$failedProcesses = @()
$domains = @()
$policyName = $null
$user = $env:USERNAME

Write-Host "This script will apply Secure Score recommendations to tenant. Recommendations are dated 2/21/25."; &p
$MSP = Read-Host -Prompt "Enter a company/label for policy naming. Policies will be named `"[company]`'s Standard Policy`""
# following param is only available on Global policy. Can be done by PS, but low priority.
#$qSender = Read-Host -Prompt "Specify an email to send quarantine notices to users FROM. This must be an existing internal sender. If input is blank, will default to 'quarantine@messaging.microsoft.com.'"
$qAdmin = Read-Host -Prompt "Specify an email to send Quarantine Release Requests TO. 
This can be configured with a shared mailbox or ticketing endpoint."
$upn = Read-Host -Prompt "Enter your 365 admin username. Ex: john@company.com  
If you login to Windows with this, you will not need to input a password.
Otherwise, you will be prompted to authenticate via a browser window TWICE - Once for ExchangeOnlineManagement and once for IPPS Session (for alert config). `
Input login now"

# Setup connection log entry
try { 
    Connect-ExchangeOnline -userprincipalname $upn
    Write-Host "Connected to ExchangeOnline Successfully. Attempting connection to IPPSsession."
    try {
        Connect-IPPSSession -userprincipalname $upn
        Write-Host "Connected to IPPSsession successfully. A log file will be created on the desktop."
        } 
        catch {
        Write-Host "Connection to Security and Compliance Center not authorized."
        }
    } 
    catch {
    write-Host "Connection to ExchangeOnline not authorized."
}

$tenant = (Get-OrganizationConfig).Identity
$domainsAll = (Get-AcceptedDomain).DomainName
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
$logFile = Join-Path $desktopPath "SecureScore_log.txt"
$global:logFile = $logFile
    logMe -level "Start" -message "Connected to $tenant with user $upn"
Write-Host "You have connected to tenant $tenant, with the following domains: $($domainsAll -join ', ')"; &p
Write-Host "Please input domains to target. Type the domain from the list above, and press enter to include it."; &p
$domains = Select-Domains -availableDomains $domainsAll
    logMe -level "Info" -message "Domains selected : $domains"

# pull variables and construct hash tables
Write-Host "Getting params from Variables.ps1"
try {
    . ./Variables.ps1
    logMe -level "Info" -message "Successfully imported Variables.ps1"
} catch {
    logMe -level "ErrorMain" -Write $true -message "Error importing Variables.ps1: $_"
}

Write-Host "Finished setting up parameters. Applying configuration now."; &p;  &p;
# set MailTips 
try {
    # Attempt to run the Set-OrganizationConfig command
    Set-OrganizationConfig @paramsMailTips 
    logMe -level "Info" -write $true -message 'Mailtips enabled'
} catch { 
    logMe -level "ErrorMain" -message "Error enabling MailTips: $_"
    $failedProcesses += "MailTips"
    }


# Set Quarantine and Alert policy using quarantineSetup.psm1
try {
    QuarantineSetup -paramsQuarantine $paramsQuarantine
    if ($qPolicy) {
    logMe -level "Info" -write $true -Message "quarantine and Alerts set up."
    } else {
    logMe -level "Main error" -Message "QuarantineSetup successful, but Main did not receive new quarantine policy"
    $failedProcesses += "Quarantine Setup"
    }
} catch {
    logMe -level "Main error" -message "Failed calling QuarantineSetup: $_"
    $failedProcesses += "Quarantine setup"
}
