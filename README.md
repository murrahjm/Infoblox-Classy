# Infoblox-Classy
Infoblox cmdlets for Posh 5.0 using classes

Powershell module project to interface with Infoblox REST API.  Makes use of new class definition features in powershell 5.0.  All of the REST interaction is done in the class definitions, with the cmdlet serving to validate input and provide for the user interface.  This is a work in progress, but since the REST API provides basic error handling (400 and 404), the cmdlets should do more validation of data to provide more meaningful errors.

The basic structure of the class definitions mirrors the REST API object definitions, with various methods also mirroring the REST API documentation.  Due to the nature of the class structure, the multiple class and cmdlet files cannot just be dot-sourced from a central module file.  All the files must be concatenated together into one large psm1 file to function.  

Pester tests are performed against an infoblox appliance in Azure.  Test script connects to azure and provisions appliance through the use of BuildTestEnvironment.ps1 and AzureDeploy.json.  Appliance dns name and admin credentials are passed back to main test script for use by cmdlets in pester tests.  Note that the test script does not destroy the environment after completion, that must be done manually if no longer needed.

### Current Build Status:
![Build Status](https://murrahjm.visualstudio.com/_apis/public/build/definitions/4b8783db-bcc0-43dd-9baf-23ac76f7e619/5/badge)