---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# New-IBWebSession

## SYNOPSIS
Creates a re-usable web session with the supplied gridmaster and credential object.

## SYNTAX

```
New-IBWebSession [-Gridmaster] <String> [-Credential] <PSCredential> [[-WapiVersion] <String>]
```

## DESCRIPTION
Creates a re-usable web session with the supplied gridmaster and credential object. 
Once created, subsequent infoblox cmdlets will not require the gridmaster or credential parameters. 
Any cmdlet called with gridmaster and credential parameters will create call this cmdlet to create a web session, or update an existing one.

## EXAMPLES

###  EXAMPLE 1 
```
New-IBWebSession -Gridmaster gridmaster.domain.com -Credential $IBCred -wapiversion v2.2
```

Connects to the specified infoblox gridmaster and creates a re-usable web session for subsequent commands

## PARAMETERS

### -Gridmaster
The fully qualified domain name of the Infoblox gridmaster. 
SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Powershell credential object for use in authentication to the specified gridmaster. 
This username/password combination needs access to the WAPI interface.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WapiVersion
The version of web api to use when running commands against the infoblox appliance. 
This can affect the availability of certain features. 
Refer to Infoblox WAPI documentation for details.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### PSCredential
System.String

## OUTPUTS

## NOTES

## RELATED LINKS

