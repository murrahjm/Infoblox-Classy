---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# New-IBExtensibleAttributeDefinition

## SYNOPSIS
New-IBExtensibleAttributeDefinition creates an extensible attribute definition in the Infoblox database.

## SYNTAX

```
New-IBExtensibleAttributeDefinition [[-Gridmaster] <String>] [[-Credential] <PSCredential>] [-Name] <String>
 [-Type] <String> [[-DefaultValue] <String>] [[-Comment] <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
New-IBExtensibleAttributeDefinition creates an extensible attribute definition in the Infoblox database. 
This can be used as a reference for assigning extensible attributes to other objects.

## EXAMPLES

###  EXAMPLE 1 
```
New-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -Name Site -Type String -defaultValue CORP
```

This example creates an extensible attribute definition for assigned a site attribute to an object.

## PARAMETERS

### -Gridmaster
The fully qualified domain name of the Infoblox gridmaster. 
SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
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

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The Name of the new extensible attribute definition.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
The type definition for the extensible attribute. 
This defines the type of data that can be provided as a value when assigning an extensible attribute to an object.
Valid values are:
    â€¢DATE
    â€¢EMAIL
    â€¢ENUM
    â€¢INTEGER
    â€¢STRING
    â€¢URL

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DefaultValue
The default value to assign to the extensible attribute if no value is selected. 
This applies when assigning an extensible attribute to an object.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Comment
Optional comment field for the object. 
Can be used for notation and keyword searching by Get- cmdlets.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: None
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

### System.String
IB_ReferenceObject

## OUTPUTS

### IB_ExtAttrsDef

## NOTES

## RELATED LINKS

