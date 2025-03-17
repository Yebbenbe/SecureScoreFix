<#  Main.ps1  ######################################################
The main script, a WIP
Impoves on SecureScoreFix.ps1 and SSlowImpact.ps1 by modularizing different calls
Variables for configuratio are all stored in Variables.ps1 to allow for easy review.
Goal: have this execute all changes as moddules/functions.
Goal: Have external variables file that includes all params, for easy tweaking..
Goal: Notes on all variables in Variables.ps1, so people can understand what they do.
Goal: For Rule+Policy combo's,  dynamically generate the cmdles from the function name, like was done in Main to the overall Fn's


####################################################################>
Import-Module .\DomainSelection.psm1
Import-Module .\fileLog.psm1
Import-Module .\ThreatPolicies.psm1

function p {Start-Sleep -Seconds 1}

# Set up log file
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
$logFile = Join-Path $desktopPath "SecureScore_log.txt"
$global:logFile = $logFile


# prompt for requisite inputs
Write-Host "This script will apply Secure Score recommendations to tenant. Recommendations are dated 2/21/25."; &p
$MSP = Read-Host -Prompt "Enter a company/label for policy naming. Policies will be named `"[company]`'s Standard Policy`""
$qAdmin = Read-Host -Prompt "`n Specify an email to send Quarantine Release Requests TO. `n This can be configured with a shared mailbox or ticketing endpoint."
$upn = Read-Host -Prompt "`n Enter your 365 admin username. Ex: john@company.com `n If you login to Windows with this, you will not need to input a password. Input login now."

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

# return tenant and prompt for domains
$tenant = (Get-OrganizationConfig).Identity
$domainsAll = (Get-AcceptedDomain).DomainName
Write-Host "_______________________ `n $($domainsAll -join ', ')"; &p
Write-Host "You have connected to $tenant, with the above domains associated. Next, you will input the domains you would like to configure. Recommended: all" ; &p
$domains = Select-Domains -availableDomains $domainsAll
    logMe -level "Info" -message "Domains selected : $domains"

# pull variables and construct hash tables
Write-Host "_______________________ `nGetting params from Variables.ps1"
try {
    . ./Variables.ps1
    logMe -level "Info" -message "Successfully imported Variables.ps1"
} catch {
    logMe -level "ErrorMain" -Write $true -message "Error importing Variables.ps1: $_"
}

Write-Host "Finished setting up parameters. Applying configuration now."; &p;  &p;

foreach ($function in $toFix) {
# need to call function, pass paramHash to functionParam
    # Dynamically build the param hashtable name
    $paramName = $function + "Params" # generates the name of the param hash table
    try {
        $functionParams = (Get-Variable -Name $paramName -ErrorAction Stop).Value #get the actual hashtable - simply a string
        if ($functionParams -eq $null) {
            logMe -level "ErrorMain" -message "Error generating $function param - param is null." # This checks that the non-null hash table isn't EMPTY, rather than $null
            return
        }
        # dynamically build the parameter name and call the function
        $param = @{ $paramName = $functionParams }  # equivalent to -$paramName = $functionParams, where $functionParams is the hashtable, and $paramName is the name of the param in the function.
        & $function @param #call that function, passing the hashtable as the single parameter
        logMe -level "info" -message "$function executed Successfully"
    } catch {
    logMe -level "ErrorMain" -message "Error executing $function : $_" 
    $failedProcesses += $function;
    }
    Read-Host -Prompt "$function config finished. Press Enter to continue."
}

# After all functions are executed, check failed processes
if ($failedProcesses.Count -gt 0) {
    logMe -level "ErrorMain" -message "The following processes failed: $($failedProcesses -join ', ')"
} else {
    logMe -level "Info" -message "All processes completed successfully."
}
