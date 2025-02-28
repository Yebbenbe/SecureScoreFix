function logMe {
    param(
        [Parameter(ValueFromPipeline=$true)] [string]$message,
        [string]$level = "Info")

    # Format the timestamp
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    #conversion
    if ($message -is [array]) {
        $formattedMessage = "Array converted to: " + ($message -join ', ')
    } elseif ($message -is [string]) {
        $formattedMessage = $message
    } elseif ($message -is [int]) {
        $formattedMessage = $message.ToString()
    } elseif ($message -is [boolean]) {
        $formattedMessage = $message.ToString()
    } elseif ($message -eq $null) {
        $formattedMessage = "null"
    } else {
        $formattedMessage = $message.ToString()
    }

    # log it
    $logMessage = "$timestamp [$level] - $formattedMessage"
    $logMessage | Out-File -FilePath $global:logFile -Append
}
