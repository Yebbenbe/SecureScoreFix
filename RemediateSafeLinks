# This script will check for existing SafeLinks rules - policy and domain pairings.
# If found, it will check the settings and assignmeents against the desired ones/all domains
# if mismatched, will set them. 
# get domains
$domains = Get-AcceptedDomain | Select-Object DomainName; $domains

# get all existing Safe Links rules
$existingRules = Get-SafeLinksRule

# check if any rule exists and if its settings match the desired configuration
$existingRule = $existingRule

# If an existing rule is found, use its policy name
if ($existingRule) {
    Write-Host "Safe Links rule found."

    # Set the policy name from the existing rule (if any)
    $policyName = $existingRule.SafeLinksPolicy

    # Track mismatches
    $mismatches = @()

    # Check if the rule's settings match the desired configuration
    foreach ($key in $desiredParams.Keys) {
        if ($existingRule."$key" -ne $desiredParams[$key]) {
            # Add mismatch to the list
            $mismatches += "$key: Current = $($existingRule."$key"), Desired = $($desiredParams[$key])"
        }
    }

    # If there are mismatches, display them
    if ($mismatches.Count -gt 0) {
        Write-Host "The following mismatches were found in the Safe Links rule settings:"
        $mismatches | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "No mismatches found for Safe Links rule settings."
    }

    # Check if the rule's domains match the accepted domains
    $existingDomains = $existingRule.RecipientDomainIs
    $domainsList = $domains.DomainName
    if ($existingDomains -ne $domainsList) {
        Write-Host "Domains in the rule do not match. Domains in the rule are: $existingDomains"
        Write-Host "The correct domains should be: $domainsList"
        # Add domain mismatch to the list
        $mismatches += "Domain mismatch: Current = $existingDomains, Desired = $domainsList"
    }

    # If any mismatches were found, prompt the user to apply changes
    if ($mismatches.Count -gt 0) {
        Write-Host "There are mismatches that need to be fixed. Do you want to update the Safe Links rule? (Y/N)"
        $userInput = Read-Host
        if ($userInput -eq "Y") {
            # Apply changes to the rule
            Write-Host "Updating Safe Links rule..."

            # Update settings
            Set-SafeLinksRule -Identity $existingRule.Identity @desiredParams
            Write-Host "Safe Links rule updated with correct settings."

            # Update domains
            Set-SafeLinksRule -Identity $existingRule.Identity -RecipientDomainIs $domainsList
            Write-Host "Safe Links rule updated with correct domains."
        } else {
            Write-Host "No updates were made to the Safe Links rule."
        }
    }
    else {
        Write-Host "No mismatches detected. Safe Links rule is correct."
    }
} else {
    Write-Host "No existing Safe Links rule found. Creating new rule for all domains..."
    $policyName = "Standard Safe Links policy"
    # create a safe Links policy with required params, and a rule linking it to the domains
    New-SafeLinksPolicy @desiredParams
    Write-Host "Safe Links policy created."
    New-SafeLinksRule -Name "$policyName - All Domains" SafeLinksPolicy $policyName -RecipientDomainIs $domains
    Write-Host "Safe Links rule created, assigning all domains to $policyName."


}

# Assign final elements to the policy after rule has been created or updated
Set-SafeLinksPolicy -Identity $policyName -EnableForInternalEmail $true -EnableRealTimeScanning $true -WaitForURLScanning $true
Write-Host "Recommended SafeLinks policy created, assigned to all domains - $policyName"
