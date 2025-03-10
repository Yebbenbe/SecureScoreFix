# SafeLinks.psm1

function SafeLinks {
    param(
        [hashtable][ValidateNotNull()]$SafeLinksParams
        )

    $policyName = $SafeLinksParams['Name']

    try {
        New-SafeLinksPolicy @SafeLinksParams
        logMe -level "Info" -message "SafeLinks Policy '$policyName' created successfully. Creating rule."

        New-SafeLinksRule -Name "$policyName - All Domains" -SafeLinksPolicy $policyName -RecipientDomainIs $domains
        logMe -level "Info" -message "SafeLinks Rule created for all domains with policy: $policyName. Assigning final config."

        Set-SafeLinksPolicy -Identity $policyName -EnableForInternalSenders $true -ScanUrls $true -DeliverMessageAfterScan $true
        logMe -level "Info" -message "SafeLinks Policy '$policyName' configured successfully."
    } catch {
        logMe -level "SafeLinksSetup" -message "Error in SafeLinks setup: $_"
    }
}