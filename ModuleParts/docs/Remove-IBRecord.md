---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Remove-IBRecord

## SYNOPSIS
Remove-IBRecord removes the specified record from the Infoblox database.

## SYNTAX

```
Remove-IBRecord [[-Gridmaster] <String>] [[-Credential] <PSCredential>] [-_Ref] <String> [-WhatIf] [-Confirm]
```

## DESCRIPTION
Remove-IBRecord removes the specified record from the Infoblox database. 
This is a generalized version of the Remove-IBDNSARecord, Remove-IBDNSCNameRecord, etc. 
If deletion is successful the reference string of the deleted record is returned.

## EXAMPLES

###  EXAMPLE 1 
```
Remove-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_ref fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:192.168.1.1/default
```

This example deletes the fixed address record with the specified unique reference string. 
If successful, the reference string will be returned as output.

###  EXAMPLE 2 
```
Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -name Server01 | Remove-IBRecord
```

This example retrieves the address reservation for Server01, and deletes it from the infoblox database. 
If successful, the reference string will be returned as output.

###  EXAMPLE 3 
```
Remove-DNSInfobloxRecrd -Gridmaster $Gridmaster -Credential $Credential -_Ref record:a/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:testrecord.domain.com/default
```

This example deletes the DNS A record with the specified unique reference string. 
If successful, the reference string will be returned as output.

###  EXAMPLE 4 
```
Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -name Testrecord.domain.com | Remove-IBRecord
```

This example retrieves the dns record with name testrecord.domain.com, and deletes it from the infoblox database. 
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
The unique reference string representing the record. 
String is in format \<recordtype\>/\<uniqueString\>:\<Name\>/\<view\>. 
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

### System.Net.IPAddress[]
System.String
IB_ReferenceObject

## OUTPUTS

### IB_ReferenceObject

## NOTES

## RELATED LINKS

