---
external help file: InfobloxCmdlets-help.xml
Module Name: infobloxcmdlets
online version: 
schema: 2.0.0
---

# Test-IBGridmaster

## SYNOPSIS
Tests for connection to accessible Infoblox Gridmaster.

## SYNTAX

```
Test-IBGridmaster [-Gridmaster] <String> [-Quiet]
```

## DESCRIPTION
Tests for connection to accessible Infoblox Gridmaster. 
Connects to provided gridmaster FQDN over SSL and verifies gridmaster functionality.

## EXAMPLES

###  EXAMPLE 1 
```
Test-IBGridmaster -Gridmaster testGM.domain.com
```

This example tests the connection to testGM.domain.com and returns a True or False value based on availability.

## PARAMETERS

### -Gridmaster
The fully qualified domain name of the Infoblox gridmaster. 
SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quiet
Switch parameter to specify whether error output should be provided with more detail about the connection errors.

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

## INPUTS

### System.String

## OUTPUTS

### Bool

## NOTES

## RELATED LINKS

