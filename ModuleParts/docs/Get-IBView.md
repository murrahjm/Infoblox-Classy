---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Get-IBView

## SYNOPSIS
Get-IBView retreives objects of type View or network_view from the Infoblox database.

## SYNTAX

### byQuery (Default)
```
Get-IBView [-Gridmaster <String>] [-Credential <PSCredential>] [-Name <String>] [-Comment <String>]
 [-ExtAttributeQuery <String>] [-Strict] [-IsDefault <String>] [-MaxResults <Int32>] -Type <String>
```

### byRef
```
Get-IBView [-Gridmaster <String>] [-Credential <PSCredential>] -_Ref <String>
```

## DESCRIPTION
Get-IBView retreives objects of type view or network_view from the Infoblox database. 
Parameters allow searching by Name, Comment or status as default. 
Search can target either DNS View or Network view, not both. 
Also allows retrieving a specific record by reference string. 
Returned object is of class type IB_View or IB_NetworkView.

## EXAMPLES

###  EXAMPLE 1 
```
Get-IBView -Gridmaster $Gridmaster -Credential $Credential Type DNSView -IsDefault $True
```

This example retrieves the dns view specified as default.

###  EXAMPLE 2 
```
Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -comment 'default'
```

This example retrieves any network views with the word 'default' in the comment

###  EXAMPLE 3 
```
Get-IBView -Gridmaster $Gridmaster -Credential $Credential -_Ref 'networkview/ZGdzLm5ldHdvamtfdmlldyQw:Default/true'
```

This example retrieves the single view with the assigned reference string

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
The view name to search for. 
Can be full or partial name match depending on use of the -Strict switch

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
A string to search for in the comment field of the view. 
Will return any view with the matching string anywhere in the comment field. 
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

### -IsDefault
Search for views based on whether they are default or not. 
If parameter is not specified both types will be returned.

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

### -MaxResults
The maximum number of results to return from the query. 
A positive value will truncate the results at the specified number. 
A negative value will throw an error if the query returns more than the specified number.

```yaml
Type: Int32
Parameter Sets: byQuery
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Determines which class of object to search for. 
DNSView searches for IB_View objects, where NetworkView searches for IB_Networkview objects.

```yaml
Type: String
Parameter Sets: byQuery
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -_Ref
The unique reference string representing the view. 
String is in format \<recordtype\>/\<uniqueString\>:\<Name\>/\<isDefault\>. 
Value is assigned by the Infoblox appliance and returned with and find- or get- command.

```yaml
Type: String
Parameter Sets: byRef
Aliases: 

Required: True
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

### IB_View
IB_NetworkView

## NOTES

## RELATED LINKS

