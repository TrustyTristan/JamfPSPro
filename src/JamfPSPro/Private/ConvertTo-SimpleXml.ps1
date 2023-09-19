function ConvertTo-SimpleXml {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object]$InputObject
    )

    if ($InputObject -is [System.Collections.Hashtable]) {
        $xml = @()
        foreach ($key in $InputObject.Keys) {
            $value = $InputObject[$key]
            $xml += "<$key>" + (ConvertTo-SimpleXml -InputObject $value) + "</$key>"
        }
        return $xml -join ''
    } elseif ($InputObject -is [PSCustomObject]) {
        $xml = '<' + $InputObject.PSObject.Properties.Name + '>' + (ConvertTo-SimpleXml -InputObject $InputObject.PSObject.Properties.Value) + '</' + $InputObject.PSObject.Properties.Name + '>'
        return $xml
    } else {
        return $InputObject.ToString()
    }
}