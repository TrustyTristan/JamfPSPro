<#
    .SYNOPSIS
        Remove an existing resource or record from Jamf Pro.
    .DESCRIPTION
        The Remove-Jamf cmdlet allows you to delete or remove an existing resource
        or record from a Jamf Pro system, which is a comprehensive management solution
        for macOS and iOS devices. You can use this cmdlet to delete assets, configurations,
        or other entities from your Jamf Pro environment. Ensure that you have the necessary
        permissions and access for this operation.
    .PARAMETER Component
        Specifies the component or resource name in Jamf Pro from which to remove data.
        This parameter is mandatory.
    .PARAMETER Select
        Specifies the fields to use to submit data to. The UPPERCASE values are to indicate
        the parameters for -Param.
        This parameter is mandatory.
    .PARAMETER Params
        Specifies additional parameters required for filtering or selecting the data to remove.
        Parameters are indicated by UPPERCASE from -Select
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
        [ValidateNotNullOrEmpty()]
        [String[]]$Params
    )
    DynamicParam {
        $ValidOptions = @( Get-ValidOption -Method 'delete' -Component $Component )
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
        $replacementCounter = 0
    }

    PROCESS {
        if ( $ReplaceMatches.count -gt 1 ) {

            Write-Debug "Multi param path"
            Write-Debug "Path: $($Path.URL)"
            Write-Debug "Matches: $($ReplaceMatches.Matches.value)"

            foreach ( $replace in $ReplaceMatches.Matches.value ) {
                $RestURL = $Path.URL -replace $replace, $Params[$replacementCounter]
                $replacementCounter++
            }
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $Path.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $Path.API, $RestURL -join '/'

            if ($PSCmdlet.ShouldProcess("$RestURL",'Delete')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'delete'
                if ( $Result.IsSuccessStatusCode -eq $true ) {
                    return [pscustomobject]@{
                        Action = 'Removed'
                        Path   = $RestURL
                    }
                } else {
                    Write-Error (Get-ErrorMessage $Result)
                }
            }
        } elseif ( $Params.count -gt 1 ) {

            Write-Debug "Multi params"
            Write-Debug "Path: $($Path.URL)"
            Write-Debug "Matches: $($ReplaceMatches.Matches.value)"

            $Results = New-Object System.Collections.Generic.List[System.Object]
            foreach ( $Param in $Params ) {
                $RestURL = $Path.URL -replace '{.*?}', $Param
                $BaseURL = 'https:/', $TokenJamfPSPro.Server, $Path.API -join '/'
                $RestPath = 'https:/', $TokenJamfPSPro.Server, $Path.API, $RestURL -join '/'

                if ($PSCmdlet.ShouldProcess("$RestURL",'Delete')){
                    $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'delete'
                    if ( $Result.IsSuccessStatusCode -eq $true) {
                        $Results.Add(
                            [pscustomobject]@{
                                Action = 'Removed'
                                Path   = $RestURL
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
            Write-Debug "Path: $($Path.URL)"
            Write-Debug "Matches: $($ReplaceMatches.Matches.value)"

            $RestURL = $Path.URL -replace '{.*?}', $Params
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $Path.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $Path.API, $RestURL -join '/'
            if ($PSCmdlet.ShouldProcess("$RestURL",'Delete')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'delete'
                if ( $Result.IsSuccessStatusCode -eq $true ) {
                    return [pscustomobject]@{
                        Action = 'Removed'
                        Path   = $RestURL
                    }
                } else {
                    Write-Debug "IsSuccessStatusCode: $false"
                    Write-Error (Get-ErrorMessage $Result)
                }
            }
        }
    }
}