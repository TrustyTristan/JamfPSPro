function Invoke-JamfAPICall {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$BaseURL,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Body,

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
            Write-Information "Uri: $Path"
            if ( $Body ) {
                $Response = Invoke-RestMethod $Path -Authentication Bearer -Token $TokenJamfPSPro.token -ContentType $app_Type -Headers $app_Headers -Method $Method -Body $Body -ErrorAction Stop
            } else {
                $Response = Invoke-RestMethod $Path -Authentication Bearer -Token $TokenJamfPSPro.token -ContentType $app_Type -Headers $app_Headers -Method $Method -ErrorAction Stop
            }

            # Expand result if only 1 property at top
            if ( ($Response.PSObject.Properties | Measure-Object).Count -eq 1 ) {
                return ($Response | Where-Object {$_.getType().Name -eq 'PSCustomObject'}).PSObject.Properties.Value 
            } else {
                return $Response
            }
        } catch {
            return "Invalid response from `'$Path`'`n$($_.Exception.Message)"
        }
    }
}