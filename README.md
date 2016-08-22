# Infoblox-Classy
Infoblox cmdlets for Posh 5.0 using classes

Powershell module project to interface with Infoblox REST API.  Makes use of new class definition features in powershell 5.0.  All of the REST interaction is done in the class definitions, with the cmdlet serving to validate input and provide for the user interface.  This is a work in progress, but since the REST API provides basic error handling (400 and 404), the cmdlets should do more validation of data to provide more meaningful errors.

The basic structure of the class definitions mirrors the REST API object definitions, with various methods also mirroring the REST API documentation.  Due to the nature of the class structure, the multiple class and cmdlet files cannot just be dot-sourced from a central module file.  All the files must be concatenated together into one large psm1 file to function.  

Pester tests are included with mocking functions to simulate and infoblox device.  More thorough testing should be done against an actual infoblox appliance, but the mocking functions provide basic validation.
