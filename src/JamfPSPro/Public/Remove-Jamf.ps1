<#
    .SYNOPSIS
        Removes data from Jamf Pro
    .DESCRIPTION
        Removes data from Jamf Pro
    .PARAMETER Component
        Specify the 'component' name
    .PARAMETER Params
        Specify params outlined by '{}' in component path
    .EXAMPLE
        Remove-Jamf -Component computers -Path 'computers-inventory/{id}' -Params 69
#>
function Remove-Jamf {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Position = 0,
            Mandatory)]
        [ValidateSet('accounts','advanced-mobile-device-searches','advanced-user-content-searches','advancedcomputersearches','advancedmobiledevicesearches','advancedusersearches','alerts','allowedfileextensions','api-integrations','api-roles','app-request','buildings','categories','classes','cloud-azure','cloud-ldaps','commandflush','computer-inventory-collection-settings','computer-prestages','computerextensionattributes','computergroups','computerinvitations','computers-inventory','computers','csa','departments','device-enrollments','directorybindings','diskencryptionconfigurations','distributionpoints','dockitems','ebooks','enrollment-customization','enrollment-customizations','enrollment','ibeacons','inventory-preload','jamf-protect','jsonwebtokenconfigurations','ldapservers','licensedsoftware','logflush','macapplications','managedpreferenceprofiles','mobile-device-groups','mobile-device-prestages','mobiledeviceapplications','mobiledeviceconfigurationprofiles','mobiledeviceenrollmentprofiles','mobiledeviceextensionattributes','mobiledevicegroups','mobiledeviceinvitations','mobiledeviceprovisioningprofiles','mobiledevices','networksegments','notifications','obj','osxconfigurationprofiles','packages','patch-policies','patch-software-title-configurations','patches','patchpolicies','patchsoftwaretitles','peripherals','peripheraltypes','pki','policies','printers','remote-administration-configurations','removablemacaddresses','restrictedsoftware','scripts','self-service','sites','softwareupdateservers','sso','supervision-identities','user','userextensionattributes','usergroups','users','volume-purchasing-locations','volume-purchasing-subscriptions','vppaccounts','vppassignments','vppinvitations','webhooks')]
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
        $ValidOptions = @( Get-ValidOption -Method 'delete' -Component $Component )
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
        if ( $ReplaceMatches.count -gt 1 ) {
            foreach ( $replace in $ReplaceMatches.Matches.value ) {
                $RestURL = $PathDetails.URL -replace $replace, $Params[$replacementCounter]
                $replacementCounter++
            }
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'

            if ($PSCmdlet.ShouldProcess("$RestURL",'Delete')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'delete'
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

                if ($PSCmdlet.ShouldProcess("$RestURL",'Delete')){
                    $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'delete'
                    if ( $Result.IsSuccessStatusCode -eq $true) {
                        $Results.Add( ($Result | Select-Object * -ExcludeProperty IsSuccessStatusCode) )
                    } else {
                        Write-Error (Get-ErrorMessage $Result)
                    }
                }

            }
            return $Results
        } else {
            $RestURL = $PathDetails.URL -replace '{.*?}', $Params
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $PathDetails.API, $RestURL -join '/'
            if ($PSCmdlet.ShouldProcess("$RestURL",'Delete')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'delete'
                if ( $Result.IsSuccessStatusCode -eq $true ) {
                    return $Result | Select-Object * -ExcludeProperty IsSuccessStatusCode
                } else {
                    Write-Error (Get-ErrorMessage $Result)
                }
            }
        }
    }
}