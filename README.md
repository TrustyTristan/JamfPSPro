# JamfPSPro
[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PowerShell-6+-purple.svg)](https://github.com/PowerShell/PowerShell) ![Cross Platform](https://img.shields.io/badge/platform-windows%20%7C%20macos%20%7C%20linux-lightgrey) [![License][license-badge]](LICENSE)

![Build Status Windows PowerShell Core](https://github.com/TrustyTristan/JamfPSPro/workflows/ActionsTest-Windows-pwsh-Build/badge.svg?branch=master) \
![Build Status Linux](https://github.com/TrustyTristan/JamfPSPro/workflows/ActionsTest-Linux-Build/badge.svg?branch=master) \
![Build Status MacOS](https://github.com/TrustyTristan/JamfPSPro/workflows/ActionsTest-MacOS-Build/badge.svg?branch=master)

[license-badge]: https://img.shields.io/github/license/TrustyTristan/JamfPSPro

## Description

JamfPSPro is a PowerShell module that aims to bring cli tools for the Jamf API, can use both Classic API and Jamf Pro API.

### Warning 

Most things seem to be working most of the time.

## Getting Started

### Installation

```powershell
# how to install JamfPSPro
Install-Module -Name JamfPSPro -Repository PSGallery -Scope CurrentUser
```

### Quick start

#### Example

```powershell
PS > Connect-JamfPro -Server server.jamfcloud.com -Credential $PSCredential

Account  Access     Server               Build     Expires
-------  ------     ------               -----     -------
UserName FullAccess trusty.jamfcloud.com 10.69.420 19/9/2023 4:20:00 pm
```

```powershell
PS > Get-Jamf -Component computers -Select NAME -Params 'macbookpro'

general                : @{...}
location               : @{...}
peripherals            : {}
hardware               : @{...}
certificates           : {...}
security               : @{...}
software               : @{...}
extension_attributes   : {...}
groups_accounts        : @{...}
iphones                : {}
configuration_profiles : {...}
```

## JamfPSPro Cmdlets
### [Connect-JamfPro](Connect-JamfPro.md)
Connects to JamfPro

### [Get-Jamf](Get-Jamf.md)
Retrieve data from Jamf Pro.

#### EXAMPLE
```
Get-Jamf -Component computers -Select all
Retrieves all available information for computers in Jamf Pro.
```

### [New-Jamf](New-Jamf.md)
Create a new resource or record in Jamf Pro.

#### EXAMPLE 1
```
New-Jamf -Component computers -Select 'ID/recalculate-smart-groups' -Param 420
Recalculates the smart group for the given computer id and then returns the count of
smart groups the computer falls into.
```

#### EXAMPLE 2
```
$NewScript = [PSCustomObject]@{
    'script' = @{
        'name' = 'Supa script';
        'category' = 'Testing';
        'info' = 'Script information';
        'notes' = 'Created 20230420';
        'priority' = 'Before';
        'parameters' = @{
                'parameter4' = 'Some input';
            }
        'os_requirements' = '10.15';
        'script_contents' = '#!/bin/
            echo "Are you there?'
        }
    }
New-Jamf -Component scripts -Select ID -Params 999 -Content $NewScript
Creates a script 'Supa script', an ID must be supplied but will use next ID.
```

### [Remove-Jamf](Remove-Jamf.md)
Remove an existing resource or record from Jamf Pro.

#### EXAMPLE
```
Remove-Jamf -Component computers -Select ID -Params 69
Removes the computer with the ID 69
```

### [Set-Jamf](Set-Jamf.md)
Update or modify an existing resource or record in Jamf Pro.

#### EXAMPLE 1
```
<name>Blazing Script</name></script>"
Set-Jamf -Component scripts -Select ID -Param 420 -Content $UpdatedScript
Changes the name of the script with the ID 420
```

#### EXAMPLE 2
```
$Update = [PSCustomObject]@{
    'computer_group' = @{
        'name' = 'The Plastics';
        }
    }
Set-Jamf -Component computergroups -Select ID -Param 69 -Content $Update
Changes the name of the computer group with the ID of 69
```

## To Do

 - Get schema... would ideally get the schema for post/put in PSObject format.

## Contributing

If you'd like to contribute to JamfPSPro, please see the [contribution guidelines](.github/CONTRIBUTING.md).

## License

JamfPSPro is licensed under the [MIT license](LICENSE).

## Author

Tristan Brazier