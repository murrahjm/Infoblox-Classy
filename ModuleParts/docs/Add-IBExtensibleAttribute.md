---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Add-IBExtensibleAttribute

## SYNOPSIS
Add-IBExtensibleAttribute adds or updates an extensible attribute to an existing infoblox record.

## SYNTAX

### byObject (Default)
```
Add-IBExtensibleAttribute -Record <Object[]> -EAName <String> -EAValue <String> [-Passthru] [-WhatIf]
 [-Confirm]
```

### byRef
```
Add-IBExtensibleAttribute [-Gridmaster <String>] [-Credential <PSCredential>] -_Ref <String> -EAName <String>
 -EAValue <String> [-Passthru] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Updates the provided infoblox record with an extensible attribute as defined in the ExtensibleAttributeDefinition of the Infoblox. 
If the extensible attribute specified already exists the value will be updated. 
A valid infoblox object must be provided either through parameter or pipeline. 
Pipeline supports multiple objects, to allow adding/updating the extensible attribute on multiple records at once.

## EXAMPLES

###  EXAMPLE 1 
```
Add-IBExtensibleAttribute -gridmaster $gridmaster -credential $credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default' -EAName Site -EAValue Corp
```

This example create a new extensible attribute for 'Site' with value of 'Corp' on the provided extensible attribute

###  EXAMPLE 2 
```
Get-DNSARecord  -gridmaster $gridmaster -credential $credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default' | `
```

Add-IBExtensibleAttribute -EAName Site -EAValue DR

This example retrieves the DNS record using Get-DNSARecord, then passes that object through the pipeline to Add-IBExtensibleAttribute, which updates the previously created extensible attribute 'Site' to value 'DR'

###  EXAMPLE 3 
```
Get-IBFixedAddress -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'} | Add-IBExtensibleAttribute -EAName Site -EAValue NewSite
```

This example retrieves all Fixed Address objects with a defined Extensible attribute of 'Site' with value 'OldSite' and updates the value to 'NewSite'

## PARAMETERS

### -Gridmaster
The fully qualified domain name of the Infoblox gridmaster. 
SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.

```yaml
Type: String
Parameter Sets: byRef
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Credential
Powershell credential object for use in authentication to the specified gridmaster. 
This username/password combination needs access to the WAPI interface.

```yaml
Type: PSCredential
Parameter Sets: byRef
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -_Ref
The unique reference string representing the Infoblox object. 
String is in format \<recordtype\>/\<uniqueString\>:\<Name\>/\<view\>. 
Value is assigned by the Infoblox appliance and returned with and find- or get- command.

```yaml
Type: String
Parameter Sets: byRef
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Record
An object of type IB_xxx representing the Infoblox object. 
This parameter is typically for passing an object in from the pipeline, likely from Get-DNSARecord.

```yaml
Type: Object[]
Parameter Sets: byObject
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -EAName
The name of the extensible attribute to add to the provided infoblox object. 
This extensible attribute must already be defined on the Infoblox.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EAValue
The value to set the specified extensible attribute to. 
Provided value must meet the data type criteria specified by the extensible attribute definition.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Passthru
Switch parameter to return the provided object(x) with the new values after updating the Infoblox. 
The default behavior is to return nothing on successful record edit.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

