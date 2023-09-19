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
        [string]$Method,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$AppType = 'application/json'
    )

    BEGIN {
        $app_Type = $AppType
        $app_Headers = @{
            Server  = $TokenJamfPSPro.Server
            BaseURL = $BaseURL
            Accept  = $app_Type
        }
    }

    PROCESS {
        try {

            Write-Debug "Uri: $Path"
            Write-Debug "AppType: $app_Type"

            if ( $Body ) {
                $Response = Invoke-RestMethod $Path -Authentication Bearer -Token $TokenJamfPSPro.token -ContentType $app_Type -Headers $app_Headers -Method $Method -Body $Body -ErrorAction Stop
            } else {
                $Response = Invoke-RestMethod $Path -Authentication Bearer -Token $TokenJamfPSPro.token -ContentType $app_Type -Headers $app_Headers -Method $Method -ErrorAction Stop
            }

            # totalCount is unnecessary
            $Response.PSObject.Properties.Remove('totalCount')

            # Expand result if only 1 property at top level
            if ( ($Response.PSObject.Properties | Measure-Object).Count -eq 1 ) {
                $Response = ($Response | Where-Object {$_.getType().Name -eq 'PSCustomObject'}).PSObject.Properties.Value 
            }

            # No response with delete, don't know of a way to validate success
            if ( $Method -eq 'delete' ) {
                $Response = [PSCustomObject]@{
                    IsSuccessStatusCode = $true
                }
            } else {
                $Response | Add-Member -NotePropertyName 'IsSuccessStatusCode' -NotePropertyValue $true
            }

            return $Response
        } catch {
            $ErrorMessage = $_
            Add-Member -InputObject $ErrorMessage -NotePropertyName IsSuccessStatusCode -NotePropertyValue $false
            return $ErrorMessage
        }
    }
}