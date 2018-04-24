---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Set-IBView

## SYNOPSIS
Set-IBView modifies properties of an existing View or NetworkView object in the Infoblox database.

## SYNTAX

### byObject (Default)
```
Set-IBView -Record <Object[]> [-Name <String>] [-Comment <String>] [-Passthru] [-WhatIf] [-Confirm]
```

### byRef
```
Set-IBView [-Gridmaster <String>] [-Credential <PSCredential>] -_Ref <String> [-Name <String>]
 [-Comment <String>] [-Passthru] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Set-IBView modifies properties of an existing View or NetworkView object in the Infoblox database. 
Valid IB_View or IB_NetworkView objects can be passed through the pipeline for modification. 
A valid reference string can also be specified. 
On a successful edit no value is returned unless the -Passthru switch is used.

## EXAMPLES

###  EXAMPLE 1 
```
Get-IBView -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBView -comment 'new comment'
```

This example retrieves all View or NetworkView objects with a comment of 'old comment' and replaces it with 'new comment'

###  EXAMPLE 2 
```
Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Name view2 | Set-IBView -name view3 -comment 'new comment' -passthru
	Name      : view3
	Comment   : new comment
	is_default: false
	_ref      : view/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:view3/false
```

This example modifes the name and comment on the provided record and outputs the updated record definition

###  EXAMPLE 3 
```
Set-IBView -Gridmaster $Gridmaster -Credential $Credential -_ref networkview/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:networkview2/false -Passthru -comment $False
	Name      : networkview2
	Comment   : 
	is_default: False
	_ref      : networkview/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:networkview2/false
```

This example finds the record based on the provided ref string and clears the comment

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
The unique reference string representing the View or NetworkView object. 
String is in format \<recordtype\>/\<uniqueString\>:\<Name\>/\<defaultbool\>. 
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
An object of type IB_View or IB_NetworkView representing the View or NetworkView object. 
This parameter is typically for passing an object in from the pipeline, likely from Get-IBView.

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

### -Name
The name to set on the provided View or NetworkView object.

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

### -Comment
The comment to set on the provided View or NetworkView object. 
Can be used for notation and keyword searching by Get- cmdlets.

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

### -Passthru
Switch parameter to return an IB_View or IB_NetworkView object with the new values after updating the Infoblox. 
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

### System.String
IB_ReferenceObject

## OUTPUTS

### IB_View
   IB_NetworkView

## NOTES

## RELATED LINKS

