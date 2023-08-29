---
external help file: JamfPSPro-help.xml
Module Name: JamfPSPro
online version:
schema: 2.0.0
---

# Connect-JamfPro

## SYNOPSIS
Connects to JamfPro

## SYNTAX

```
Connect-JamfPro [-Server] <String> [[-Credential] <PSCredential>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Connects to JamfPro with bearer token

## EXAMPLES

### EXAMPLE 1
```
Connect-JamfPro -Server trusty.jamfcloud.com -Credential $Creds
```

### EXAMPLE 2
```
Connect-JamfPro -Server trusty.jamfcloud.com -Credential $Creds -Force
```

## PARAMETERS

### -Server
Specify the JamfPro 'server'

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

### -Credential
Specify the credentails

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: [System.Management.Automation.PSCredential]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Force reconnection to API ignoring 'valid' token

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
