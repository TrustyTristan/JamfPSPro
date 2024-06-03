<#
    .SYNOPSIS
        Update or modify an existing resource or record in Jamf Pro.
    .DESCRIPTION
        The Set-Jamf cmdlet enables you to update or modify an existing resource or
        record in a Jamf Pro system. Jamf Pro is a comprehensive management solution
        for macOS and iOS devices. You can use this cmdlet to make changes to assets,
        configurations, or other entities in your Jamf Pro environment. Ensure that you
        have the necessary permissions and access for this operation.
    .PARAMETER Component
        Specifies the component or resource name in Jamf Pro from which to update data.
        This parameter is mandatory.
    .PARAMETER Select
        Specifies the fields to use to submit data to. The UPPERCASE values are to indicate
        the parameters for -Param.
        This parameter is mandatory.
    .PARAMETER Params
        Specifies additional parameters required for filtering or customizing the data
        retrieval. Parameters are indicated by UPPERCASE from -Select
    .PARAMETER Content
        The content to send to jamf this can be in json, PSObject or jamf simple xml format.
    .EXAMPLE
        $UpdatedScript = "<script><name>Blazing Script</name></script>"
        Set-Jamf -Component scripts -Select ID -Param 420 -Content $UpdatedScript
        Changes the name of the script with the ID 420
    .EXAMPLE
        $Update = [PSCustomObject]@{
            'computer_group' = @{
                'name' = 'The Plastics';
                }
            }
        Set-Jamf -Component computergroups -Select ID -Param 69 -Content $Update
        Changes the name of the computer group with the ID of 69
#>
function Set-Jamf {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Position = 0,
            Mandatory)]
        [ValidateSet('accounts','activation-code','activationcode','adue-session-token-settings','advanced-mobile-device-searches','advanced-user-content-searches','advancedcomputersearches','advancedmobiledevicesearches','advancedusersearches','api-integrations','api-roles','app-request','buildings','byoprofiles','cache-settings','categories','check-in','classes','cloud-azure','cloud-ldaps','computer-prestages','computercheckin','computerextensionattributes','computergroups','computerinventorycollection','computers','departments','device-communication-settings','device-enrollments','directorybindings','diskencryptionconfigurations','distributionpoints','dock-items','dockitems','ebooks','engage','enrollment','enrollment-customization','enrollment-customizations','gsx-connection','gsxconnection','healthcarelistener','healthcarelistenerrule','ibeacons','infrastructuremanager','inventory-preload','jamf-connect','jamf-pro-server-url','jamf-protect','jsonwebtokenconfigurations','ldapservers','licensedsoftware','local-admin-password','login-customization','macapplications','managed-software-updates','mobile-device-prestages','mobiledeviceapplications','mobiledeviceconfigurationprofiles','mobiledeviceenrollmentprofiles','mobiledeviceextensionattributes','mobiledevicegroups','mobiledeviceprovisioningprofiles','mobiledevices','networksegments','obj','onboarding','osxconfigurationprofiles','packages','parent-app','patches','patchexternalsources','patchpolicies','patchsoftwaretitles','peripherals','peripheraltypes','policies','policy-properties','printers','reenrollment','removablemacaddresses','restrictedsoftware','return-to-service','scripts','self-service','sites','smtp-server','smtpserver','softwareupdateservers','sso','supervision-identities','teacher-app','user','userextensionattributes','usergroups','users','volume-purchasing-subscriptions','vppaccounts','vppassignments','vppinvitations','webhooks')]
        [ValidateNotNullOrEmpty()]
        [String]$Component,

        [Parameter(
            Position = 2,
            Mandatory = $false,
            ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Params,

        [Parameter(
            Position = 3,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Content
    )
    DynamicParam {
        $ValidOptions = @( Get-ValidOption -Method 'put' -Component $Component )
        Get-DynamicParam -Name Select -ValidateSet $ValidOptions.Option -Mandatory -Position 1 -HelpMessage "Specify the selection method of the 'component path'"
    }
    BEGIN {
        if ( $TokenJamfPSPro.Server -and $TokenJamfPSPro.credential ) {
            Connect-JamfPro -Server $TokenJamfPSPro.Server -Credential $TokenJamfPSPro.credential
        } else {
            Connect-JamfPro
        }

        $Path = $ValidOptions | Where-Object {$_.Option -eq $PSBoundParameters.Select}
        $ReplaceMatches = $Path.URL | Select-String -Pattern '{.*?}' -AllMatches
        $MatchType = switch ($true) {
            { ($ReplaceMatches.Matches.Count -eq $Params.Count) -and ($Params.Count) -eq 1}                  { "1-1" }
            { ($ReplaceMatches.Matches.Count -eq 1) -and ($Params.Count -gt 1) }                             { "1-Many" }
            { ($ReplaceMatches.Matches.Count -eq $Params.Count) -and ($Params.Count) -gt 1}                  { "Many-Many" }
            { ($ReplaceMatches.Matches.Count -gt 1) -and ($Params.Count -gt $ReplaceMatches.Matches.Count) } { "Many-More" }
        }
    }

    PROCESS {

        # Convert content to Simple XML
        if ( $Content ) {
            if ( $Content.GetType().Name -eq 'XmlDocument' ) {
                Write-Debug "Content type: XML"
                $Content = $Content.InnerXml
            } elseif ( $Content.GetType().Name -eq 'PSCustomObject' ) {
                Write-Debug "Content type: PSObject"
                $Content = ( ConvertTo-SimpleXml $Content )
            } elseif ( $Content.GetType().Name -eq 'String' ) {
                Write-Debug "Content type: String"
                try {
                    $Content = ( [xml]$Content ).InnerXml
                    Write-Debug "Content already in XML format"
                } catch {
                    try {
                        $Content = ConvertFrom-Json -InputObject $Content
                        Write-Debug "Content in Json format"
                    } catch {
                        Write-Debug "Could not format content"
                        break
                    }
                }
                $AppType = 'application/xml'
            } else {
                $AppType = 'application/json'
            }
        }

        if ( $MatchType -match '1-1|Many-Many' ) {
            Write-Debug "1-1|Many-Many"
            foreach ( $Replacement in $ReplaceMatches.Matches.value ) {
                Write-Debug "Path: $RestURL"
                $MatchIndex = [array]::IndexOf($ReplaceMatches.Matches.value, $Replacement)
                $RestURL = $RestURL -replace $Replacement, $Params[$MatchIndex]
            }
        } elseif ( $MatchType -match '1-Many|Many-More' ) {
            Write-Debug "1-Many|Many-More"
            for ( ($i = 0); $i -lt ($ReplaceMatches.Matches.Count - 1); $i++ ) {
                Write-Debug "Path: $RestURL"
                $RestURL = $RestURL -replace $ReplaceMatches.Matches[$i].value, $Params[$i]
            }
            if ( $ReplaceMatches.Matches[$i].value -match 'list' ) {
                $RestURL = $RestURL -replace $ReplaceMatches.Matches[$i].value, ($Params[$i..($Params.count)] -join ',')
                Write-Debug "Path: $RestURL"
            } else {
                $CustomList = $true
            }
        }

        if ( $CustomList ) {
            $Results = New-Object System.Collections.Generic.List[System.Object]
            foreach ( $Param in $Params[$i..($Params.count)] ) {
                $RestURL = $RestURL -replace $ReplaceMatches.Matches[$i].value, $Param
                $BaseURL = 'https:/', $TokenJamfPSPro.Server, $Path.API -join '/'
                $RestPath = 'https:/', $TokenJamfPSPro.Server, $Path.API, $RestURL -join '/'
                if ($PSCmdlet.ShouldProcess("$Component",'Create')){
                    $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'put' -Body $Content -AppType $AppType
                    if ( $Result.IsSuccessStatusCode -eq $true ) {
                        $Results.Add([pscustomobject]@{
                                Action  = 'Set'
                                Path    = $RestURL
                                Content = $Content
                                Result  = $Result
                            }
                        )
                    } else {
                        Write-Error (Get-ErrorMessage $Result)
                    }
                }
            }
            return $Results
        } else {
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $Path.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $Path.API, $RestURL -join '/'
            if ($PSCmdlet.ShouldProcess("$Component",'Create')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'put' -Body $Content -AppType $AppType
                if ( $Result.IsSuccessStatusCode -eq $true ) {
                    return [pscustomobject]@{
                        Action  = 'Set'
                        Path    = $RestURL
                        Content = $Content
                        Result  = $Result
                    }
                } else {
                    Write-Error (Get-ErrorMessage $Result)
                }
            }
        }

    }
}