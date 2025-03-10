# SafeLinks.psm1

function SafeLinks {
    param(
        [hashtable]$SafeLinksParams,
        )

     if ($SafeLinksParams -eq $null) {
        logMe -level "SafeLinksSetup" -message "SafeLinksSetup did not receive any SafeLinksParams"
        return} # exits the function
        }
    $policyName = $SafeLinksParams['Name']

try {
    # Create Safe Links Policy
    New-SafeLinksPolicy @SafeLinksParams
    logMe -level "Info" -message "SafeLinks Policy '$policyName' created successfully."

    # Create a Safe Links Rule for all domains
    New-SafeLinksRule -Name "$policyName - All Domains" -SafeLinksPolicy $policyName -RecipientDomainIs $domains
    logMe -level "Info" -message "SafeLinks Rule created for all domains with policy: $policyName"

    # Assign final elements of the policy
    Set-SafeLinksPolicy -Identity $policyName -EnableForInternalSenders $true -ScanUrls $true -DeliverMessageAfterScan $true
    logMe -level "Info" -message "SafeLinks Policy '$policyName' configured successfully."
} catch {
    logMe -level "SafeLinksSetup" -message "Error in SafeLinks setup: $_"
}