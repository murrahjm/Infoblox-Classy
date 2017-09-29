---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Set-IBDNSPTRRecord

## SYNOPSIS
Set-IBDNSPTRRecord modifies properties of an existing DNS PTR Record in the Infoblox database.

## SYNTAX

### byObject (Default)
```
Set-IBDNSPTRRecord -Record <IB_DNSPTRRecord[]> [-PTRDName <String>] [-Comment <String>] [-TTL <UInt32>]
 [-ClearTTL] [-Passthru] [-WhatIf] [-Confirm]
```

### byRef
```
Set-IBDNSPTRRecord [-Gridmaster <String>] [-Credential <PSCredential>] -_Ref <String> [-PTRDName <String>]
 [-Comment <String>] [-TTL <UInt32>] [-ClearTTL] [-Passthru] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Set-IBDNSPTRRecord modifies properties of an existing DNS PTR Record in the Infoblox database. 
Valid IB_DNSPTRRecord objects can be passed through the pipeline for modification. 
A valid reference string can also be specified. 
On a successful edit no value is returned unless the -Passthru switch is used.

## EXAMPLES

###  EXAMPLE 1 
```
Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBDNSPTRRecord -comment 'new comment'
```

This example retrieves all dns ptr records with a comment of 'old comment' and replaces it with 'new comment'

###  EXAMPLE 2 
```
Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -PTRDName testrecord.domain.com | Set-IBDNSPTRRecord -PTRDName testrecord2.domain.com -comment 'new comment' -passthru

	Name      : testrecord2.domain.com
	IPAddress : 192.168.1.1
	Comment   : new comment
	View      : default
	TTL       : 0
	Use_TTL   : False
	_ref      : record:ptr/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:1.1.168.192.in-addr.arpa/default
```

This example modifes the PTRDName and comment on the provided record and outputs the updated record definition

###  EXAMPLE 3 
```
Set-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -_ref record:ptr/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:2.1.168.192.in-addr.arpa/default -ClearTTL -Passthru
	Name      : testrecord2.domain.com
	IPAddress : 192.168.1.2
	Comment   : new record
	View      : default
	TTL       : 0
	Use_TTL   : False
	_ref      : record:ptr/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:2.1.168.192.in-addr.arpa/default
```

This example finds the record based on the provided ref string and clears the record-specific TTL

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
The unique reference string representing the DNS record. 
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
An object of type IB_DNSPTRRecord representing the DNS record. 
This parameter is typically for passing an object in from the pipeline, likely from Get-IBDNSPTRRecord.

```yaml
Type: IB_DNSPTRRecord[]
Parameter Sets: byObject
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PTRDName
The resolvable hostname to set on the provided dns record.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: Unspecified
Accept pipeline input: False
Accept wildcard characters: False
```

### -Comment
The comment to set on the provided dns record. 
Can be used for notation and keyword searching by Get- cmdlets.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: Unspecified
Accept pipeline input: False
Accept wildcard characters: False
```

### -TTL
The record-specific TTL to set on the provided dns record. 
If the record is currently inheriting the TTL from the Grid, setting this value will also set the record to use the record-specific TTL

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 4294967295
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClearTTL
Switch parameter to remove any record-specific TTL and set the record to inherit from the Grid TTL

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

### -Passthru
Switch parameter to return an IB_DNSPTRRecord object with the new values after updating the Infoblox. 
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

### System.Net.IPAddress[]
System.String
IB_ReferenceObject

## OUTPUTS

### IB_DNSPTRRecord

## NOTES

## RELATED LINKS

