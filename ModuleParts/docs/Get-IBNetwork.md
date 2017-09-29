---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Get-IBNetwork

## SYNOPSIS
Get-IBNetwork retreives objects of type Network from the Infoblox database.

## SYNTAX

### byQuery (Default)
```
Get-IBNetwork [-Gridmaster <String>] [-Credential <PSCredential>] [-Network <String>]
 [-NetworkContainer <String>] [-NetworkView <String>] [-Comment <String>] [-ExtAttributeQuery <String>]
 [-Strict] [-MaxResults <Int32>]
```

### byref
```
Get-IBNetwork [-Gridmaster <String>] [-Credential <PSCredential>] -_ref <String> [-MaxResults <Int32>]
```

## DESCRIPTION
Get-IBNetwork retreives objects of type Network from the Infoblox database. 
Parameters allow searching by network, network view or comment. 
Also allows retrieving a specific record by reference string. 
Returned object is of class type IB_Network.

## EXAMPLES

###  EXAMPLE 1 
```
Get-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -network 192.168.101.0/24
```

This example retrieves the network object for subnet 192.168.101.0

###  EXAMPLE 2 
```
Get-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict
```

This example retrieves all network objects with the exact comment 'test comment'

###  EXAMPLE 3 
```
Get-IBNetwork -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'}
```

This example retrieves all network objects with an extensible attribute defined for 'Site' with value of 'OldSite'

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

### -Network
The IP Network to search for. 
Standard IPv4 or CIDR notation applies. 
Partial matches are supported.

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

### -NetworkContainer
The parent network to search by. 
Will return any networks that are subnets of this value. 
i.e.
query for 192.168.0.0/16 will return 192.168.1.0/24, 192.168.2.0/24, etc.

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

### -NetworkView
The Infoblox network view to search for records in. 
The provided value must match a valid network view on the Infoblox.

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
A string to search for in the comment field of the Fixed Address record. 
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

### -ExtAttributeQuery
{{Fill ExtAttributeQuery Description}}

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
A switch to specify whether the search of the comment field should be exact, or allow partial word searches or regular expression matching.

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
The unique reference string representing the fixed address record. 
String is in format \<recordtype\>/\<uniqueString\>:\<IPAddress\>/\<networkview\>. 
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

### IB_Network

## NOTES

## RELATED LINKS

