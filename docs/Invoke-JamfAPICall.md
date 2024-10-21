---
external help file: JamfPSPro-help.xml
Module Name: JamfPSPro
online version:
schema: 2.0.0
---

# Invoke-JamfAPICall

## SYNOPSIS
Invokes a Jamf api call.

## SYNTAX

```
Invoke-JamfAPICall [-Path] <String> [-BaseURL] <String> [[-Body] <Object>] [-Method] <String>
 [[-AppType] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Invoke-JamfAPICall cmdlet allows you to make a Jamf api call
without needing to build out headers.
This is mostly used for debugging.

Note: Ensure that you have proper permissions and access to Jamf Pro.

## EXAMPLES

### EXAMPLE 1
```
Invoke-JamfAPICall -Path 'https://trusty.jamfcloud.com/api/v1/computers' -BaseURL 'https://trusty.jamfcloud.com/api/v1/' -Method get
```

## PARAMETERS

### -Path
Specifies the full uri of the api call

eg: https://trusty.jamfcloud.com/api/v1/computers
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

### -BaseURL
Specifies the base uri of the api call, this is the server and api version

eg: https://trusty.jamfcloud.com/api/v1/
This parameter is mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body
Specifies the body of the call.
Not required.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
Specifies the method of the api call to lookup.
Eg delete, get, post and put.
This parameter is mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AppType
Specifies the AppType 'application/json' or 'application/xml'
Defaults to 'application/json'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Application/json
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
