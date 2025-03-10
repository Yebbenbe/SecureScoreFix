<#   QuarantineSetup.psm1 #####################################
Module used by Main
Configures a quarantine policy to send user quarantine notifs.
Grants perms to view preview, delete, or request release.
Configures release requests to go to desired email. 

###############################################################>

function Quarantine {
    param(
        [hashtable][ValidateNotNull()]$QuarantineParams,
        )

        if (-not $QuarantineParams) {
        logMe -level "Quarantinesetup" -message "QuarantineSetup did not receive any QuarantineParams"
        return # exits the function
        }

    try {
        New-QuarantinePolicy @QuarantineParams
        $qPolicy = Get-QuarantinePolicy -Identity "$($QuarantineParams['Name'])"
       
        logMe -level "Info" -message "Quarantine Policy '$qPolicy' created successfully."
        return $qPolicy 
    } catch {
        logMe -level "QuarantineSetup" -message "Error creating Quarantine Policy: $_"
    }   
}

function Alert {
    param [hashtable][ValidateNotNull()]$AlertParams
    }
        # Create the Protection Alert
        if (-not $alertParams) {
            logMe -level "Quarantinesetup" -message "QuarantineSetup did not receive any AlertParams"
            return  # exit the function if no AlertParams were passed
        }
    try {
        New-ProtectionAlert @AlertParams
        logMe -level "Info" -message "Protection alert created successfully, sends release alerts to $($AlertParams['NotifyUser'])"
    } catch {
        logMe -level "QuarantineSetup" -message "Error creating Protection Alert: $_"
    }
return $qPolicy
    

}


