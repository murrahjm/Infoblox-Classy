---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Get-IBDNSZone

## SYNOPSIS
Get-IBDNSZone retreives objects of type DNSZone from the Infoblox database.

## SYNTAX

### byQuery (Default)
```
Get-IBDNSZone [-Gridmaster <String>] [-Credential <PSCredential>] [-FQDN <String>] [-ZoneFormat <String>]
 [-View <String>] [-Comment <String>] [-ExtAttributeQuery <String>] [-Strict] [-MaxResults <Int32>]
```

### byref
```
Get-IBDNSZone [-Gridmaster <String>] [-Credential <PSCredential>] -_ref <String> [-MaxResults <Int32>]
```

## DESCRIPTION
Get-IBDNSZone retreives objects of type DNSZone from the Infoblox database. 
Parameters allow searching by DNSZone, DNSZone view or comment. 
Also allows retrieving a specific record by reference string. 
Returned object is of class type IB_DNSZone.

## EXAMPLES

###  EXAMPLE 1 
```
Get-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -DNSZone 192.168.101.0/24
```

This example retrieves the DNSZone object for subnet 192.168.101.0

###  EXAMPLE 2 
```
Get-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict
```

This example retrieves all DNSZone objects with the exact comment 'test comment'

###  EXAMPLE 3 
```
Get-IBDNSZone -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'}
```

This example retrieves all DNSZone objects with an extensible attribute defined for 'Site' with value of 'OldSite'

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

### -FQDN
The fully qualified name of the DNSZone to search for. 
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

### -ZoneFormat
The parent dns zone format to search by. 
Will return any DNSZones of this type. 
Valid values are:
       â€¢FORWARD
       â€¢IPV4
       â€¢IPV6

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

### -View
The Infoblox DNS view to search for zones in. 
The provided value must match a valid DNS view on the Infoblox.

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
A string to search for in the comment field of the dns zone record. 
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
The unique reference string representing the dns zone record. 
String is in format \<recordtype\>/\<uniqueString\>:\<IPAddress\>/\<DNSZoneview\>. 
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

### IB_DNSZone

## NOTES

## RELATED LINKS

