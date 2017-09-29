---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# New-IBNetwork

## SYNOPSIS
New-IBNetwork creates an object of type DNSARecord in the Infoblox database.

## SYNTAX

```
New-IBNetwork [[-Gridmaster] <String>] [[-Credential] <PSCredential>] [-Network] <String>
 [[-NetworkView] <String>] [[-Comment] <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
New-IBNetwork creates an object of type DNSARecord in the Infoblox database. 
If creation is successful an object of type IB_DNSARecord is returned.

## EXAMPLES

###  EXAMPLE 1 
```
New-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -Network '10.0.0.0/8' -networkview default -comment 'new network'
```

This example creates a new network for 10.0.0.0 in the default view

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

### -Network
The IP address of the network to create in CIDR format

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

### -NetworkView
The Infoblox network view to create the network in. 
The provided value must match a valid view on the Infoblox. 
If no view is provided the default network view is used.

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

### -Comment
Optional comment field for the network. 
Can be used for notation and keyword searching by Get- cmdlets.

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

### IB_Network

## NOTES

## RELATED LINKS

