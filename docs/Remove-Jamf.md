---
external help file: JamfPSPro-help.xml
Module Name: JamfPSPro
online version:
schema: 2.0.0
---

# Remove-Jamf

## SYNOPSIS
Removes data from Jamf Pro

## SYNTAX

```
Remove-Jamf [-Component] <String> [[-Params] <String[]>] [-WhatIf] [-Confirm] -Path <String>
 [<CommonParameters>]
```

## DESCRIPTION
Removes data from Jamf Pro

## EXAMPLES

### EXAMPLE 1
```
Remove-Jamf -Component computers -Path 'computers-inventory/{id}' -Params 69
```

## PARAMETERS

### -Component
Specify the 'component' name

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
Specify params outlined by '{}' in component path

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

### -Path
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
