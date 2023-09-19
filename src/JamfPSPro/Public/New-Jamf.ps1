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
        The content to send to jamf in json format
    .EXAMPLE
        New-Jamf -Component computers -Path 'computers/{id}/recalculate-smart-groups' -Param 420 -Content $Data
#>
function New-Jamf {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Position = 0,
            Mandatory)]
        [ValidateSet('accounts','advanced-mobile-device-searches','advanced-user-content-searches','advancedcomputersearches','advancedmobiledevicesearches','advancedusersearches','allowedfileextensions','api-integrations','api-roles','app-request','auth','azure-ad-migration','branding','buildings','categories','check-in','classes','cloud-azure','cloud-idp','cloud-ldaps','computer-inventory-collection-settings','computer-prestages','computercommands','computerextensionattributes','computergroups','computerinvitations','computers-inventory','computers','csa','current','departments','deploy-package','device-communication-settings','device-enrollments','directorybindings','diskencryptionconfigurations','distributionpoints','dockitems','ebooks','engage','enrollment-customization','enrollment-customizations','enrollment','fileuploads','healthcarelistenerrule','history','ibeacons','icon','initialize','initialize-database-connection','invalidateToken','inventory-preload','issueTomcatSslCertificate','jamf-connect','jamf-management-framework','jamf-pro-server-url','jamf-protect','jsonwebtokenconfigurations','keepAlive','ldap-keystore','ldapservers','licensedsoftware','macapplications','macos-managed-software-updates','managedpreferenceprofiles','mdm','mobile-device-apps','mobile-device-groups','mobile-device-prestages','mobile-devices','mobiledeviceapplications','mobiledevicecommands','mobiledeviceconfigurationprofiles','mobiledeviceenrollmentprofiles','mobiledeviceextensionattributes','mobiledevicegroups','mobiledeviceinvitations','mobiledeviceprovisioningprofiles','mobiledevices','networksegments','osxconfigurationprofiles','packages','parent-app','patch-management-accept-disclaimer','patch-policies','patch-software-title-configurations','patches','patchexternalsources','patchpolicies','patchsoftwaretitles','peripherals','peripheraltypes','pki','policies','printers','reenrollment','remote-administration-configurations','removablemacaddresses','restrictedsoftware','scripts','search-mobile-devices','self-service','sites','smart-computer-groups','smart-mobile-device-groups','smart-user-groups','softwareupdateservers','sso','supervision-identities','system','teacher-app','tokens','updateSession','userextensionattributes','usergroups','users','validate-csv','volume-purchasing-locations','volume-purchasing-subscriptions','vppaccounts','vppassignments','vppinvitations','webhooks')]
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
            if ($PSCmdlet.ShouldProcess("$Component",'Create')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'post' -Body $Content -AppType 'application/xml'
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
        } elseif ( $Params.count -gt 1 ) {

            Write-Debug "Multi params"
            Write-Debug "Path: $Path"
            Write-Debug "Matches: $($ReplaceMatches.Matches.value)"

            $Results = New-Object System.Collections.Generic.List[System.Object]
            foreach ( $Param in $Params ) {
                $RestURL = $PathDetails.URL -replace '{.*?}', $Param
                $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
                $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'

                if ($PSCmdlet.ShouldProcess("$Component",'Create')){
                    $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'post' -Body $Content -AppType 'application/xml'
                    if ( $Result.IsSuccessStatusCode -eq $true) {
                        $Results.Add(
                            [pscustomobject]@{
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

            Write-Debug "Single param"
            Write-Debug "Path: $Path"
            Write-Debug "Matches: $($ReplaceMatches.Matches.value)"

            $RestURL = $PathDetails.URL -replace '{.*?}', $Params
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'
            if ($PSCmdlet.ShouldProcess("$Component",'Create')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'post' -Body $Content -AppType 'application/xml'
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