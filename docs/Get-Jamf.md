---
external help file: JamfPSPro-help.xml
Module Name: JamfPSPro
online version:
schema: 2.0.0
---

# Get-Jamf

## SYNOPSIS
Retrieve data from Jamf Pro.

## SYNTAX

```
Get-Jamf [-Component] <String> [[-Params] <String[]>] [-WhatIf] [-Confirm] -Select <String>
 [<CommonParameters>]
```

## DESCRIPTION
The Get-Jamf cmdlet allows you to retrieve data from Jamf Pro, a comprehensive
management solution for macOS and iOS devices.
This cmdlet provides various
options for fetching specific information from Jamf Pro based on your requirements.
You can specify the component, select fields, and provide additional parameters to
customize your data retrieval.

Note: Ensure that you have proper permissions and access to Jamf Pro.

## EXAMPLES

### EXAMPLE 1
```
Get-Jamf -Component computers -Select all
Retrieves all available information for computers in Jamf Pro.
```

### EXAMPLE 2
```
Get-Jamf -Component computers -Select NAME -Param 'MacBookPro69'
Retrieves the computer object details for the computer names 'MacBookPro69'
```

### EXAMPLE 3
```
Get-Jamf -Component local-admin-password -Select 'CLIENTMANAGEMENTID/account/USERNAME/audit' -Param 69, 'myUser'
```

## PARAMETERS

### -Component
Specifies the component or resource name in Jamf Pro from which to retrieve data.
This parameter is mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Params
Specifies additional parameters required for filtering or customizing the data
retrieval.
Parameters are indicated by UPPERCASE from -Select

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Select
Specify the selection method of the 'component path'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
