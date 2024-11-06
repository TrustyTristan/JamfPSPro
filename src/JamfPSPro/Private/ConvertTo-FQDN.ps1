function ConvertTo-FQDN {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Enter url')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$String
    )
    PROCESS {
        foreach ($url in $String) {
            if ($url -match "(?:https?://)?(?:www\d?\.)?(?<domain>[-\w.]+)(?<port>:[0-9]+)?") {
                if ($matches["port"]) {
                    return $matches["domain"] + $matches["port"]
                } else {
                    return $matches["domain"]
                }
            }
        }
    }
}