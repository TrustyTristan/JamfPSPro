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

    $Results = New-Object System.Collections.Generic.List[System.Object]
    $Swagger = Get-Content $PSScriptRoot\swagger.json | ConvertFrom-Json -AsHashtable
    foreach ( $Path in $Swagger.paths.GetEnumerator() ) {
        if ( $Path.Value.Keys -contains $Method ) {
            $ComponentPath = $Path.Name -split '/'
            $_Component = $ComponentPath[1]
            $_URL = [regex]::Replace($Path.Key, "^/", '')
            if ( [String]::IsNullOrEmpty($Component) -or ($Component -eq $_Component) ) {
                $Results.Add(
                    [PSCustomObject]@{
                        API       = 'JSSResource';
                        Component = $_Component;
                        URL       = $_URL;
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
            if ( [String]::IsNullOrEmpty($Component) -or ($Component -eq $_Component) ) {
                $Results.Add(
                    [PSCustomObject]@{
                        API       = "api/$_API";
                        Component = $_Component;
                        URL       = $_URL;
                    }
                )
            }
        }
    }
    Clear-Variable -Name Schema

    return $Results | Group-Object URL | ForEach-Object {$_.Group | Select-Object -Last 1} 

}