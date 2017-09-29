---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Remove-IBView

## SYNOPSIS
Remove-IBNetwork removes the specified view or networkview object from the Infoblox database.

## SYNTAX

```
Remove-IBView [[-Gridmaster] <String>] [[-Credential] <PSCredential>] [-_Ref] <String> [-WhatIf] [-Confirm]
```

## DESCRIPTION
Remove-IBNetwork removes the specified view or networkview object from the Infoblox database. 
If deletion is successful the reference string of the deleted object is returned.

## EXAMPLES

###  EXAMPLE 1 
```
Remove-IBview -Gridmaster $Gridmaster -Credential $Credential -_Ref Networkview/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:view2/false
```

This example deletes the networkview object with the specified unique reference string. 
If successful, the reference string will be returned as output.

###  EXAMPLE 2 
```
Get-IBView -Gridmaster $Gridmaster -Credential $Credential -name view2 | Remove-IBView
```

This example retrieves the dns view named view2, and deletes it from the infoblox database. 
If successful, the reference string will be returned as output.

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
Accept pipeline input: True (ByPropertyName)
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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -_Ref
The unique reference string representing the object. 
String is in format \<objecttype\>/\<uniqueString\>:\<Name\>/\<isdefaultBoolean\>. 
Value is assigned by the Infoblox appliance and returned with and find- or get- command.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### IB_ReferenceObject

## NOTES

## RELATED LINKS

