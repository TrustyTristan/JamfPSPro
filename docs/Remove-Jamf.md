---
external help file: JamfPSPro-help.xml
Module Name: JamfPSPro
online version:
schema: 2.0.0
---

# Remove-Jamf

## SYNOPSIS
Remove an existing resource or record from Jamf Pro.

## SYNTAX

```
Remove-Jamf [-Component] <String> [[-Params] <String[]>] [-WhatIf] [-Confirm] -Select <String>
 [<CommonParameters>]
```

## DESCRIPTION
The Remove-Jamf cmdlet allows you to delete or remove an existing resource
or record from a Jamf Pro system, which is a comprehensive management solution
for macOS and iOS devices.
You can use this cmdlet to delete assets, configurations,
or other entities from your Jamf Pro environment.
Ensure that you have the necessary
permissions and access for this operation.

## EXAMPLES

### EXAMPLE 1
```
Remove-Jamf -Component computers -Select ID -Params 69
Removes the computer with the ID 69
```

## PARAMETERS

### -Component
Specifies the component or resource name in Jamf Pro from which to remove data.
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
Specifies additional parameters required for filtering or selecting the data to remove.
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
