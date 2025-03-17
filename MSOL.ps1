# MSOL


Connect-MSOLService

$newPolicyName = 'Role Assignment Policy - Prevent Add-ins'
$revisedRoles = 'MyTeamMailboxes', 'MyTextMessaging', 'MyDistributionGroups', 'MyMailSubscriptions', 'MyBaseOptions', 'MyVoiceMail', 'MyProfileInformation', 'MyContactInformation', 'MyRetentionPolicies', 'MyDistributionGroupMembership'

New-RoleAssignmentPolicy -Name $newPolicyName -Roles $revisedRoles
Set-RoleAssignmentPolicy -id $newPolicyName -IsDefault
Get-Mailbox -ResultSize Unlimited | Set-Mailbox -RoleAssignmentPolicy $newPolicyName