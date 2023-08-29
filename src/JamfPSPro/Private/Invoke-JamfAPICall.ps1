function Invoke-JamfAPICall {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$BaseURL,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Method
    )

    BEGIN {
        $app_Type   = 'application/json'
        $app_Headers = @{
            Server  = $TokenJamfPSPro.Server
            BaseURL = $BaseURL
            Accept  = $app_Type
        }
    }

    PROCESS {
        try {
            $Response = Invoke-RestMethod $Path -Authentication Bearer -Token $TokenJamfPSPro.token -ContentType $app_Type -Headers $app_Headers -Method $Method
            return $Response.PSobject.Properties.Value
        } catch {
            Write-Error "Invalid response from `'$Path`'"
            Write-Error $_.Exception.Message
        }
    }
}