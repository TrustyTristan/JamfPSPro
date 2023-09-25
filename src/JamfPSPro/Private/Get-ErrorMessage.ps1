function Get-ErrorMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Error details')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $ErrorDetails
    )
    PROCESS {
        # Extract the message from $ErrorDetails.ErrorDetails.Message
        $StartMarker = $ErrorDetails.Exception.Response.StatusCode.ToString() -replace '^.*(?=.{3}$)' 
        $EndMarker = "You can get technical details here"
        # Find the start and end positions of the markers
        if ( $ErrorDetails.ErrorDetails.Message.Contains($EndMarker) ) {
            $StartPos = $ErrorDetails.ErrorDetails.Message.IndexOf($StartMarker)
            $EndPos = $ErrorDetails.ErrorDetails.Message.IndexOf($EndMarker, $StartPos)
            if ( $StartPos -ge 0 -and $EndPos -ge 0 ) {
                $Message = $ErrorDetails.ErrorDetails.Message.Substring($StartPos + $StartMarker.Length, $EndPos - $StartPos - $StartMarker.Length).Trim()
            }
        } else {
            $Message = "Unable to determine error message"
        }

        $ErrorMessage = [PSCustomObject]@{
            requestUri  = $ErrorDetails.Exception.Response.RequestMessage.RequestUri.AbsoluteUri
            httpStatus  = $ErrorDetails.Exception.Response.StatusCode.Value__
            description = $ErrorDetails.Exception.Response.StatusCode
            message     = $Message
        }

        try {
            $ErrorJson = ConvertFrom-Json $_.ErrorDetails.Message -ErrorAction Stop
            $ErrorMessage | Add-Member -NotePropertyName code -NotePropertyValue $ErrorJson.errors.code
        } catch {
            Write-Information "No error code to write"
        }

        if ( $ErrorMessage.code ) {
            return "$($ErrorMessage.httpStatus) $($ErrorMessage.description)`nUri: $($ErrorMessage.requestUri)`nDetails: $($ErrorMessage.code)`nMessage: $($ErrorMessage.message)"
        } else {
            return "$($ErrorMessage.httpStatus) $($ErrorMessage.description)`nUri: $($ErrorMessage.requestUri)`nMessage: $($ErrorMessage.message)"
        }
    }
}