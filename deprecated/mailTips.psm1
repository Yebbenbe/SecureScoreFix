#otherConfig.psm1

function MailTips {
    param(
        [hashtable]$mailTipsParams
        ) 

 Set-OrganizationConfig @MailTipsParams
 Set-OwaMailboxPolicy -Identity OwaMailboxPolicy-Default -AdditionalStorageProvidersAvailable $false;
 }