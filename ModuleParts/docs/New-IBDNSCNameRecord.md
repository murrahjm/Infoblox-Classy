---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# New-IBDNSCNameRecord

## SYNOPSIS
New-IBDNSCNameRecord creates an object of type DNSCNameRecord in the Infoblox database.

## SYNTAX

```
New-IBDNSCNameRecord [[-Gridmaster] <String>] [[-Credential] <PSCredential>] [[-Name] <String>]
 [[-Canonical] <String>] [[-View] <String>] [[-Comment] <String>] [[-TTL] <UInt32>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
New-IBDNSCNameRecord creates an object of type DNSCNameRecord in the Infoblox database. 
If creation is successful an object of type IB_DNSCNameRecord is returned.

## EXAMPLES

###  EXAMPLE 1 
```
New-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Name testalias.domain.com -Canonical testrecord.domain.com

	Name      : testalias.domain.com
	Canonical : testrecord.domain.com
	Comment   :
	View      : default
	TTL       : 0
	Use_TTL   : False
	_ref      : record:cname/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:testalias.domain.com/default
```

This example creates a dns record with no comment, in the default view, and no record-specific TTL

###  EXAMPLE 2 
```
New-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Name Testalias2.domain.com -canonical testrecord2.domain.com -comment 'new record' -view default -ttl 100

	Name      : testalias2.domain.com
	Canonical : testrecord2.domain.com
	Comment   : new record
	View      : default
	TTL       : 100
	Use_TTL   : True
	_ref      : record:cname/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:testalias2.domain.com/default
```

This example creates a dns record with a comment, in the default view, with a TTL of 100 to override the grid default

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
The Name of the new dns record. 
This should be a valid FQDN, and the infoblox should be authoritative for the provided zone.

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

### -Canonical
The 'pointer' or canonical value of the new dns record. 
Should be a valid FQDN, but infoblox does not need any control or authority of the zone

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -View
The Infoblox view to create the record in. 
The provided value must match a valid view on the Infoblox, and the zone specified in the Name parameter must be present in the specified view. 
If no view is provided the default DNS view is used.

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
Optional comment field for the dns record. 
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

### -TTL
Optional parameter to specify a record-specific TTL. 
If not specified the record inherits the Grid TTL

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases: 

Required: False
Position: 7
Default value: 4294967295
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

### IB_DNSCNameRecord

## NOTES

## RELATED LINKS

