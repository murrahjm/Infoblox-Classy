### Current Build Status:
[![Build status](https://ci.appveyor.com/api/projects/status/xsbki1rrxo2nh3fy/branch/master?svg=true)](https://ci.appveyor.com/project/murrahjm/infoblox-classy)

## [Download from the Powershell Gallery](https://www.powershellgallery.com/packages/InfobloxCmdlets)

# Infoblox-Classy
Infoblox cmdlets for Posh 5.0 using classes

Powershell module project to interface with Infoblox REST API.  Makes use of new class definition features in powershell 5.0.  All of the REST interaction is done in the class definitions, with the cmdlet serving to validate input and provide for the user interface.  This is a work in progress, but since the REST API provides basic error handling (400 and 404), the cmdlets should do more validation of data to provide more meaningful errors.

The basic structure of the class definitions mirrors the REST API object definitions, with various methods also mirroring the REST API documentation.  Due to the nature of the class structure, the multiple class and cmdlet files cannot just be dot-sourced from a central module file.  All the files must be concatenated together into one large psm1 file to function.

Pester tests are performed against an infoblox appliance in Azure.  Appveyor build script provisions infoblox appliance in azure with AzureDeploy.json template, runs pester tests against appliance, then deletes the Azure resource group.

### v1.1 release notes:

Added support for REST web session.  Cmdlets add support for creating a web session on the first successful operation, and referencing that as the default if no alternate credentials are provided.
