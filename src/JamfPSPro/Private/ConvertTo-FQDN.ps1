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
            if ($url -match "(?:https?://)?(?:www\d?\.)?(?<domain>[-\w.]+)") {
                return $matches["domain"]
            }
        }
    }
}