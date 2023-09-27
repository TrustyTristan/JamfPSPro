---
external help file: JamfPSPro-help.xml
Module Name: JamfPSPro
online version:
schema: 2.0.0
---

# New-Jamf

## SYNOPSIS
Create a new resource or record in Jamf Pro.

## SYNTAX

```
New-Jamf [-Component] <String> [[-Params] <String[]>] [[-Content] <Object>] [-WhatIf] [-Confirm]
 -Select <String> [<CommonParameters>]
```

## DESCRIPTION
The New-Jamf cmdlet allows you to create a new resource or record in a Jamf Pro
system, which is a comprehensive management solution for macOS and iOS devices.
You can use this cmdlet to add new assets, configurations, or other entities to
your Jamf Pro environment.
Ensure that you have the necessary permissions and
access to perform this action.

## EXAMPLES

### EXAMPLE 1
```
New-Jamf -Component computers -Select 'ID/recalculate-smart-groups' -Param 420
Recalculates the smart group for the given computer id and then returns the count of
smart groups the computer falls into.
```

## PARAMETERS

### -Component
Specifies the component or resource name in Jamf Pro from which to create data.
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

### -Content
The content to send to jamf this can be in json, PSObject or jamf simple xml format.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
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
