---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Get-IBDNSARecord

## SYNOPSIS
Get-IBDNSARecord retreives objects of type DNSARecord from the Infoblox database.

## SYNTAX

### byQuery (Default)
```
Get-IBDNSARecord [-Gridmaster <String>] [-Credential <PSCredential>] [-Name <String>] [-IPAddress <IPAddress>]
 [-View <String>] [-Zone <String>] [-Comment <String>] [-ExtAttributeQuery <String>] [-Strict]
 [-MaxResults <Int32>]
```

### byref
```
Get-IBDNSARecord [-Gridmaster <String>] [-Credential <PSCredential>] -_ref <String> [-MaxResults <Int32>]
```

## DESCRIPTION
Get-IBDNSARecord retreives objects of type DNSARecord from the Infoblox database. 
Parameters allow searching by Name, IPAddress, View, Zone or Comment  Also allows retrieving a specific record by reference string. 
Returned object is of class type DNSARecord.

## EXAMPLES

###  EXAMPLE 1 
```
Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress '192.168.101.1'
```

This example retrieves all DNS records with IP Address of 192.168.101.1

###  EXAMPLE 2 
```
Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict
```

This example retrieves all DNS records with the exact comment 'test comment'

###  EXAMPLE 3 
```
Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default'
```

This example retrieves the single DNS record with the assigned reference string

###  EXAMPLE 4 
```
Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -name Testrecord.domain.com | Remove-IBDNSARecord
```

This example retrieves the dns record with name testrecord.domain.com, and deletes it from the infoblox database.

###  EXAMPLE 5 
```
Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBDNSARecord -comment 'new comment'
```

This example retrieves all dns records with a comment of 'old comment' and replaces it with 'new comment'

###  EXAMPLE 6 
```
Get-IBDNSARecord -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'}
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

### -Name
The dns name to search for. 
Can be fqdn or partial name match depending on use of the -Strict switch

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

### -View
The Infoblox view to search for records in. 
The provided value must match a valid view on the Infoblox. 
Note that if the zone parameter is used for searching results are narrowed to a particular view. 
Otherwise, searches are performed across all views.

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

### -Zone
The DNS zone to search for records in. 
Note that specifying a zone will also restrict the searching to a specific view. 
The default view will be used if none is specified.

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
A string to search for in the comment field of the DNS record. 
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
A switch to specify whether the search of the name or comment field should be exact, or allow partial word searches or regular expression matching.

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
The unique reference string representing the DNS record. 
String is in format \<recordtype\>/\<uniqueString\>:\<Name\>/\<view\>. 
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

### IB_DNSARecord

## NOTES

## RELATED LINKS

