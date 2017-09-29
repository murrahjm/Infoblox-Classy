---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Remove-IBNetwork

## SYNOPSIS
Remove-IBNetwork removes the specified fixed Address record from the Infoblox database.

## SYNTAX

### byObject (Default)
```
Remove-IBNetwork -Record <IB_Network[]> [-WhatIf] [-Confirm]
```

### byRef
```
Remove-IBNetwork [-Gridmaster <String>] [-Credential <PSCredential>] -_Ref <String> [-WhatIf] [-Confirm]
```

## DESCRIPTION
Remove-IBNetwork removes the specified fixed address record from the Infoblox database. 
If deletion is successful the reference string of the deleted record is returned.

## EXAMPLES

###  EXAMPLE 1 
```
Remove-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -_Ref Network/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:192.168.1.1/default
```

This example deletes the fixed address record with the specified unique reference string. 
If successful, the reference string will be returned as output.

###  EXAMPLE 2 
```
Get-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -name Server01 | Remove-IBNetwork
```

This example retrieves the address reservation for Server01, and deletes it from the infoblox database. 
If successful, the reference string will be returned as output.

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
The unique reference string representing the record. 
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
An object of type IB_Network representing the record. 
This parameter is typically for passing an object in from the pipeline, likely from Get-IBNetwork.

```yaml
Type: IB_Network[]
Parameter Sets: byObject
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
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

