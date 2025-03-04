# SecureScoreFix
Scripts for quickly addressing SecureScore. A WIP
Use with Defender P1 atleast.
Intended to be used by normal humans. This is ALSO a WIP. 
This may break any special configuration you have for certain emails. Working on enabling exclusions.
Currently, enables MailTips, Disables OWA External Providers, Configures SafeLinks, SafeAttachments, AntiMalware, AntiPhish, AntiSpam policies as per suggestions. Configures Quarantine to notify users every day, allow release request. 
**Release Request notifications cannot be automated by this. That must be conf'd manually, under Defender > Email & Collaboration > Rules & Policies > Alert Policies: User has requested to release a Quarantined Item.** This is because the Set-ProtectionAlert cmdlet cannot edit defaults, and the New-ProtectionAlert cmdlet won't work without Enterprise.
Does not touch user accounts. All current configurations will be seen within Defender > Email & Collaboration > Rules& Policies

## SecureScoreLowImpact.ps1 (referred to as MAIN)
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
- script for domain selection
- Outputs all Accepted Domains, prompts user to input domains to work with.
- Input one at a time. Input "all" to affect all, "next" to move forward.
- **Recommended: When you are prompted, input any domains with users attached.**
- Must be downloaded with Main, kept in same folder
- does not need to be run manually

### fileLog.psm1
- simple logger for Main
- Must be downloaded with Main, kept in same folder
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
