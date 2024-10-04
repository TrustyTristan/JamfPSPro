<#
    .SYNOPSIS
        Connects to JamfPro
    .DESCRIPTION
        Connects to JamfPro with bearer token
    .PARAMETER Server
        Specify the JamfPro 'server'
    .PARAMETER Credential
        Specify the credentails
    .PARAMETER NoWelcome
        Prevents the connection information being displayed
    .PARAMETER Force
        Force reconnection to API ignoring 'valid' token
    .EXAMPLE
        Connect-JamfPro -Server trusty.jamfcloud.com -Credential $Creds
    .EXAMPLE
        Connect-JamfPro -Server trusty.jamfcloud.com -Credential $Creds -Force
#>
function Connect-JamfPro {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Url of the Jamf Pro server')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Server,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Valid credentials for the Jamf Pro API')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $false)]
        [switch]$Force,

        [Parameter(Mandatory = $false)]
        [switch]$NoWelcome
    )

    BEGIN {
        $Server = ConvertTo-FQDN $Server
        $uri_Auth      = "https://$Server/api/v1/auth/token"
        $uri_Verify    = "https://$Server/api/v1/auth"
        $uri_Build     = "https://$Server/api/v1/jamf-pro-version"
        $uri_KeepAlive = "https://$Server/api/v1/auth/keep-alive"
        $app_Type   = "application/json"
        $app_Headers = @{
            Server  = "$Server"
            BaseURL = "$Server/JSSResource"
            Accept  = $app_Type
        }
        Add-Type -TypeDefinition @"
            using System;
            using System.Security;
            
            public class ConvertToSS {
                public static SecureString Set(string token) {
                    SecureString ss = new SecureString();
                    foreach (var c in token) {
                        ss.AppendChar(c);
                    }
                    return ss;
                }
            }
            
"@
    }

    PROCESS {
        # Check for existing session
        if ( $force -or (-not $TokenJamfPSPro.expires) -or (-not $TokenJamfPSPro.token) ) {

            Write-Debug "Try to get new token"

            if ( $TokenJamfPSPro.Credential ) {
                Write-Debug "Using saved credential: $($TokenJamfPSPro.Credential.UserName)"
                $Credential = $TokenJamfPSPro.Credential
            }
            while ( $Credential -eq [System.Management.Automation.PSCredential]::Empty ) {
                $Credential = Get-Credential
            }

            try {
                $TokenResult = Invoke-RestMethod $uri_Auth -Credential $Credential -Authentication Basic -Method POST -ContentType $app_Type
            } catch {
                Write-Error "Could not get token from `'$Server`'"
                break
            }

            $Token = [PSCustomObject]@{
                token      = [ConvertToSS]::Set($TokenResult.Token)
                expires    = (Get-Date $TokenResult.expires).AddMinutes((Get-TimeZone).BaseUtcOffset.TotalMinutes)
                server     = $Server
                credential = $Credential
            }

            try {
                $VerifyAuth = Invoke-RestMethod $uri_Verify -Authentication Bearer -Token $Token.token -ContentType $app_Type -Headers $app_Headers
                Set-Variable -Name 'TokenJamfPSPro' -Value $Token -Scope Global -Option ReadOnly -Description "Token for Jamf Pro API" -Force
                $JamfBuild = (Invoke-RestMethod $uri_Build -Authentication Bearer -Token $TokenJamfPSPro.token -ContentType $app_Type -Headers $app_Headers -Method GET).version
            } catch {
                $Error[0]
                Write-Error "$($_.Exception.Response.StatusCode.value__): $($_.Exception.Response.StatusCode)"
                Write-Error "Error authenticating to `'$Server`' with token"
                break
            }

            if ( -not $NoWelcome ) {
                $ConnectionDetails = [PSCustomObject][Ordered]@{
                    Account = $VerifyAuth.account.username
                    Access  = $VerifyAuth.account.accessLevel
                    Server  = $Server
                    Build   = $JamfBuild
                    Expires = $TokenJamfPSPro.expires
                }
                $ConnectionDetails | Format-Table
            }

        } elseif ( $TokenJamfPSPro.token -and ( (Get-Date $TokenJamfPSPro.expires) -le ((Get-Date).AddMinutes(20)) ) ) {
            Write-Debug "Found token with healthy expiry. Expires: $($TokenJamfPSPro.expires)"
            try {
                Write-Debug "Attempting to refresh token"
                $KeepAlive = Invoke-RestMethod $uri_KeepAlive -Authentication Bearer -Token $TokenJamfPSPro.token -ContentType $app_Type -Headers $app_Headers -Method POST
                $TokenJamfPSPro.psobject.Properties.Remove('token')
                $TokenJamfPSPro.psobject.Properties.Add([PSNoteProperty]::new('token', [ConvertToSS]::Set($KeepAlive.Token)))
                $TokenJamfPSPro.expires = (Get-Date $KeepAlive.expires).AddMinutes((Get-TimeZone).BaseUtcOffset.TotalMinutes)
                Write-Debug "New token expires: $($TokenJamfPSPro.expires)"
            } catch {
                Write-Debug "Error refreshing token"
                if ( $TokenJamfPSPro.Server -and $TokenJamfPSPro.Credential ) {
                    $TokenJamfPSPro.psobject.Properties.Remove('expires')
                    $TokenJamfPSPro.psobject.Properties.Remove('token')
                    Write-Debug "Cleared expiry and token"
                    Connect-JamfPro -Server $TokenJamfPSPro.Server -Credential $TokenJamfPSPro.credential
                } else {
                    Write-Debug "No stored credentials"
                    Clear-Variable -Name TokenJamfPSPro -Force
                    Connect-JamfPro
                }
            }
        }
    }

}