#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'JamfPSPro'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

InModuleScope 'JamfPSPro' {
    Describe 'ConvertTo-FQDN Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $script:TestInput = @(
                "https://example.domain.com/",
                "http://example.domain.com/",
                "example.domain.com"
            )
        } #beforeAll
        Context 'Converts input to FQDN' {
            It 'should return the expected results' {
                $ExpectedOutput = @(
                    "example.domain.com",
                    "example.domain.com",
                    "example.domain.com"
                )
                $ActualOutput = $TestInput | ConvertTo-FQDN
                $ActualOutput | Should -BeExactly $ExpectedOutput
            }
        }
        Context "Invalid input" {
            It "Throws an error for empty input" {
                { ConvertTo-FQDN @() } | Should -Throw
            }

            It "Throws an error for null input" {
                { ConvertTo-FQDN $null } | Should -Throw
            }
        }
    }
}