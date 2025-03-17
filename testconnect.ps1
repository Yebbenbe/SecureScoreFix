# testconnect.ps1
# This simply connects to two different ExchangeOnlineManagement components
# illustrates how to avoid multiple login prompts
# Will prompt once to auth the session, but then connect-ippssession will use the existing one. 
$upn = Read-Host -Prompt "input your username"
Connect-ExchangeOnline -userprincipalname $upn
Connect-IPPSSession -userprincipalname $upn
Connect-SPOService
