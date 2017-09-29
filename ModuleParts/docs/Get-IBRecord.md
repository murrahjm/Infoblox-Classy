---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Get-IBRecord

## SYNOPSIS
Get-IBRecord retreives objects from the Infoblox database.

## SYNTAX

```
Get-IBRecord [[-Gridmaster] <String>] [[-Credential] <PSCredential>] [-_Ref] <String>
```

## DESCRIPTION
Get-IBRecord retreives objects from the Infoblox database. 
Queries the Infoblox database for records matching the provided reference string. 
Returns defined objects for class-defined record types, and IB_ReferenceObjects for undefined types.

## EXAMPLES

###  EXAMPLE 1 
```
Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default'

	Name	  : testrecord.domain.com
	IPAddress : 192.168.1.1
	Comment   : 'test record'
	View      : default
	TTL       : 1200
	Use_TTL   : True
	_ref      : record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default
```
This example retrieves the single DNS record with the assigned reference string

###  EXAMPLE 2 
```
Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref 'network/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:192.168.1.0/default'

	_ref      : network/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:192.168.1.0/default
```
This example returns an IB_ReferenceObject object for the undefined object type. 
The object exists on the infoblox and is valid, but no class is defined for it in the cmdlet class definition.

###  EXAMPLE 3 
```
Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -name Testrecord.domain.com | Remove-IBDNSARecord
```

This example retrieves the dns record with name testrecord.domain.com, and deletes it from the infoblox database.

###  EXAMPLE 4 
```
Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBDNSARecord -comment 'new comment'
```

This example retrieves all dns records with a comment of 'old comment' and replaces it with 'new comment'

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
Accept pipeline input: True (ByPropertyName)
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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -_Ref
The unique reference string representing the record. 
String is in format \<recordtype\>/\<uniqueString\>:\<Name\>/\<view\>. 
Value is assigned by the Infoblox appliance and returned with and find- or get- command.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

### System.Net.IPAddress[]
System.String
IB_ReferenceObject

## OUTPUTS

### object

## NOTES

## RELATED LINKS

