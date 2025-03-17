#otherConfig.psm1
#deprecated, moved to ThreatPolicies.psm1

function MailTips {
    param(
        [hashtable]$MailTipsParams
        ) 

  try {
        Set-OrganizationConfig @MailTipsParams
        logMe -level "Info" -message "MailTips configuration '$policyName' applied successfully."

        Set-OwaMailboxPolicy -Identity OwaMailboxPolicy-Default -AdditionalStorageProvidersAvailable $false
        logMe -level "Info" -message "MailTips configuration applied and additional settings configured."

    } catch {
        logMe -level "MailTipsSetup" -message "Error in MailTips setup: $_"
    }
 }