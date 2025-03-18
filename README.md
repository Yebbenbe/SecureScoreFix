# SecureScoreFix
A tool for quickly addressing low Secure Score. Designed with non-techs in mind.

- requires Defender P1
- you will be asked for the following info:
  - Company name: used for naming policies
  - Email: this is where Quarantine Release Requests and Internal Spam Sender notifications will go to
  - Username: Your 365 username. If this is what you login to your PC with, you will not need to input a password. Otherwise, you will.
  - Domains: the domains you want to apply these rules to. Input **all** to apply to all domains on the tenant. This is recommended.
   
### Tentative Instructions
1. Download Main.ps1, DomainSelection.psm1, fileLog.psm1, Variables.ps1, ThreatPolicies.psm1 to your Downloads folder.
2. If you have the ExchangeOnlineManagement module for PowerShell, skip to 4. Otherwise, open PowerShell (the command line, not the ISE) as an admin. (Right-click + run as administrator)
3. Run `Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Confirm:$false`
4. open cmd, input `cd %USERPROFILE%\Downloads`
5. input `pwsh ./Main.ps1`
6. Follow the prompts. Log will be found on your desktop as 'SecureScore_log.txt'
7. If you get an error about enabling customization, input `Enable-OrganizationCustomization` and try again.

 ### Considerations
 - This will force Microsoft recommended values to various email-related policies.
 - This includes blocking any automatic forwarding to external email addresses, which can have an impact on anything you have configured to automatically forward (like ticketing)
 - This will also start quarantining messages. Some WILL be false flags, as it uses Microsoft AI components... Some detections are configured to go to Quarantine, some are configured to go to your Junk folder.
 - It is recommmended to familiarize yourself with the Quarantine and releasing items.

### Development
- Deprecated are old iterations of this script.
- WIP are various other SecureScore components. These are split into the service/module they use.
