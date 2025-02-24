# SecureScoreFix
Scripts for quickly addressing SecureScore

## SecureScoreFix.ps1
- creates a new, compliant policy for SafeLinks, SafeAttachments, MalwareFilter, more to be added
- enables MailTooltip
- disables additional storage providers on OWA
- any existing policies will remain, but will lose their assignments
- For non-federated environments using separate admin accounts for each tenant
- requires a Defender P1 and Entra P1 license (these can simply be on admin account)
- Maintenance items: Recommmendation date(7)

# RemediateSafeLinks.ps1
- a more robust remediation than above, which checks for an existing rule (policy + assignment combo)
- if rule exists, verifies config and assignment, fixes if needed
- if no rule, creates one with same process as above
