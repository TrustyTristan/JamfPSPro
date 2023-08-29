<#
    .SYNOPSIS
        Sets/Post data from Jamf Pro
    .DESCRIPTION
        Sets/Post data from Jamf Pro
    .PARAMETER Component
        Specify the 'component' name
    .PARAMETER Path
        Specify the selection method of the 'component path'
    .PARAMETER Params
        Specify params outlined by '{}' in component path
    .EXAMPLE
        New-Jamf -Component computers -Path 'computers/{id}/recalculate-smart-groups' -Param 420
    .EXAMPLE
        New-Jamf -Component enrollment -Path 'enrollment/history/export'
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
            Mandatory = $false)]
        [ValidateScript({ ![String]::IsNullOrEmpty($_) })]
        [String[]]$Params
    )
    DynamicParam {
        $ValidOptions = @( Get-ValidOption -Method 'post' -Component $Component )
        Get-DynamicParam -Name Path -ValidateSet $ValidOptions.URL -Mandatory -Position 1
    }
    BEGIN {
        $Path = $PSBoundParameters.Path
        $PathDetails = $ValidOptions | Where-Object {$_.url -eq $Path}
        $ReplaceMatches = $PathDetails.URL | Select-String -Pattern '{.*?}' -AllMatches
        $replacementCounter = 0
    }

    PROCESS {
        if ( $ReplaceMatches.count -gt 1 ) {
            foreach ( $replace in $ReplaceMatches.Matches.value ) {
                $RestURL = $PathDetails.URL -replace $replace, $Params[$replacementCounter]
                $replacementCounter++
            }
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'
            return Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'post'
        } elseif ( $Params.count -ge 1 ) {
            foreach ( $Param in $Params ) {
                $RestURL = $PathDetails.URL -replace '{.*?}', $Param
                $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
                $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'
                return Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'post'
                Clear-Variable -Name RestURL, Rest
            }
        } else {
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $PathDetails.URL -join '/'
            return Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'post'
        }
    }
}