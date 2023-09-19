# JamfPSPro
[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PowerShell-6+-purple.svg)](https://github.com/PowerShell/PowerShell) ![Cross Platform](https://img.shields.io/badge/platform-windows%20%7C%20macos%20%7C%20linux-lightgrey) [![License][license-badge]](LICENSE)

![Build Status Windows PowerShell Core](https://github.com/TrustyTristan/JamfPSPro/workflows/ActionsTest-Windows-pwsh-Build/badge.svg?branch=master) \
![Build Status Linux](https://github.com/TrustyTristan/JamfPSPro/workflows/ActionsTest-Linux-Build/badge.svg?branch=master) \
![Build Status MacOS](https://github.com/TrustyTristan/JamfPSPro/workflows/ActionsTest-MacOS-Build/badge.svg?branch=master)

[license-badge]: https://img.shields.io/github/license/TrustyTristan/JamfPSPro

## Description

JamfPSPro is a PowerShell module that aims to bring cli tools for the Jamf API, can use both Classic API and Jamf Pro API

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
PS > Get-Jamf -Component computers -Path 'computers/name/{name}' -Params 'macbookpro'

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
Get data from Jamf Pro

### [New-Jamf](New-Jamf.md)
Sets/Post data from Jamf Pro

### [Remove-Jamf](Remove-Jamf.md)
Removes data from Jamf Pro

### [Set-Jamf](Set-Jamf.md)
Sets/Post data from Jamf Pro

## To Do

 - Get schema... would ideally get the schema for post/put in PSObject format.

## Contributing

If you'd like to contribute to JamfPSPro, please see the [contribution guidelines](.github/CONTRIBUTING.md).

## License

JamfPSPro is licensed under the [MIT license](LICENSE).

## Author

Tristan Brazier