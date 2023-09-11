# JamfPSPro
[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PowerShell-6+-purple.svg)](https://github.com/PowerShell/PowerShell) ![Cross Platform](https://img.shields.io/badge/platform-windows%20%7C%20macos%20%7C%20linux-lightgrey) [![License][license-badge]](LICENSE)

![Build Status Windows PowerShell Core](https://github.com/TrustyTristan/JamfPSPro/workflows/ActionsTest-Windows-pwsh-Build/badge.svg?branch=master)

![Build Status Linux](https://github.com/TrustyTristan/JamfPSPro/workflows/ActionsTest-Linux-Build/badge.svg?branch=master)

![Build Status MacOS](https://github.com/TrustyTristan/JamfPSPro/workflows/ActionsTest-MacOS-Build/badge.svg?branch=master)

[license-badge]: https://img.shields.io/github/license/TrustyTristan/JamfPSPro

## Warning 

This is in a very early state, could be many issues.
Get-Jamf should hopefully be working.
Have done a small amount of testing with Remove-Jamf and New-Jamf

## Description

JamfPSPro is a PowerShell module that aims to bring cli tools for the Jamf API, can use both Classic API and Jamf Pro API

## Getting Started

### Installation

```powershell
# how to install JamfPSPro
Install-Module -Name JamfPSPro -Repository PSGallery -Scope CurrentUser
```

### Quick start

#### Example

```powershell
Connect-JamfPro -Server server.jamfcloud.com -Credential $PSCredential
Get-Jamf -Component computers -Path computers
Get-Jamf -Component computers -Path 'computers/name/{name}' -Params 'macbookpro'
Get-Command -Module JamfPSPro

```
## JamfPSPro Cmdlets
[Cmdlets list](/docs/JamfPSPro.md)

## Contributing

If you'd like to contribute to JamfPSPro, please see the [contribution guidelines](.github/CONTRIBUTING.md).

## License

JamfPSPro is licensed under the [MIT license](LICENSE).

## Author

Tristan Brazier