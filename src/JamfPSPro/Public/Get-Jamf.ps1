<#
    .SYNOPSIS
        Get data from Jamf Pro
    .DESCRIPTION
        Get data from Jamf Pro
    .PARAMETER Component
        Specify the 'component' name
    .PARAMETER Params
        Specify params outlined by '{}' in component path
    .EXAMPLE
        Get-Jamf -Component computers -Path 'computers/name/{name}' -Param 'HostName'
    .EXAMPLE
        Get-Jamf -Component local-admin-password -Path 'local-admin-password/{clientManagementId}/account/{username}/audit' -Param 69,myUser
#>
function Get-Jamf {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Position = 0,
            Mandatory)]
        [ValidateSet('accounts','activationcode','admin-accounts','adue-session-token-settings','advanced-mobile-device-searches','advanced-user-content-searches','advancedcomputersearches','advancedmobiledevicesearches','advancedusersearches','alerts','allowedfileextensions','api-integrations','api-role-privileges','api-roles','app-request','app-store-country-codes','auth','azure-ad-migration','branding-images','buildings','byoprofiles','cache-settings','categories','check-in','classes','classic-ldap','cloud-azure','cloud-idp','cloud-information','cloud-ldaps','computer-groups','computer-inventory-collection-settings','computer-prestages','computerapplications','computerapplicationusage','computercheckin','computercommands','computerextensionattributes','computergroups','computerhardwaresoftwarereports','computerhistory','computerinventorycollection','computerinvitations','computermanagement','computerreports','computers','computers-inventory','computers-inventory-detail','conditional-access','csa','csv-template','dashboard','departments','device-communication-settings','device-enrollments','directorybindings','diskencryptionconfigurations','distributionpoints','dockitems','ebooks','engage','enrollment','enrollment-customization','enrollment-customizations','extensionAttributes','groups','gsxconnection','healthcarelistener','healthcarelistenerrule','history','ibeacons','icon','infrastructuremanager','inventory-information','inventory-preload','jamf-connect','jamf-package','jamf-pro-information','jamf-pro-server-url','jamf-pro-version','jamf-protect','jsonwebtokenconfigurations','jssuser','ldap','ldapservers','licensedsoftware','local-admin-password','locales','macapplications','macos-managed-software-updates','managed-software-updates','managedpreferenceprofiles','mdm','mobile-device-enrollment-profile','mobile-device-groups','mobile-device-prestages','mobile-devices','mobiledeviceapplications','mobiledevicecommands','mobiledeviceconfigurationprofiles','mobiledeviceenrollmentprofiles','mobiledeviceextensionattributes','mobiledevicegroups','mobiledevicehistory','mobiledeviceinvitations','mobiledeviceprovisioningprofiles','mobiledevices','networksegments','notifications','obj','osxconfigurationprofiles','packages','parent-app','patch-policies','patch-software-title-configurations','patchavailabletitles','patches','patchexternalsources','patchinternalsources','patchpolicies','patchreports','patchsoftwaretitles','peripherals','peripheraltypes','pki','policies','policy-properties','printers','reenrollment','remote-administration-configurations','removablemacaddresses','restrictedsoftware','savedsearches','scripts','self-service','servers','sites','smtpserver','softwareupdateservers','sso','static-user-groups','subscriptions','supervision-identities','teacher-app','time-zones','user','userextensionattributes','usergroups','users','volume-purchasing-locations','volume-purchasing-subscriptions','vppaccounts','vppassignments','vppinvitations','webhooks')]
        [ValidateNotNullOrEmpty()]
        [String]$Component,

        [Parameter(
            Position = 2,
            Mandatory = $false,
            ValueFromPipeline = $true)]
        [ValidateScript({ ![String]::IsNullOrEmpty($_) })]
        [String[]]$Params
    )
    DynamicParam {
        $ValidOptions = @( Get-ValidOption -Method 'get' -Component $Component )
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
        $ReplacementCounter = 0
    }

    PROCESS {
        if ( $ReplaceMatches.Matches.count -gt 1 ) {
            Write-Information "Multi Param Path"
            foreach ( $replace in $ReplaceMatches.Matches.value ) {
                if ( $ReplacementCounter -eq 0 ) {
                    $RestURL = $PathDetails.URL -replace $replace, $Params[$ReplacementCounter]
                    $ReplacementCounter++
                } else {
                    $RestURL = $RestURL -replace $replace, $Params[$ReplacementCounter]
                    $ReplacementCounter++
                }
            }
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'
            if ($PSCmdlet.ShouldProcess("$RestURL",'Get')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'get'
                if ( $Result.IsSuccessStatusCode -eq $true ) {
                    return $Result | Select-Object * -ExcludeProperty IsSuccessStatusCode
                } else {
                    Write-Error (Get-ErrorMessage $Result)
                }
            }
        } elseif ( $Params.count -gt 1 ) {
            Write-Information "Multi Params"
            $Results = New-Object System.Collections.Generic.List[System.Object]
            foreach ( $Param in $Params ) {
                $RestURL = $PathDetails.URL -replace '{.*?}', $Param
                $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
                $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'

                if ($PSCmdlet.ShouldProcess("$RestURL",'Get')){
                    $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'get'
                    if ( $Result.IsSuccessStatusCode -eq $true) {
                        $Results.Add( ($Result | Select-Object * -ExcludeProperty IsSuccessStatusCode) )
                    } else {
                        Write-Error (Get-ErrorMessage $Result)
                    }
                }

            }
            return $Results
        } else {
            Write-Information "Single Param"
            $RestURL = $PathDetails.URL -replace '{.*?}', $Params
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'
            if ($PSCmdlet.ShouldProcess("$RestURL",'Get')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'get'
                if ( $Result.IsSuccessStatusCode -eq $true) {
                    return $Result | Select-Object * -ExcludeProperty IsSuccessStatusCode
                } else {
                    Write-Error (Get-ErrorMessage $Result)
                }
            }
        }
    }
}