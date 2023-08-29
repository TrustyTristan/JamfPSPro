<#
    .SYNOPSIS
        Connects to JamfPro
    .DESCRIPTION
        Connects to JamfPro with bearer token
    .PARAMETER Server
        Specify the JamfPro 'server'
    .PARAMETER Credential
        Specify the credentails
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
        [switch]$Force
    )

    BEGIN {
        $Server = ConvertTo-FQDN $Server
        $uri_Auth      = "https://$Server/api/v1/auth/token"
        $uri_Verify    = "https://$Server/api/v1/auth"
        $uri_Build     = "https://$Server/JSSCheckConnection"
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
        if ( $force -or (-not $TokenJamfPSPro.expires) -or ((Get-Date $TokenJamfPSPro.expires) -le ((Get-Date).AddMinutes(20))) ) {

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
                token      = [ConvertToSS]::Set($TokenResult.Token);
                expires    = Get-Date $TokenResult.expires;
                server     = $Server
                credential = $Credential
            }

            try {
                $VerifyAuth = Invoke-RestMethod $uri_Verify -Authentication Bearer -Token $Token.token -ContentType $app_Type -Headers $app_Headers
                Set-Variable -Name 'TokenJamfPSPro' -Value $Token -Scope Global -Option ReadOnly -Description "Token for Jamf Pro API" -Force
                $JamfBuild = Invoke-RestMethod $uri_Build -Authentication Bearer -Token $TokenJamfPSPro.token -ContentType $app_Type -Headers $app_Headers -Method GET
            } catch {
                $Error[0]
                Write-Error "$($_.Exception.Response.StatusCode.value__): $($_.Exception.Response.StatusCode)"
                Write-Error "Error authenticating to `'$Server`' with token"
                break
            }

            $ConnectionDetails = [PSCustomObject][Ordered]@{
                Account = $VerifyAuth.account.username
                Access  = $VerifyAuth.account.accessLevel
                Server  = $Server
                Build   = $JamfBuild
                Expires = $TokenJamfPSPro.expires
            }
            $ConnectionDetails | Format-Table

        } else {
            Write-Information "Token Variable Found"
            try {
                Write-Information "Trying $uri_KeepAlive"
                $KeepAlive = Invoke-RestMethod $uri_KeepAlive -Authentication Bearer -Token $TokenJamfPSPro.token -ContentType $app_Type -Headers $app_Headers -Method POST
                $TokenJamfPSPro.token   = [ConvertToSS]::Set($TokenResult.Token)
                $TokenJamfPSPro.expires = Get-Date $KeepAlive.expires
                Write-Information "Token expires: $($TokenJamfPSPro.expires)"
            } catch {
                Write-Error "Trying $uri_KeepAlive"
                if ( $TokenJamfPSPro.Server -and $TokenJamfPSPro.Credential ) {
                    Write-Information "Trying to connect again with stored details"
                    $TokenJamfPSPro.expires = $null
                    $TokenJamfPSPro.token   = $null
                    Connect-JamfPro -Server $TokenJamfPSPro.Server -Credential $TokenJamfPSPro.credential
                } else {
                    Clear-Variable -Name TokenJamfPSPro -Force
                    Connect-JamfPro
                }
            }
        }
    }

}