<#
    .SYNOPSIS
        Sets/Post data from Jamf Pro
    .DESCRIPTION
        Sets/Post data from Jamf Pro
    .PARAMETER Component
        Specify the 'component' name
    .PARAMETER Params
        Specify params outlined by '{}' in component path
    .PARAMETER Content
        The content to send to jamf
    .EXAMPLE
        Set-Jamf -Component computers -Path 'computers/{id}/recalculate-smart-groups' -Param 420
    .EXAMPLE
        Set-Jamf -Component enrollment -Path 'enrollment/history/export'
#>
function Set-Jamf {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Position = 0,
            Mandatory)]
        [ValidateSet('accounts','activationcode','adue-session-token-settings','advanced-mobile-device-searches','advanced-user-content-searches','advancedcomputersearches','advancedmobiledevicesearches','advancedusersearches','api-integrations','api-roles','app-request','buildings','byoprofiles','cache-settings','categories','check-in','classes','cloud-azure','cloud-ldaps','computer-prestages','computercheckin','computerextensionattributes','computergroups','computerinventorycollection','computers','csa','departments','device-communication-settings','device-enrollments','directorybindings','diskencryptionconfigurations','distributionpoints','dockitems','ebooks','engage','enrollment','enrollment-customization','enrollment-customizations','gsxconnection','healthcarelistener','healthcarelistenerrule','ibeacons','infrastructuremanager','inventory-preload','jamf-connect','jamf-pro-server-url','jamf-protect','jsonwebtokenconfigurations','ldapservers','licensedsoftware','local-admin-password','macapplications','managedpreferenceprofiles','mobile-device-prestages','mobiledeviceapplications','mobiledeviceconfigurationprofiles','mobiledeviceenrollmentprofiles','mobiledeviceextensionattributes','mobiledevicegroups','mobiledeviceprovisioningprofiles','mobiledevices','networksegments','obj','osxconfigurationprofiles','packages','parent-app','patches','patchexternalsources','patchpolicies','patchsoftwaretitles','peripherals','peripheraltypes','policies','policy-properties','printers','reenrollment','removablemacaddresses','restrictedsoftware','scripts','self-service','sites','smtpserver','softwareupdateservers','sso','supervision-identities','teacher-app','user','userextensionattributes','usergroups','users','volume-purchasing-subscriptions','vppaccounts','vppassignments','vppinvitations','webhooks')]
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
        Get-DynamicParam -Name Path -ValidateSet $ValidOptions.URL -Mandatory -Position 1 -HelpMessage "Specify the selection method of the 'component path'"
    }
    BEGIN {
        if ( $TokenJamfPSPro.Server -and $TokenJamfPSPro.credential ) {
            Connect-JamfPro -Server $TokenJamfPSPro.Server -Credential $TokenJamfPSPro.credential
        } else {
            Connect-JamfPro
        }

        $Path = $PSBoundParameters.Path
        $PathDetails = $ValidOptions | Where-Object {$_.url -eq $Path}
        $ReplaceMatches = $PathDetails.URL | Select-String -Pattern '{.*?}' -AllMatches
        $replacementCounter = 0
    }

    PROCESS {

        # Convert content to Simple XML
        if ( $Content.GetType() -eq 'XmlDocument' ) {
            Write-Debug "Content type: XML"
            $Content = $Content.InnerXml
        } elseif ( $Content.GetType() -eq 'PSCustomObject' ) {
            Write-Debug "Content type: PSObject"
            $Content = ( ConvertTo-SimpleXml $Content )
        } elseif ( $Content.GetType() -eq 'String' ) {
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
        }

        if ( $ReplaceMatches.count -gt 1 ) {

            Write-Debug "Multi param path"
            Write-Debug "Path: $Path"
            Write-Debug "Matches: $($ReplaceMatches.Matches.value)"

            foreach ( $replace in $ReplaceMatches.Matches.value ) {
                $RestURL = $PathDetails.URL -replace $replace, $Params[$replacementCounter]
                $replacementCounter++
            }
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'
            if ($PSCmdlet.ShouldProcess("$RestURL",'Create')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'put' -Body $Content -AppType 'application/xml'
                if ( $Result.IsSuccessStatusCode -eq $true) {
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
        } elseif ( $Params.count -gt 1 ) {

            Write-Debug "Multi params"
            Write-Debug "Path: $Path"
            Write-Debug "Matches: $($ReplaceMatches.Matches.value)"

            $Results = New-Object System.Collections.Generic.List[System.Object]
            foreach ( $Param in $Params ) {
                $RestURL = $PathDetails.URL -replace '{.*?}', $Param
                $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
                $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'

                if ($PSCmdlet.ShouldProcess("$RestURL",'Create')){
                    $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'put' -Body $Content -AppType 'application/xml'
                    if ( $Result.IsSuccessStatusCode -eq $true) {
                        $Results.Add(
                            [pscustomobject]@{
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

            Write-Debug "Single param"
            Write-Debug "Path: $Path"
            Write-Debug "Matches: $($ReplaceMatches.Matches.value)"

            $RestURL = $PathDetails.URL -replace '{.*?}', $Params
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'
            if ($PSCmdlet.ShouldProcess("$RestURL",'Create')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'put' -Body $Content -AppType 'application/xml'
                if ( $Result.IsSuccessStatusCode -eq $true) {
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