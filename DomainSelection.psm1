# DomainSelection.psm1
# This module provides the functionality for selecting domains from a list.
# Working

function Select-Domains {
    param(
        [array]$availableDomains  #takes the array of domains
    )
    $domains = @() #array to hold results
    # loop to select
    while ($true) 
        Write-Host "Domains selected: $domains"
        $userInput = Read-Host "Input a domain, 'all' for all, or 'next' when done."

        if ($userInput -eq "next" -and $domains.Count -eq 0) {
            Write-Host "No domains selected. Please input at least one domain or type 'all' to select all."
        } 
            
        # grabs all domains from $domainsAll
        if ($userInput -eq "all") {
            $domains = $availableDomains
            Write-Host "You have selected all the domains: $domains"
            break #end loop
        }

        # add input matching all domains to selected domains
        if ($availableDomains -contains $userInput) {
            $domains += $userInput
            Write-Host "$userInput has been added. Input another domain, or 'next' to continue. Selected domains: $domains"
        } 
        
        if ($userInput -eq "next") {
            break  # end loop
        } else {
            Write-Host "Invalid domain. Please enter domains one by one."
        }
    }

    # returns selected domains
    return $domains
}
