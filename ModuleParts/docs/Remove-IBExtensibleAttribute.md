---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Remove-IBExtensibleAttribute

## SYNOPSIS
Remove-IBExtensibleAttribute adds or updates an extensible attribute to an existing infoblox record.

## SYNTAX

### byObjectEAName (Default)
```
Remove-IBExtensibleAttribute -Record <Object[]> -EAName <String> [-Passthru] [-WhatIf] [-Confirm]
```

### byRefAll
```
Remove-IBExtensibleAttribute [-Gridmaster <String>] [-Credential <PSCredential>] -_Ref <String> [-RemoveAll]
 [-Passthru] [-WhatIf] [-Confirm]
```

### byRefEAName
```
Remove-IBExtensibleAttribute [-Gridmaster <String>] [-Credential <PSCredential>] -_Ref <String>
 -EAName <String> [-Passthru] [-WhatIf] [-Confirm]
```

### byObjectAll
```
Remove-IBExtensibleAttribute -Record <Object[]> [-RemoveAll] [-Passthru] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Removes the specified extensible attribute from the provided Infoblox object. 
A valid infoblox object must be provided either through parameter or pipeline. 
Pipeline supports multiple objects, to allow adding/updating the extensible attribute on multiple records at once.

## EXAMPLES

###  EXAMPLE 1 
```
Remove-IBExtensibleAttribute -gridmaster $gridmaster -credential $credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default' -EAName Site
```

This example removes the extensible attribute 'site' from the specified infoblox object.

###  EXAMPLE 2 
```
Get-IBDNSARecord  -gridmaster $gridmaster -credential $credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default' | `
```

Remove-IBExtensibleAttribute -EAName Site

This example retrieves the DNS record using Get-IBDNSARecord, then passes that object through the pipeline to Remove-IBExtensibleAttribute, which removes the extensible attribute 'Site' from the object.

###  EXAMPLE 3 
```
Get-IBFixedAddress -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'} | Remove-IBExtensibleAttribute -RemoveAll
```

This example retrieves all Fixed Address objects with a defined Extensible attribute of 'Site' with value 'OldSite' and removes all extensible attributes defined on the objects.

## PARAMETERS

### -Gridmaster
The fully qualified domain name of the Infoblox gridmaster. 
SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.

```yaml
Type: String
Parameter Sets: byRefAll, byRefEAName
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Powershell credential object for use in authentication to the specified gridmaster. 
This username/password combination needs access to the WAPI interface.

```yaml
Type: PSCredential
Parameter Sets: byRefAll, byRefEAName
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -_Ref
The unique reference string representing the Infoblox object. 
String is in format \<recordtype\>/\<uniqueString\>:\<Name\>/\<view\>. 
Value is assigned by the Infoblox appliance and returned with and find- or get- command.

```yaml
Type: String
Parameter Sets: byRefAll, byRefEAName
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Record
An object of type IB_xxx representing the Infoblox object. 
This parameter is typically for passing an object in from the pipeline, likely from Get-IBDNSARecord.

```yaml
Type: Object[]
Parameter Sets: byObjectEAName, byObjectAll
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -EAName
The name of the extensible attribute to remove from the provided infoblox object.

```yaml
Type: String
Parameter Sets: byObjectEAName, byRefEAName
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveAll
Switch parameter to remove all extensible attributes from the provided infoblox object(s).

```yaml
Type: SwitchParameter
Parameter Sets: byRefAll, byObjectAll
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Passthru
Switch parameter to return the provided object(s) with the new values after updating the Infoblox. 
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

