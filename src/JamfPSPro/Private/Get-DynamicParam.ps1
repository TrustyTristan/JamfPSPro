function Get-DynamicParam {
    <# 
    .NOTES
        Credit to:
        http://jrich523.wordpress.com/2013/05/30/powershell-simple-way-to-add-dynamic-parameters-to-advanced-function/
        https://github.com/RamblingCookieMonster/PowerShell/blob/master/New-DynamicParam.ps1
    .PARAMETER Name
        Name of the dynamic parameter
    .PARAMETER Type
        Type for the dynamic parameter.  Default is string
    .PARAMETER Alias
        If specified, one or more aliases to assign to the dynamic parameter
    .PARAMETER ValidateSet
        If specified, set the ValidateSet attribute of this dynamic parameter
    .PARAMETER Mandatory
        If specified, set the Mandatory attribute for this dynamic parameter
    .PARAMETER ParameterSetName
        If specified, set the ParameterSet attribute for this dynamic parameter
    .PARAMETER Position
        If specified, set the Position attribute for this dynamic parameter
    .PARAMETER ValueFromPipelineByPropertyName
        If specified, set the ValueFromPipelineByPropertyName attribute for this dynamic parameter
    .PARAMETER HelpMessage
        If specified, set the HelpMessage for this dynamic parameter
    .PARAMETER DPDictionary
        If specified, add resulting RuntimeDefinedParameter to an existing RuntimeDefinedParameterDictionary (appropriate for multiple dynamic parameters)
        If not specified, create and return a RuntimeDefinedParameterDictionary (appropriate for a single dynamic parameter)
    #>

    param (
        [string]
        $Name,

        [System.Type]
        $Type = [string],

        [string[]]
        $Alias = @(),

        [string[]]
        $ValidateSet,

        [switch]
        $Mandatory,

        [string]
        $ParameterSetName = "__AllParameterSets",

        [int]
        $Position,

        [switch]
        $ValueFromPipelineByPropertyName,

        [string]
        $HelpMessage,

        [validatescript({
                if (-not ( $_ -is [System.Management.Automation.RuntimeDefinedParameterDictionary] -or -not $_)) {
                    throw "DPDictionary must be a System.Management.Automation.RuntimeDefinedParameterDictionary object, or not exist"
                }
                $True
            })]
        $DPDictionary = $false
    )

    # Create attribute object, add attributes, add to collection   
    $ParamAttr = New-Object System.Management.Automation.ParameterAttribute
    $ParamAttr.ParameterSetName = $ParameterSetName
    if ($mandatory) {
        $ParamAttr.Mandatory = $True
    }
    if ($Position -ne $null) {
        $ParamAttr.Position = $Position
    }
    if ($ValueFromPipelineByPropertyName) {
        $ParamAttr.ValueFromPipelineByPropertyName = $True
    }
    if ($HelpMessage) {
        $ParamAttr.HelpMessage = $HelpMessage
    }

    $AttributeCollection = New-Object 'Collections.ObjectModel.Collection[System.Attribute]'
    $AttributeCollection.Add($ParamAttr)

    # param validation set if specified
    if ($ValidateSet) {
        $ParamOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList $ValidateSet
        $AttributeCollection.Add($ParamOptions)
    }

    # Aliases if specified
    if ($Alias.count -gt 0) {
        $ParamAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList $Alias
        $AttributeCollection.Add($ParamAlias)
    }

    # Create the dynamic parameter
    $Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList @($Name, $Type, $AttributeCollection)

    # Add the dynamic parameter to an existing dynamic parameter dictionary, or create the dictionary and add it
    if ($DPDictionary) {
        $DPDictionary.Add($Name, $Parameter)
    } else {
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $Dictionary.Add($Name, $Parameter)
        $Dictionary
    }

}