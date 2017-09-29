---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# New-IBDNSZone

## SYNOPSIS
New-IBDNSZone creates an object of type DNSARecord in the Infoblox database.

## SYNTAX

```
New-IBDNSZone [[-Gridmaster] <String>] [[-Credential] <PSCredential>] [-FQDN] <String> [[-ZoneFormat] <String>]
 [[-View] <String>] [[-Comment] <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
New-IBDNSZone creates an object of type DNSARecord in the Infoblox database. 
If creation is successful an object of type IB_DNSARecord is returned.

## EXAMPLES

###  EXAMPLE 1 
```
New-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -zone domain.com -zoneformat Forward -comment 'new zone'
```

This example creates a forward-lookup dns zone in the default view

###  EXAMPLE 2 
```
New-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential  -zoneformat IPV4 -fqdn 10.in-addr-arpa
```

This example creates a reverse lookup zone for the 10.0.0.0 network in the default dns view

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

### -FQDN
The fully qualified name of the zone to create. 
This should be a valid FQDN for the zone that is to be created.

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

### -ZoneFormat
The format of the zone to be created.
The default value is Forward. 
Valid Values are:
       â€¢FORWARD
       â€¢IPV4
       â€¢IPV6

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
The Infoblox view to create the zone in. 
The provided value must match a valid view on the Infoblox. 
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
Optional comment field for the dns zone. 
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

## OUTPUTS

### IB_ZoneAuth

## NOTES

## RELATED LINKS

