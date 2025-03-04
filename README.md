MAIN: SecureScoreLowImpact.ps1
AUTHOR: Yebbenbe
LAST VERIFIED: "March 4 2025"
REQUIRED MODS: fileLog.psm1, DomainSelector.psm1

# SecureScoreFix
Scripts for quickly addressing SecureScore. [WIP]

- Use with Defender P1 atleast.
- If you see [main] in this document, replace it with whatever is listed as MAIN above. This includes any code.
- Intended to be used by normal humans who don't understand this stuff, but know their score is too low. This is ALSO a [WIP]
- If you want to use this, but can't because it's not finished- click the "Issues" tab and input an issue, and we can talk.
- This may break any special configuration you have for certain emails. Working on enabling exclusions.
- Currently, enables MailTips, Disables OWA External Providers, Configures SafeLinks, SafeAttachments, AntiMalware, AntiPhish, AntiSpam policies as per suggestions. Configures Quarantine to notify users every day, allow release request. 
- **Release Request notifications cannot be automated by this. That must be conf'd manually, under Defender > Email & Collaboration > Rules & Policies > Alert Policies: User has requested to release a Quarantined Item.** This is because the Set-ProtectionAlert cmdlet cannot edit defaults, and the New-ProtectionAlert cmdlet won't work without Enterprise.
- Does not touch user accounts. All current configurations will be seen within Defender > Email & Collaboration > Rules& Policie

### Tentative Instructions
- This is a WIP, and will not work as desired.
- Download [main]
- download [mods]
- Ensure these are in the same folder on your machine. If on Windows, it is likely C:\Users\*you*\Downloads
- Open Powershell in that directory
- - open cmd, input `cd %USERPROFILE%\Downloads`
  - input `pwsh ./[main]`
  - Follow the prompts.
 - Log will be found in the same folder named "yourTenant-log.txt"
 ###### considerations
 - This will force Microsoft recommended values to various email-related policies.
 - This includes blocking any automatic forwarding to external email addresses, which can have an impact on anything you have configured to automatically forward (like ticketing)
 - This will also start quarantining messages. Some WILL be false flags, as it uses Microsoft AI components... Some detections are configured to go to Quarantine, some are configured to go to your Junk folder.
 - It will create shortcuts on your desktop to Defender Quarantine, Impersonation Insight, Spoofing Insight and Spam Insight pages. The Quarantine is where messages can be released. The Insight Pages gives you info on how much is getting flagged by various tools. You can use this to tweak policies - but this may cost you points.

## SecureScoreLowImpact.ps1 (referred to as MAIN)
[WIP]
- began as a Fix to limit the amount of quarantining
- has evolved past that, to set a quarantine policy allowing users to request item releases.
- checks for existing rules (policy + domain combinations) and updates whatever exists with proper rules. Assigns remaining input domains to it.
- If no no  existing rules, creates a new one.
Status: SafeLinks, SafeAttachments, MalwareFilter, Spam Filter (HostedContentFilter)  inbound and outbound created.
- [ ] Need to update all of these with domain assignment for existing rules
- [ ] Need to include params from original SecureScoreFix.ps1
- [ ] Add intro query allowing users to exclude certain emails from assignment, unclear how to do this as of yet. Probably similar to a ticketing forward.
- [ ] Modularize the different elements, this is nauseating.

### DomainSelector.psm1 
[comp]
- script for domain selection for [main]
- Outputs all Accepted Domains, prompts user to input domains to work with.
- Input one at a time. Input "all" to affect all, "next" to move forward.
- **Recommended: When you are prompted, input any domains with users attached.**
- Must be downloaded with [main], kept in same folder
- does not need to be run manually

### fileLog.psm1
[comp]
- simple logger for [main]
- Must be downloaded with [main], kept in same folder
- does not need to be ru manually
- Logs can be found in the same folder, as "YourTenant - log.txt"
 
## SecureScoreFix.ps1 (deprecated)
- creates a new, compliant policy for SafeLinks, SafeAttachments, MalwareFilter, more to be added
- enables MailTooltip
- disables additional storage providers on OWA
- any existing policies will remain, but will lose their assignments
- For non-federated environments using separate admin accounts for each tenant
- requires a Defender P1 and Entra P1 license (these can simply be on admin account)
- Maintenance items: Recommmendation date(7)

# RemediateSafeLinks.ps1 (deprecated)
- experimental
- a more robust remediation than above, which checks for an existing rule (policy + assignment combo)
- if rule exists, verifies config and assignment, fixes if needed
- if no rule, creates one with same process as above

# devcontainer
ignore this, this was used so I could write this within GitHub Codespaces. Isn't needed.
