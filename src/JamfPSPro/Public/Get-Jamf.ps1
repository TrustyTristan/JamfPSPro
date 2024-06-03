<#
    .SYNOPSIS
        Retrieve data from Jamf Pro.
    .DESCRIPTION
        The Get-Jamf cmdlet allows you to retrieve data from Jamf Pro, a comprehensive
        management solution for macOS and iOS devices. This cmdlet provides various
        options for fetching specific information from Jamf Pro based on your requirements.
        You can specify the component, select fields, and provide additional parameters to
        customize your data retrieval.

        Note: Ensure that you have proper permissions and access to Jamf Pro.
    .PARAMETER Component
        Specifies the component or resource name in Jamf Pro from which to retrieve data.
        This parameter is mandatory.
    .PARAMETER Select
        Specifies the fields to use to retrieved data. The UPPERCASE values are to indicate
        the parameters for -Param. The 'all' selection is available to some components to
        retrieve all available fields, no -Param option is required in this case.
        This parameter is mandatory.
    .PARAMETER Params
        Specifies additional parameters required for filtering or customizing the data
        retrieval. Parameters are indicated by UPPERCASE from -Select
    .EXAMPLE
        Get-Jamf -Component computers -Select all
        Retrieves all available information for computers in Jamf Pro.
    .EXAMPLE
        Get-Jamf -Component computers -Select NAME -Param 'MacBookPro69'
        Retrieves the computer object details for the computer names 'MacBookPro69'
    .EXAMPLE
        Get-Jamf -Component local-admin-password -Select 'CLIENTMANAGEMENTID/account/USERNAME/audit' -Param 69, 'myUser'
#>
function Get-Jamf {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Position = 0,
            Mandatory)]
        [ValidateSet('accounts','activationcode','advancedcomputersearches','advancedmobiledevicesearches','advancedusersearches','allowedfileextensions','buildings','byoprofiles','categories','classes','computerapplications','computerapplicationusage','computercheckin','computercommands','computerextensionattributes','computergroups','computerhardwaresoftwarereports','computerhistory','computerinventorycollection','computerinvitations','computermanagement','computerreports','computers','departments','directorybindings','diskencryptionconfigurations','distributionpoints','dockitems','ebooks','gsxconnection','healthcarelistener','healthcarelistenerrule','ibeacons','infrastructuremanager','jsonwebtokenconfigurations','jssuser','ldapservers','licensedsoftware','macapplications','mobiledeviceapplications','mobiledevicecommands','mobiledeviceconfigurationprofiles','mobiledeviceenrollmentprofiles','mobiledeviceextensionattributes','mobiledevicegroups','mobiledevicehistory','mobiledeviceinvitations','mobiledeviceprovisioningprofiles','mobiledevices','networksegments','osxconfigurationprofiles','packages','patchavailabletitles','patches','patchexternalsources','patchinternalsources','patchpolicies','patchreports','patchsoftwaretitles','peripherals','peripheraltypes','policies','printers','removablemacaddresses','restrictedsoftware','savedsearches','scripts','sites','smtpserver','softwareupdateservers','userextensionattributes','usergroups','users','vppaccounts','vppassignments','vppinvitations','webhooks','extensionAttributes','csv-template','history','groups','servers','alerts','remote-administration-configurations','obj','adue-session-token-settings','advanced-mobile-device-searches','advanced-user-content-searches','api-integrations','api-role-privileges','api-roles','app-request','app-store-country-codes','auth','branding-images','cache-settings','classic-ldap','cloud-azure','cloud-distribution-point','cloud-idp','cloud-information','computer-groups','computer-inventory-collection-settings','computer-prestages','computers-inventory','computers-inventory-detail','conditional-access','csa','dashboard','device-communication-settings','device-enrollments','dock-items','engage','enrollment-customization','gsx-connection','health-check','icon','inventory-information','inventory-preload','jamf-connect','jamf-package','jamf-pro-information','jamf-pro-server-url','jamf-pro-version','jamf-protect','jamf-remote-assist','jcds','ldap','local-admin-password','locales','login-customization','macos-managed-software-updates','managed-software-updates','mdm','mobile-device-enrollment-profile','mobile-device-groups','mobile-device-prestages','mobile-devices','notifications','onboarding','parent-app','pki','policy-properties','reenrollment','return-to-service','scheduler','self-service','smtp-server','sso','static-user-groups','supervision-identities','teacher-app','time-zones','user','volume-purchasing-locations','volume-purchasing-subscriptions','account-preferences','cloud-ldaps','enrollment','enrollment-customizations','patch-policies','patch-software-title-configurations','check-in')]
        [ValidateNotNullOrEmpty()]
        [String]$Component,

        [Parameter(
            Position = 2,
            Mandatory = $false,
            ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Params
    )
    DynamicParam {
        $ValidOptions = @( Get-ValidOption -Method 'get' -Component $Component )
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

        $RestURL = $Path.URL
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
                if ($PSCmdlet.ShouldProcess("$RestURL",'Get')){
                    $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'get'
                    if ( $Result.IsSuccessStatusCode -eq $true ) {
                        $Results.Add( ($Result | Select-Object * -ExcludeProperty IsSuccessStatusCode) )
                    } else {
                        Write-Error (Get-ErrorMessage $Result)
                    }
                }
            }
            return $Results
        } else {
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $Path.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $Path.API, $RestURL -join '/'
            if ($PSCmdlet.ShouldProcess("$RestURL",'Get')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'get'
                if ( $Result.IsSuccessStatusCode -eq $true ) {
                    return $Result | Select-Object * -ExcludeProperty IsSuccessStatusCode
                } else {
                    Write-Error (Get-ErrorMessage $Result)
                }
            }
        }

    }
}