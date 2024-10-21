<#
    .SYNOPSIS
        Retrieve a valid Jamf api call.
    .DESCRIPTION
        The Get-ValidJamfOption cmdlet allows you to look up both the schema and swagger
        from Jamf Pro and return the possible api calls.
        These are filtered to the core methods of delete, get, post and put.

        Note: Ensure that you have proper permissions and access to Jamf Pro.
    .PARAMETER Method
        Specifies the method of the api call to lookup. Eg delete, get, post and put.
        This parameter is mandatory.
    .PARAMETER Component
        Specifies the component or resource name in Jamf Pro from which to retrieve data.
        This parameter is not mandatory.
    .EXAMPLE
        Get-ValidJamfOption -Method get
        Retrieves all available api calls that match the get method.
    .EXAMPLE
        Get-ValidJamfOption -Method get -Component computers
        Retrieves all the available api calls that match the get method and computers path.
#>
function Get-ValidJamfOption {
    param (
        [Parameter(
            Position = 0,
            Mandatory)]
        [ValidateSet('delete','get','post','put')]
        [ValidateNotNullOrEmpty()]
        [String]$Method,

        [Parameter(
            Position = 1,
            Mandatory = $false)]
        [String]$Component
    )

    BEGIN {
        $Results = New-Object System.Collections.Generic.List[System.Object]
        function Get-ParamOption {
            param (
                $Path,
                $Component
            )
            
            $Path = ([regex]::Replace($Path, "^$Component/", '')) -replace '^/', '' # Simplify path
            $Pattern = '\{([^}]+)\}' # Match text within {}

            # replace {param} with PARAM
            $CapParam = [regex]::Replace(
                $Path,
                $Pattern,
                {
                    param($match)
                    $param = $match.Groups[1].Value.ToUpper()
                    return $param
                }
            )

            $Split = $CapParam -split '/'

            if ( $CapParam -match $Component ) {
                return 'all'
            } elseif ( ($Split[0] -match $Split[1]) -and (-not $Split[2]) ) {
                return $Split[0].ToUpper()
            } else {
                return $CapParam
            }
        }
        $PrivatePath = Join-Path -Path (Split-Path $PSScriptRoot) -ChildPath Private
    }

    PROCESS {
        $Swagger = Get-Content $PrivatePath\swagger.json | ConvertFrom-Json -AsHashtable
        foreach ( $Path in $Swagger.paths.GetEnumerator() ) {
            if ( $Path.Value.Keys -contains $Method ) {

                $ComponentPath = $Path.Name -split '/'
                $_Component = $ComponentPath[1]
                $_URL = [regex]::Replace($Path.Key, "^/", '')
                $_Option = (Get-ParamOption -Path $_URL -Component $_Component)

                if ( [String]::IsNullOrEmpty($Component) -or ($Component -eq $_Component) ) {
                    $Results.Add(
                        [PSCustomObject]@{
                            API       = 'JSSResource';
                            Component = $_Component;
                            URL       = $_URL;
                            Option    = $_Option;
                        }
                    )
                }
            }
        }
        Clear-Variable -Name Swagger
    
        $Schema  = Get-Content $PrivatePath\schema.json | ConvertFrom-Json -AsHashtable
        foreach ( $Path in $Schema.paths.GetEnumerator() ) {
            if ( $Path.Value.Keys -contains $Method ) {

                $ComponentPath = $Path.Name -split '/'
                $_API = $ComponentPath[1]
                $_Component = $ComponentPath[2]
                $_URL = [regex]::Replace($Path.Key, "/$_API/", '')
                $_Option = (Get-ParamOption -Path $_URL -Component $_Component)

                if ( [String]::IsNullOrEmpty($Component) -or ($Component -eq $_Component) ) {
                    $Results.Add(
                        [PSCustomObject]@{
                            API       = "api/$_API";
                            Component = $_Component;
                            URL       = $_URL;
                            Option    = $_Option;
                        }
                    )
                }
            }
        }
        Clear-Variable -Name Schema
    
        if ( $Component ) {
            return $Results | Where-Object { $_.Component -notin @($null,'','{id}')} | Group-Object Option | ForEach-Object {$_.Group | Select-Object -Last 1}
        } else {
            return $Results | Where-Object { $_.Component -notin @($null,'','{id}')}
        }

    }

}