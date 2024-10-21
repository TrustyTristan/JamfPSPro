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
        Remove-Jamf -Component computers -Select ID -Params 69
        Removes the computer with the ID 69
#>
function Remove-Jamf {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Position = 0,
            Mandatory)]
        [ValidateSet('accounts','advanced-mobile-device-searches','advanced-user-content-searches','advancedcomputersearches','advancedmobiledevicesearches','advancedusersearches','alerts','allowedfileextensions','api-integrations','api-roles','app-request','buildings','categories','classes','cloud-azure','cloud-ldaps','commandflush','computer-extension-attributes','computer-groups','computer-inventory-collection-settings','computer-prestages','computerextensionattributes','computergroups','computerinvitations','computers','computers-inventory','csa','departments','device-enrollments','directorybindings','diskencryptionconfigurations','distributionpoints','dock-items','dockitems','ebooks','enrollment','enrollment-customization','enrollment-customizations','ibeacons','inventory-preload','jamf-protect','jcds','jsonwebtokenconfigurations','ldapservers','licensedsoftware','logflush','macapplications','mobile-device-groups','mobile-device-prestages','mobiledeviceapplications','mobiledeviceconfigurationprofiles','mobiledeviceenrollmentprofiles','mobiledeviceextensionattributes','mobiledevicegroups','mobiledeviceinvitations','mobiledeviceprovisioningprofiles','mobiledevices','networksegments','notifications','obj','osxconfigurationprofiles','packages','patch-policies','patch-software-title-configurations','patches','patchpolicies','patchsoftwaretitles','peripherals','peripheraltypes','pki','policies','printers','remote-administration-configurations','removablemacaddresses','restrictedsoftware','return-to-service','scripts','self-service','sites','softwareupdateservers','sso','supervision-identities','user','userextensionattributes','usergroups','users','volume-purchasing-locations','volume-purchasing-subscriptions','vppaccounts','vppassignments','vppinvitations','webhooks')]
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
        $MatchType = switch ($true) {
            { ($ReplaceMatches.Matches.Count -eq $Params.Count) -and ($Params.Count) -eq 1}                  { "1-1" }
            { ($ReplaceMatches.Matches.Count -eq 1) -and ($Params.Count -gt 1) }                             { "1-Many" }
            { ($ReplaceMatches.Matches.Count -eq $Params.Count) -and ($Params.Count) -gt 1}                  { "Many-Many" }
            { ($ReplaceMatches.Matches.Count -gt 1) -and ($Params.Count -gt $ReplaceMatches.Matches.Count) } { "Many-More" }
        }
    }

    PROCESS {

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
                if ($PSCmdlet.ShouldProcess("$Component",'Delete')){
                    $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'delete'
                    if ( $Result.IsSuccessStatusCode -eq $true ) {
                        $Results.Add([pscustomobject]@{
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
            $BaseURL = 'https:/', $TokenJamfPSPro.Server, $Path.API -join '/'
            $RestPath = 'https:/', $TokenJamfPSPro.Server, $Path.API, $RestURL -join '/'
            if ($PSCmdlet.ShouldProcess("$Component",'Delete')){
                $Result = Invoke-JamfAPICall -Path $RestPath -BaseURL $BaseURL -Method 'post'
                if ( $Result.IsSuccessStatusCode -eq $true ) {
                    return [pscustomobject]@{
                        Action = 'Removed'
                        Path   = $RestURL
                    }
                } else {
                    Write-Error (Get-ErrorMessage $Result)
                }
            }
        }

    }
}