---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Get-IBExtensibleAttributeDefinition

## SYNOPSIS
Get-IBExtensibleAttributeDefinition retreives objects of type ExtAttrsDef from the Infoblox database.

## SYNTAX

### byQuery (Default)
```
Get-IBExtensibleAttributeDefinition [-Gridmaster <String>] [-Credential <PSCredential>] [-Name <String>]
 [-Type <String>] [-Comment <String>] [-Strict] [-MaxResults <Int32>]
```

### byref
```
Get-IBExtensibleAttributeDefinition [-Gridmaster <String>] [-Credential <PSCredential>] -_ref <String>
 [-MaxResults <Int32>]
```

## DESCRIPTION
Get-IBExtensibleAttributeDefinition retreives objects of type ExtAttrsDef from the Infoblox database. 
Extensible Attribute Definitions define the type of extensible attributes that can be attached to other records. 
Parameters allow searching by Name, type, and commentAlso allows retrieving a specific record by reference string. 
Returned object is of class type IB_ExtAttrsDef.

## EXAMPLES

###  EXAMPLE 1 
```
Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -Name 'Site'
```

This example retrieves all extensible attribute definitions with name beginning with the word Site

###  EXAMPLE 2 
```
Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict
```

This example retrieves all extensible attribute definitions with the exact comment 'test comment'

###  EXAMPLE 3 
```
Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -_Ref 'extensibleattributedef/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:extattr2'
```

This example retrieves the single extensible attribute definition with the assigned reference string

###  EXAMPLE 4 
```
Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -name extattr2 | Remove-IBRecord
```

This example retrieves the extensibleattributedefinition with name extattr2, and deletes it from the infoblox database. 
Note that some builtin extensible attributes cannot be deleted.

###  EXAMPLE 5 
```
Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBDNSARecord -comment 'new comment'
```

This example retrieves all extensible attribute definitions with a comment of 'old comment' and replaces it with 'new comment'

## PARAMETERS

### -Gridmaster
The fully qualified domain name of the Infoblox gridmaster. 
SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.

```yaml
Type: String
Parameter Sets: (All)
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
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The attribute definition name to search for. 
Can be full or partial name match depending on use of the -Strict switch

```yaml
Type: String
Parameter Sets: byQuery
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
The attribute value type to search for. 
Valid values are:
       â€¢DATE
       â€¢EMAIL
       â€¢ENUM
       â€¢INTEGER
       â€¢STRING
       â€¢URL

```yaml
Type: String
Parameter Sets: byQuery
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Comment
A string to search for in the comment field of the extensible attribute definition. 
Will return any record with the matching string anywhere in the comment field. 
Use with -Strict to match only the exact string in the comment.

```yaml
Type: String
Parameter Sets: byQuery
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Strict
A switch to specify whether the search of the name or comment field should be exact, or allow partial word searches or regular expression matching.

```yaml
Type: SwitchParameter
Parameter Sets: byQuery
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -_ref
The unique reference string representing the extensible attribute definition. 
String is in format \<recordtype\>/\<uniqueString\>:\<Name\>. 
Value is assigned by the Infoblox appliance and returned with and find- or get- command.

```yaml
Type: String
Parameter Sets: byref
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -MaxResults
The maximum number of results to return from the query. 
A positive value will truncate the results at the specified number. 
A negative value will throw an error if the query returns more than the specified number.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
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

