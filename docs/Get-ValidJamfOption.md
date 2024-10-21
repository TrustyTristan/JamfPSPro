---
external help file: JamfPSPro-help.xml
Module Name: JamfPSPro
online version:
schema: 2.0.0
---

# Get-ValidJamfOption

## SYNOPSIS
Retrieve a valid Jamf api call.

## SYNTAX

```
Get-ValidJamfOption [-Method] <String> [[-Component] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-ValidJamfOption cmdlet allows you to look up both the schema and swagger
from Jamf Pro and return the possible api calls.
These are filtered to the core methods of delete, get, post and put.

Note: Ensure that you have proper permissions and access to Jamf Pro.

## EXAMPLES

### EXAMPLE 1
```
Get-ValidJamfOption -Method get
Retrieves all available api calls that match the get method.
```

### EXAMPLE 2
```
Get-ValidJamfOption -Method get -Component computers
Retrieves all the available api calls that match the get method and computers path.
```

## PARAMETERS

### -Method
Specifies the method of the api call to lookup.
Eg delete, get, post and put.
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

### -Component
Specifies the component or resource name in Jamf Pro from which to retrieve data.
This parameter is not mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
