<#
    .SYNOPSIS
        Create a new resource or record in Jamf Pro.
    .DESCRIPTION
        The New-Jamf cmdlet allows you to create a new resource or record in a Jamf Pro
        system, which is a comprehensive management solution for macOS and iOS devices.
        You can use this cmdlet to add new assets, configurations, or other entities to
        your Jamf Pro environment. Ensure that you have the necessary permissions and
        access to perform this action.
    .PARAMETER Component
        Specifies the component or resource name in Jamf Pro from which to create data.
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
        New-Jamf -Component computers -Select 'ID/recalculate-smart-groups' -Param 420
        Recalculates the smart group for the given computer id and then returns the count of
        smart groups the computer falls into.
    .EXAMPLE
        $NewScript = [PSCustomObject]@{
            'script' = @{
                'name' = 'Supa script';
                'category' = 'Testing';
                'info' = 'Script information';
                'notes' = 'Created 20230420';
                'priority' = 'Before';
                'parameters' = @{
                        'parameter4' = 'Some input';
                    }
                'os_requirements' = '10.15';
                'script_contents' = '#!/bin/
                    echo "Are you there?'
                }
            }
        New-Jamf -Component scripts -Select ID -Params 999 -Content $NewScript
        Creates a script 'Supa script', an ID must be supplied but will use next ID.
#>
function New-Jamf {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Position = 0,
            Mandatory)]
        [ValidateSet('accounts','advanced-mobile-device-searches','advanced-user-content-searches','advancedcomputersearches','advancedmobiledevicesearches','advancedusersearches','allowedfileextensions','api-integrations','api-roles','app-request','auth','branding','buildings','categories','check-in','classes','cloud-azure','cloud-idp','cloud-ldaps','computer-extension-attributes','computer-groups','computer-inventory','computer-inventory-collection-settings','computer-prestages','computercommands','computerextensionattributes','computergroups','computerinvitations','computers','computers-inventory','current','ddm','departments','deploy-package','device-communication-settings','device-enrollments','directorybindings','diskencryptionconfigurations','distributionpoints','dock-items','dockitems','ebooks','engage','enrollment','enrollment-customization','enrollment-customizations','fileuploads','gsx-connection','healthcarelistenerrule','history','ibeacons','icon','invalidateToken','inventory-preload','issueTomcatSslCertificate','jamf-connect','jamf-management-framework','jamf-pro-server-url','jamf-protect','jamf-remote-assist','jcds','jsonwebtokenconfigurations','keepAlive','ldap-keystore','ldapservers','licensedsoftware','macapplications','macos-managed-software-updates','managed-software-updates','mdm','mobile-device-apps','mobile-device-groups','mobile-device-prestages','mobile-devices','mobiledeviceapplications','mobiledevicecommands','mobiledeviceconfigurationprofiles','mobiledeviceenrollmentprofiles','mobiledeviceextensionattributes','mobiledevicegroups','mobiledeviceinvitations','mobiledeviceprovisioningprofiles','mobiledevices','networksegments','oidc','onboarding','osxconfigurationprofiles','packages','parent-app','patch-management-accept-disclaimer','patch-policies','patch-software-title-configurations','patches','patchexternalsources','patchpolicies','patchsoftwaretitles','peripherals','peripheraltypes','pki','policies','printers','reenrollment','remote-administration-configurations','removablemacaddresses','restrictedsoftware','return-to-service','scripts','self-service','sites','slasa','smart-computer-groups','smart-mobile-device-groups','smart-user-groups','smtp-server','softwareupdateservers','sso','supervision-identities','system','teacher-app','updateSession','user','userextensionattributes','usergroups','users','validate-csv','volume-purchasing-locations','volume-purchasing-subscriptions','vppaccounts','vppassignments','vppinvitations','webhooks')]
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
        $ValidOptions = @( Get-ValidOption -Method 'post' -Component $Component )
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

        if ( $Content ) {
            # Convert content to Simple XML
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
                    Write-Debug "Content in XML format"
                } catch {
                    try {
                        $Content = ConvertFrom-Json -InputObject $Content
                        Write-Debug "Content in Json format"
                    } catch {
                        Write-Debug "Could not format content"
                        break
                    }
                }
            }
            $AppType = 'application/xml'
        } else {
            $AppType = 'application/json'
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
                    $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'post' -Body $Content -AppType $AppType
                    if ( $Result.IsSuccessStatusCode -eq $true ) {
                        $Results.Add([pscustomobject]@{
                                Action  = 'Created'
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
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'post' -Body $Content -AppType $AppType
                if ( $Result.IsSuccessStatusCode -eq $true ) {
                    return [pscustomobject]@{
                        Action  = 'Created'
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