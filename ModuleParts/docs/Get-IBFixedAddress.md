---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Get-IBFixedAddress

## SYNOPSIS
Get-IBFixedAddress retreives objects of type FixedAddress from the Infoblox database.

## SYNTAX

### byQuery (Default)
```
Get-IBFixedAddress [-Gridmaster <String>] [-Credential <PSCredential>] [-IPAddress <IPAddress>] [-MAC <String>]
 [-NetworkView <String>] [-Comment <String>] [-ExtAttributeQuery <String>] [-Strict] [-MaxResults <Int32>]
```

### byref
```
Get-IBFixedAddress [-Gridmaster <String>] [-Credential <PSCredential>] -_ref <String> [-MaxResults <Int32>]
```

## DESCRIPTION
Get-IBFixedAddress retreives objects of type FixedAddress from the Infoblox database. 
Parameters allow searching by ip address, mac address, network view or comment. 
Also allows retrieving a specific record by reference string. 
Returned object is of class type FixedAddress.

## EXAMPLES

###  EXAMPLE 1 
```
Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -IPAddress '192.168.101.1'
```

This example retrieves all fixed address records with IP Address of 192.168.101.1

###  EXAMPLE 2 
```
Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict
```

This example retrieves all fixed address records with the exact comment 'test comment'

###  EXAMPLE 3 
```
Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -MAC '00:00:00:00:00:00' -comment 'Delete'
```

This example retrieves all fixed address records with a mac address of all zeroes and the word 'Delete' anywhere in the comment text.

###  EXAMPLE 4 
```
Get-IBFixedAddress -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'}
```

This example retrieves all dns records with an extensible attribute defined for 'Site' with value of 'OldSite'

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

### -IPAddress
The IP Address to search for. 
Standard IPv4 notation applies, and a string value must be castable to an IPAddress object.

```yaml
Type: IPAddress
Parameter Sets: byQuery
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MAC
The MAC address to search for. 
Colon separated format of 00:00:00:00:00:00 is required.

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

### System.Net.IPAddress[]
System.String
IB_ReferenceObject

## OUTPUTS

### IB_FixedAddress

## NOTES

## RELATED LINKS

