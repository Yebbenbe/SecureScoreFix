# working

# enable mailbox auditing
Set-OrganizationConfig -AuditDisabled $false # set at org level
Get-Mailbox -RecipientTypeDetails RoomMailbox, EquipmentMailbox | Where-Object { $_.AuditEnabled -eq $false } # get any mailboxes with it off
# set all the mailboxes to enabled.. Resources mailboxes
Get-Mailbox -RecipientTypeDetails RoomMailbox, EquipmentMailbox | Where-Object { $_.AuditEnabled -eq $false } | Set-Mailbox -AuditEnabled $true
# public folder mailboxes
Get-Mailbox -PublicFolder | Where-Object { $_.AuditEnabled -eq $false } | Set-Mailbox -AuditEnabled $true
# Discovery Search mailboxes
Get-Mailbox -RecipientTypeDetails DiscoveryMailbox | Where-Object { $_.AuditEnabled -eq $false } | Set-Mailbox -AuditEnabled $true

