---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# New-IBFixedAddress

## SYNOPSIS
New-IBFixedAddress creates an object of type FixedAddress in the Infoblox database.

## SYNTAX

```
New-IBFixedAddress [[-Gridmaster] <String>] [[-Credential] <PSCredential>] [-IPAddress] <IPAddress>
 [[-MAC] <String>] [[-Name] <String>] [[-NetworkView] <String>] [[-Comment] <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
New-IBFixedAddress creates an object of type FixedAddress in the Infoblox database. 
If creation is successful an object of type IB_FixedAddress is returned.

## EXAMPLES

###  EXAMPLE 1 
```
New-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential Name Server01 -IPAddress 192.168.1.1

	Name        : Server01
	IPAddress   : 192.168.1.1
	Comment     :
	NetworkView : default
	MAC         : 00:00:00:00:00:00
	_ref        : fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:192.168.1.1/default
```

This example creates an IP reservation for 192.168.1.1 with no comment in the default view

###  EXAMPLE 2 
```
New-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -Name Server02.domain.com -IPAddress 192.168.1.2 -comment 'Reservation for Server02' -view default -MAC '11:11:11:11:11:11'

	Name      : Server02
	IPAddress : 192.168.1.2
	Comment   : Reservation for Server02
	View      : default
	MAC       : 11:11:11:11:11:11
	_ref      : fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:192.168.1.2/default
```

This example creates a dhcp reservation for 192.168.1.1 to the machine with MAC address 11:11:11:11:11:11

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

### -IPAddress
The IP Address for the fixedaddress assignment. 
Standard IPv4 notation applies, and a string value must be castable to an IPAddress object.

```yaml
Type: IPAddress
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MAC
The mac address for the fixed address reservation. 
Colon separated format of 00:00:00:00:00:00 is required. 
If the parameter is left blank or a MAC of 00:00:00:00:00:00 is used, the address is marked as type "reserved" in the infoblox database. 
If a non-zero mac address is provided the IP is reserved for the provided MAC, and the MAC must not be assigned to any other IP Address.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: 00:00:00:00:00:00
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The Name of the device to which the IP Address is reserved.

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

### -NetworkView
The Infoblox networkview to create the record in. 
The provided value must match a valid view on the Infoblox, and the subnet for the provided IPAddress must exist in the specified view. 
If no view is provided the default network view is used.

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

### -Comment
Optional comment field for the record. 
Can be used for notation and keyword searching by Get- cmdlets.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 7
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

### System.Net.IPAddress[]
System.String
IB_ReferenceObject

## OUTPUTS

### IB_FixedAddress

## NOTES

## RELATED LINKS

