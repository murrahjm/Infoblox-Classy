---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Find-IBRecord

## SYNOPSIS
Performs a full search of all Infoblox records matching the supplied value.

## SYNTAX

### globalSearchbyIP (Default)
```
Find-IBRecord [-Gridmaster <String>] [-Credential <PSCredential>] -IPAddress <IPAddress> [-MaxResults <Int32>]
```

### globalSearchbyString
```
Find-IBRecord [-Gridmaster <String>] [-Credential <PSCredential>] -SearchString <String> [-RecordType <String>]
 [-Strict] [-MaxResults <Int32>]
```

## DESCRIPTION
Performs a full search of all Infoblox records matching the supplied value. 
Returns defined objects for defined record types, and IB_ReferenceObjects for undefined types.

## EXAMPLES

###  EXAMPLE 1 
```
Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress '192.168.101.1'
```

This example retrieves all records with IP Address of 192.168.101.1

###  EXAMPLE 2 
```
Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString 'Test' -Strict
```

This example retrieves all records with the exact name 'Test'

###  EXAMPLE 3 
```
Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString 'Test' -RecordType 'record:a'
```

This example retrieves all dns a records that have 'test' in the name.

###  EXAMPLE 4 
```
Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -RecordType 'fixedaddress'
```

This example retrieves all fixedaddress records in the infoblox database

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

### -SearchString
A string to search for. 
Will return any record with the matching string anywhere in a matching string property. 
Use with -Strict to match only the exact string.

```yaml
Type: String
Parameter Sets: globalSearchbyString
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -RecordType
A filter for record searching. 
By default this cmdlet will search all record types. 
Use this parameter to search for only a specific record type. 
Can only be used with a string search. 
Note this parameter is not validated, so value must be the correct syntax for the infoblox to retrieve it.

```yaml
Type: String
Parameter Sets: globalSearchbyString
Aliases: 

Required: False
Position: Named
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### -Strict
A switch to specify whether the search of the Name field should be exact, or allow partial word searches or regular expression matching.

```yaml
Type: SwitchParameter
Parameter Sets: globalSearchbyString
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IPAddress
The IP Address to search for. 
Standard IPv4 notation applies, and a string value must be castable to an IPAddress object.

```yaml
Type: IPAddress
Parameter Sets: globalSearchbyIP
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
IB_DNSARecord
IB_DNSCNameRecord
IB_DNSPTRRecord
IB_ReferenceObject

## NOTES

## RELATED LINKS

