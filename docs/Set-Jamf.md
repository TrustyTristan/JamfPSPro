---
external help file: JamfPSPro-help.xml
Module Name: JamfPSPro
online version:
schema: 2.0.0
---

# Set-Jamf

## SYNOPSIS
Update or modify an existing resource or record in Jamf Pro.

## SYNTAX

```
Set-Jamf [-Component] <String> [[-Params] <String[]>] [[-Content] <Object>] [-WhatIf] [-Confirm]
 -Select <String> [<CommonParameters>]
```

## DESCRIPTION
The Set-Jamf cmdlet enables you to update or modify an existing resource or
record in a Jamf Pro system.
Jamf Pro is a comprehensive management solution
for macOS and iOS devices.
You can use this cmdlet to make changes to assets,
configurations, or other entities in your Jamf Pro environment.
Ensure that you
have the necessary permissions and access for this operation.

## EXAMPLES

### EXAMPLE 1
```
<name>Blazing Script</name></script>"
Set-Jamf -Component scripts -Select ID -Param 420 -Content $UpdatedScript
Changes the name of the script with the ID 420
```

### EXAMPLE 2
```
$Update = [PSCustomObject]@{
    'computer_group' = @{
        'name' = 'The Plastics';
        }
    }
Set-Jamf -Component computergroups -Select ID -Param 69 -Content $Update
Changes the name of the computer group with the ID of 69
```

## PARAMETERS

### -Component
Specifies the component or resource name in Jamf Pro from which to update data.
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
