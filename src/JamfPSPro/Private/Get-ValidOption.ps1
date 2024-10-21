function Get-ValidOption {
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
    }

    PROCESS {
        $Swagger = Get-Content $PSScriptRoot\swagger.json | ConvertFrom-Json -AsHashtable
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
    
        $Schema  = Get-Content $PSScriptRoot\schema.json | ConvertFrom-Json -AsHashtable
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