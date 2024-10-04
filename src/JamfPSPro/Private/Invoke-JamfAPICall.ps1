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
                $pageCount = ($Response.results.count)
                if ( $Response.totalCount -gt $pageCount ) {
                    $ResponseList = New-Object System.Collections.Generic.List[System.Object]
                    $Pages = [math]::ceiling( $Response.totalCount / $pageCount ) - 1
                    $Response | Add-Member -NotePropertyName 'pageCount' -NotePropertyValue $pageCount
                    $ResponseList.Add( $Response )
                    foreach ( $Page in $Pages ) {
                        $Response = Invoke-RestMethod "$Path/?page=$Page" -Authentication Bearer -Token $TokenJamfPSPro.token -ContentType $app_Type -Headers $app_Headers -Method $Method -ErrorAction Stop
                        $Response | Add-Member -NotePropertyName 'pageCount' -NotePropertyValue ($Response.results.count)
                        $ResponseList.Add( $Response )
                    }
                }
            }

            if ( $ResponseList ) {
                $ResponseList = $ResponseList | Select-Object * -ExcludeProperty totalCount, pageCount
                $ResponseName = $ResponseList | Get-Member -MemberType NoteProperty
                if ( $ResponseName.Count -eq 1) {
                    $ResponseList.($ResponseName.Name) | Add-Member -NotePropertyName 'IsSuccessStatusCode' -NotePropertyValue $true
                    return $ResponseList.($ResponseName.Name)
                } else {
                    $ResponseList | Add-Member -NotePropertyName 'IsSuccessStatusCode' -NotePropertyValue $true
                    return $ResponseList
                }
            } else {
                # totalCount is unnecessary
                $Response.PSObject.Properties.Remove('totalCount')
                # Expand result if only 1 property at top level
                if ( ($Response.PSObject.Properties | Measure-Object).Count -eq 1 ) {
                    $Response = ($Response | Where-Object {$_.getType().Name -eq 'PSCustomObject'}).PSObject.Properties.Value
                    # If response is empty, but still valid
                    if ( -not $Response ) {
                        $Response = [PSCustomObject]@{}
                    }
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
            }
        } catch {
            $ErrorMessage = $_
            Add-Member -InputObject $ErrorMessage -NotePropertyName 'IsSuccessStatusCode' -NotePropertyValue $false
            return $ErrorMessage
        }
    }
}