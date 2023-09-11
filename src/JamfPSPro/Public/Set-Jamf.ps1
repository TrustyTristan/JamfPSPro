<#
    .SYNOPSIS
        Updates data from Jamf Pro
    .DESCRIPTION
        Updates data from Jamf Pro
    .PARAMETER Component
        Specify the 'component' name
    .PARAMETER Params
        Specify params outlined by '{}' in component path
    .PARAMETER Content
        Specify content in valid schema
    .EXAMPLE
        Set-Jamf -Component scripts -Path 'scripts/{id}' -Params 420
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
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Params,

        [Parameter(
            Position = 3,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Content
    )
    DynamicParam {
        $ValidOptions = @( Get-ValidOption -Method 'put' -Component $Component )
        Get-DynamicParam -Name Path -ValidateSet $ValidOptions.URL -Mandatory -Position 1 -HelpMessage "Specify the selection method of the 'component path'"
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
            return Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'put'
        } elseif ( $Params.count -ge 1 ) {
            foreach ( $Param in $Params ) {
                $RestURL = $PathDetails.URL -replace '{.*?}', $Param
                $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
                $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'
                return Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'put'
                Clear-Variable -Name RestURL, Rest
            }
        } else {
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $PathDetails.URL -join '/'
            return Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'put'
        }
    }
}