#scrap

<# set MailTips 
try {
    # Attempt to run the Set-OrganizationConfig command
    Set-OrganizationConfig @paramsMailTips 
    logMe -level "Info" -write $true -message 'Mailtips enabled'
} catch { 
    logMe -level "ErrorMain" -message "Error enabling MailTips: $_"
    $failedProcesses += "MailTips"
    }
#>


# following param is only available on Global policy. Can be done by PS, but low priority.
#$qSender = Read-Host -Prompt "Specify an email to send quarantine notices to users FROM. This must be an existing internal sender. If input is blank, will default to 'quarantine@messaging.microsoft.com.'"