---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Set-IBFixedAddress

## SYNOPSIS
Set-IBFixedAddress modifies properties of an existing fixed address in the Infoblox database.

## SYNTAX

### byObject (Default)
```
Set-IBFixedAddress -Record <IB_FixedAddress[]> [-Name <String>] [-Comment <String>] [-MAC <String>] [-Passthru]
 [-WhatIf] [-Confirm]
```

### byRef
```
Set-IBFixedAddress [-Gridmaster <String>] [-Credential <PSCredential>] -_Ref <String> [-Name <String>]
 [-Comment <String>] [-MAC <String>] [-Passthru] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Set-IBFixedAddress modifies properties of an existing fixed address in the Infoblox database. 
Valid IB_FixedAddress objects can be passed through the pipeline for modification. 
A valid reference string can also be specified. 
On a successful edit no value is returned unless the -Passthru switch is used.

## EXAMPLES

###  EXAMPLE 1 
```
Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBFixedAddress -comment 'new comment'
```

This example retrieves all fixed addresses with a comment of 'old comment' and replaces it with 'new comment'

###  EXAMPLE 2 
```
Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -Name testrecord.domain.com | Set-IBFixedAddress -Name testrecord2.domain.com -comment 'new comment' -passthru
	Name      : testrecord2.domain.com
	IPAddress : 192.168.1.1
	Comment   : new comment
	MAC       : 00:00:00:00:00:00
	View      : default
	_ref      : fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:192.168.1.1/default
```

This example modifes the PTRDName and comment on the provided record and outputs the updated record definition

###  EXAMPLE 3 
```
Set-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -_ref fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:192.168.1.2/default -MAC '11:11:11:11:11:11' -Passthru
	Name      : testrecord2.domain.com
	IPAddress : 192.168.1.2
	Comment   : new record
	MAC       : 11:11:11:11:11:11
	View      : default
	_ref      : fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:192.168.1.2/default
```

This example finds the record based on the provided ref string and set the MAC address on the record

## PARAMETERS

### -Gridmaster
The fully qualified domain name of the Infoblox gridmaster. 
SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.

```yaml
Type: String
Parameter Sets: byRef
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Credential
Powershell credential object for use in authentication to the specified gridmaster. 
This username/password combination needs access to the WAPI interface.

```yaml
Type: PSCredential
Parameter Sets: byRef
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -_Ref
The unique reference string representing the DNS record. 
String is in format \<recordtype\>/\<uniqueString\>:\<Name\>/\<view\>. 
Value is assigned by the Infoblox appliance and returned with and find- or get- command.

```yaml
Type: String
Parameter Sets: byRef
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Record
An object of type IB_FixedAddress representing the DNS record. 
This parameter is typically for passing an object in from the pipeline, likely from Get-IBFixedAddress.

```yaml
Type: IB_FixedAddress[]
Parameter Sets: byObject
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
The hostname to set on the provided dns record.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: Unspecified
Accept pipeline input: False
Accept wildcard characters: False
```

### -Comment
The comment to set on the provided dns record. 
Can be used for notation and keyword searching by Get- cmdlets.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: Unspecified
Accept pipeline input: False
Accept wildcard characters: False
```

### -MAC
The MAC address to set on the record. 
Colon separated format of 00:00:00:00:00:00 is required.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 99:99:99:99:99:99
Accept pipeline input: False
Accept wildcard characters: False
```

### -Passthru
Switch parameter to return an IB_FixedAddress object with the new values after updating the Infoblox. 
The default behavior is to return nothing on successful record edit.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
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

