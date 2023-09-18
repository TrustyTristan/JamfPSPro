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
        $startMarker = $ErrorDetails.Exception.Response.StatusCode.ToString() -replace '^.*(?=.{3}$)' 
        $endMarker = "You can get technical details here"
        # Find the start and end positions of the markers
        $startPos = $ErrorDetails.ErrorDetails.Message.IndexOf($startMarker)
        $endPos = $ErrorDetails.ErrorDetails.Message.IndexOf($endMarker, $startPos)
        if ($startPos -ge 0 -and $endPos -ge 0) {
            $message = $ErrorDetails.ErrorDetails.Message.Substring($startPos + $startMarker.Length, $endPos - $startPos - $startMarker.Length).Trim()
        }

        $ErrorMessage = [PSCustomObject]@{
            requestUri  = $ErrorDetails.Exception.Response.RequestMessage.RequestUri.AbsoluteUri
            httpStatus  = $ErrorDetails.Exception.Response.StatusCode.Value__
            description = $ErrorDetails.Exception.Response.StatusCode
            message     = $message
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