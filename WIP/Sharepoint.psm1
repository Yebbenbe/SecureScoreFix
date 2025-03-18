# Sharepoint.ps1
# Connects to SPOService, runs requisite config items

$temp =  (Get-OrganizationConfig).SharePointSite

Set-SPOTenant -LegacyAuthProtocolsEnabled $false
Set-SPOBrowserIdleSignOut -Enabled $true -WarnAfter (New-TimeSpan -Seconds 2700) -SignOutAfter (New-TimeSpan -Seconds 3600)