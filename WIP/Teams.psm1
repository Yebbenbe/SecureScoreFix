# Teams.ps1

Connect-MicrosoftTeams -userprimaryname $upn
Set-CsTeamsEventsPolicy -Identity <policy name> -AutoAdmittedUsers InvitedUsers 