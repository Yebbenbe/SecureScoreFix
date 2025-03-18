<#   QuarantineSetup.psm1 #####################################
Module used by Main
Configures a quarantine policy to send user quarantine notifs.
Grants perms to view preview, delete, or request release.
Configures release requests to go to desired email. 

###############################################################>

#### REMINDER: QuarantineTag must be set manually, with the updated qPolicy. MalwareFilter,

# Handles MailTips and Additional Storage Provider policy
function MailTips {
    param([hashtable]$MailTipsParams) # checks if hash table is not null. If null, exits and errors.

    if (-not $MailTipsParams) {
        logMe -level "MailTipsSetup" -message "MailTips received empty param" # This checks that the non-null hash table isn't EMPTY, rather than $null
        return
    }

    try {
        Set-OrganizationConfig @MailTipsParams
        logMe -level "Info" -message "MailTips configuration '$policyName' applied successfully."

        Set-OwaMailboxPolicy -Identity OwaMailboxPolicy-Default -AdditionalStorageProvidersAvailable $false
        logMe -level "Info" -message "MailTips configuration applied and additional settings configured."
        Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true # enable audit log search

    } catch {
        logMe -level "MailTipsSetup" -message "Error in MailTips setup: $_"
    }
 }


function Quarantine {   # working
    param([hashtable]$QuarantineParams)

    if (-not $QuarantineParams) {
        logMe -level "Quarantinesetup" -message "Quarantine received empty param"
        return
    }

    try {
        New-QuarantinePolicy @QuarantineParams
        # $qPolicy = Get-QuarantinePolicy -Identity "$($QuarantineParams['Name'])"   ### redundant, this is now set to AllowReleaseRequests
        logMe -level "Info" -message "Quarantine Policy '$qPolicy' created successfully."
        return $qPolicy

    } catch {
        logMe -level "QuarantineSetup" -message "Error creating Quarantine Policy: $_"
    }   
}




function Alert {
    param ([hashtable]$AlertParams)
        
    if (-not $alertParams) {
            logMe -level "AlertSetup" -message "Alert received empty params"
            return
    }

    try {
        New-ProtectionAlert @AlertParams
        logMe -level "Info" -message "Protection alert created successfully, sends release alerts to $($AlertParams['NotifyUser'])"

    } catch {
        logMe -level "QuarantineSetup" -message "Error creating Protection Alert: $_"
    }
}




function SafeLinks {
    param([hashtable]$SafeLinksParams)

    if (-not $SafeLinksParams) {
        logMe -level "Quarantinesetup" -message "SafeLinks received empty param"
        return
    }
    $policyName = $SafeLinksParams['Name']
    try {
        New-SafeLinksPolicy @SafeLinksParams
        logMe -level "Info" -message "SafeLinks Policy '$policyName' created successfully. Creating rule."

        New-SafeLinksRule -Name "$policyName - Selected Domains" -SafeLinksPolicy $policyName -RecipientDomainIs $domains
        logMe -level "Info" -message "SafeLinks Rule assigned to domains."

        Set-SafeLinksPolicy -Identity $policyName -EnableForInternalSenders $true -ScanUrls $true -DeliverMessageAfterScan $true
        logMe -level "Info" -message "Secondary config elements set on Safe Links Policy."

    } catch {
        logMe -level "SafeLinksSetup" -message "Error in SafeLinks setup: $_"
    }
}


function MalwareFilter {
    param([hashtable]$MalwareFilterParams)

    if (-not $MalwareFilterParams) {
        logMe -level "MalwareFilterSetup" -message "MalwareFilter received empty param"
        return
    }

    # $MalwareFilterParams['QuarantineTag'] = $qPolicy #redundant, this is now set statically
    $policyName = $MalwareFilterParams['Name']
    try {
        New-MalwareFilterPolicy @MalwareFilterParams
        logMe -level "Info" -message "Malware Filter Policy '$policyName' created successfully. Creating rule."
        New-MalwareFilterRule -Name "$policyName - Selected Domains" -MalwareFilterPolicy $policyName -RecipientDomainIs $domains
        logMe -level "Info" -message "Malware Filter Policy paired with domains."
    } catch {
        logMe -level "MalwareFilterSetup" -message "Error in MalwareFilter setup: $_"
    }
}

function SafeAttach {
    param([hashtable]$SafeAttachParams)

    if (-not $SafeAttachParams) {
        logMe -level "SafeAttachmentsSetup" -message "SafeAttach received empty param"
        return
    }

    # $SafeAttachParams['QuarantineTag'] = $qPolicy #redundant, this is now set statically
    $policyName = $SafeAttachParams['Name']
    try {
    New-SafeAttachmentPolicy @params 
    New-SafeAttachmentsRule -Name "$policyName - Selected Domains" -SafeAttachmentsPolicy $policyName -RecipientDomainIs $domains
    logMe -level "Info" -message "New Safe Attachments policy created and assigned"
    } catch {
    logMe -level "SafeAttachSetup" -message "Error in SafeAttachSetup: $_"
    }
}



function AntiPhish {
    param([hashtable]$AntiPhishParams)

    if (-not $AntiPhishParams) {
        logMe -level "AntiPhishSetup" -message "AntiPhish received empty param"
    }
    # $AntiPhishParams['TargetedUserQuarantineTag'] = $qPolicy # redundant, set staticly
    # $AntiPhishParams['TargetedDomainQuarantineTag'] = $qPolicy # redundant, set staticly
    $policyName = $AntiPhishParams['Name']
    try {
        New-AntiPhishPolicy @AntiPhishParams
        logMe -level "Info" -message "Anti Phishing Policy '$policyName' created successfully. Creating rule." 
        New-AntiPhishRule -Name "$policyName - Selected Domains" -MalwareFilterPolicy $policyName -RecipientDomainIs $domains
        logMe -level "Info" -message "Anti Phishing Rule policy paired with domains."
        } catch {
            logMe -level "AntiPhishSetup" -message "Error in AntiPhish setup: $_"

        }
}

function InboundSpam {
    param([hashtable]$InboundSpamParams)
    
    if (-not $InboundSpamParams) {
        logMe -level "InboundSpamSetup" -message "InboundSpam received empty param"
    }
    $policyName = $InboundSpamParams['Name']
    try {
        New-HostedContentFilterPolicy @InboundSpamParams
        logMe -level "Info" -message "Inbound Spam policy '$policyName' created successfully. Creating rule."
        New-HostedContentFilterRule -Name "$policyName - Selected domains" -HostedContentFilterPolicy $policyName -RecipientDomainIs $domain
        logMe -level "Info" -message "Inbound spam policy paired with domains."
        } catch {
            logMe -level "InboundSpamSetup" -message "Error in InboundSpam setup: $_"
        }
}

function OutboundSpam {
    param([hashtable]$OutboundSpamParams)
    
    if (-not $OutboundSpamParams) {
        logMe -level "OutboundSpamSetup" -message "OutboundSpam received empty param"
    }
    $policyName = $OutboundSpamParams['Name']
    try {
        New-HostedOutboundSpamFilterPolicy @OutboundSpamParams
        logMe -level "Info" -message "Outbound Spam policy '$policyName' created successfully. Creating rule."
        New-HostedOutboundSpamFilterRule -Name "$policyName - Selected domains" -HostedContentFilterPolicy $policyName -RecipientDomainIs $domain
        logMe -level "Info" -message "Inbound spam policy paired with domains."
        } catch {
            logMe -level "OutboundSpamSetup" -message "Error in OutboundSpam setup: $_"
        }
}





Export-ModuleMember -Function Quarantine, Alert, SafeLinks, MailTips, MalwareFilter, SafeAttach, AntiPhish, InboundSpam, OutboundSpam



