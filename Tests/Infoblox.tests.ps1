#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests. 
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#
$ScriptLocation = Split-Path -parent $MyInvocation.MyCommand.Definition
$Scripts = Get-ChildItem "$ScriptLocation\ModuleParts" -Filter *.ps1 -Recurse
$Scripts | get-content | out-file -FilePath "$($env:TEMP)\epd-infoblox.ps1"
. "$($env:TEMP)\epd-infoblox.ps1"
remove-item "$($env:TEMP)\epd-infoblox.ps1"
$scripts | %{. $_.FullName}
. "$scriptlocation\TestHelperFunctions.ps1"
$Gridmaster = 'FakeInfobloxGridmaster'
$Username = 'pass'
$password = 'pass' | ConvertTo-SecureString -Force -AsPlainText
$Credential = New-Object System.Management.Automation.PSCredential ($Username,$password)
#
Describe "IB_DNSARecord Tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Put'} {
		Mock-InfobloxPut -uri $Uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Post'} {
		Mock-InfobloxPost -uri $uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Delete'} {
	$uri | Mock-InfobloxDelete
	}
	Context "Get Method" {

		It "Throws error with invalid credential object" {
			{[IB_DNSARecord]::Get($Gridmaster,'notacredential','refstring')} | should throw
			{[IB_DNSARecord]::Get($Gridmaster,'notacredential','name','1.1.1.1','comment','domain.com','view',$False,0)} | should throw
		}
		It "Throws error with invalid IP Address object" {
			{[IB_DNSARecord]::Get($Gridmaster,$Credential,'name','notanipaddress','comment','zone','view',$False,0)} | should throw
		}
		It "Throws error with invalid boolean object" {
			{[IB_DNSARecord]::Get($Gridmaster,$Credential,'name','1.1.1.1','comment','zone','view','notabool',0)} | should throw
		}
		It "Throws error with invalid integer object" {
			{[IB_DNSARecord]::Get($gridmaster,$Credential,'name','1.1.1.1','comment','zone','view',$False,'notanint')} | should throw
		}
		It "Throws error with less than 3 parameters" {
			{[IB_DNSARecord]::Get($gridmaster,$Credential)} | should throw
		}
		It "Throws error with more than 3 but less than 10 parameters" {
			{[IB_DNSARecord]::Get($gridmaster,$Credential,'param1','param2')} | should throw
		}
		It "Throws errror with more than 10 parameters" {
			{[IB_DNSARecord]::Get($Gridmaster,$Credential,'name','1.1.1.1','comment','extattrib','zone','view',$False,0,'param10')} | should throw
		}
		It "returns A record from ref query" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			$TestRecord.GetType().Name | should be 'IB_DNSARecord'
			$TestRecord.Name | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "Returns A record from strict name query" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,'testrecord.domain.com',$Null,$Null,$Null,$Null,$Null,$True,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.Name | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "returns multiple A records from non-strict name query" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,'testrecord',$Null,$Null,$Null,$Null,$Null,$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.count | should be 3
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
			$TestRecord[0].Name | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
			$TestRecord[1].Name | should be 'testrecord3.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.1.1.1'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
			#
			$TestRecord[2].GetType().Name | should be 'IB_DNSARecord'
			$TestRecord[2].Name | should be 'testrecord2.domain.com'
			$TestRecord[2].View | should be 'view3'
			$TestRecord[2].IPAddress | should be '2.2.2.2'
			$TestRecord[2].Comment | should benullorempty
			$TestRecord[2]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3'
			$TestRecord[2].TTL | should be 0
			$TestRecord[2].Use_TTL | should be $False

		}
		It "Returns multiple A records from zone query" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,'domain.com',$Null,$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.count | should be 3
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
			$TestRecord[0].Name | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
			$TestRecord[1].Name | should be 'testrecord3.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.1.1.1'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
			#
			$TestRecord[2].GetType().Name | should be 'IB_DNSARecord'
			$TestRecord[2].Name | should be 'testrecord2.domain.com'
			$TestRecord[2].View | should be 'view3'
			$TestRecord[2].IPAddress | should be '2.2.2.2'
			$TestRecord[2].Comment | should benullorempty
			$TestRecord[2]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3'
			$TestRecord[2].TTL | should be 0
			$TestRecord[2].Use_TTL | should be $False

		}
		It "Returns multiple A records from IP Address query" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,$Null,'1.1.1.1',$Null,$Null,$Null,$Null,$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.count | should be 2
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
			$TestRecord[0].Name | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
			$TestRecord[1].Name | should be 'testrecord3.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.1.1.1'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True

		}
		It "Returns A record from view query" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$Null,'view3',$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.Name | should be 'testrecord2.domain.com'
			$TestRecord.View | should be 'view3'
			$TestRecord.IPAddress | should be '2.2.2.2'
			$TestRecord.Comment | should benullorempty
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3'
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False

		}
		It "Returns A record from strict comment query" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,$Null,$Null,'test comment',$Null,$Null,$Null,$True,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.Name | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True

		}
		It "returns A record from non-strict comment query" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,$Null,$Null,'test comment',$Null,$Null,$Null,$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.count | should be 2
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
			$TestRecord[0].Name | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
			$TestRecord[1].Name | should be 'testrecord3.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.1.1.1'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
		}
		It "returns A record from non-strict name and comment query" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,'testrecord',$Null,'test comment 2',$Null,$Null,$Null,$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.Name | should be 'testrecord3.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Comment | should be 'test comment 2'
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "returns A record from strict name and IP Address query" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'testrecord.domain.com','1.1.1.1',$Null,$Null,$Null,$Null,$True,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.Name | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "returns A record from strict name and view query" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,'testrecord.domain.com',$Null,$Null,$Null,$Null,'default',$True,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.Name | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "returns A record from strict name and zone query" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,'testrecord.domain.com',$Null,$Null,$Null,'domain.com',$Null,$True,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.Name | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True

		}
		It "returns A record from non-strict name query with results count of 1" {
			$TestRecord = [IB_DNSARecord]::Get($Gridmaster,$Credential,'testrecord',$Null,$Null,$Null,$Null,$Null,$False,1)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord[]'
			$TestRecord.Name | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True

		}
	}
	Context "Set Method" {
		It "Throws an error with an invalid IP Address parameter" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			{$TestRecord.Set('NotanIPAddress',$Null,$Null,$Null)} | should throw
		}
		It "Throws an error with an invalid TTL parameter" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			{$TestRecord.Set('1.1.1.1',$Null,'NotATTL',$Null)} | should Throw
		}
		It "Throws an error with less than 4 parameters" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			{$TestRecord.Set('1.1.1.1','comment','TTL')} | Should Throw
		}
		It "Throws an error with more than 4 parameters" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			{$TestRecord.Set('l.l.l.l','comment','ttl',$True,'5thparameter')} | should Throw
		}
		It "Sets the comment and IPAddress on an existing DNS Record" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			$TestRecord.Set('2.2.2.2','new comment',0,$False)
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.GetType().Name | should be 'IB_DNSARecord'
			$TestRecord.Name | should be  'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '2.2.2.2'
			$TestRecord.Comment | should be 'new comment'
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
		It "Sets the TTL on an existing record" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			$TestRecord.Set('2.2.2.2','new comment',100,$True)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord'
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.Name | should be  'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '2.2.2.2'
			$TestRecord.Comment | should be 'new comment'
			$TestRecord.TTL | should be 100
			$TestRecord.Use_TTL | should be $True

		}
		It "Sets the Use_TTL flag with a null TTL value, resulting in a 0 TTL" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			$TestRecord.Set('1.1.1.1','test comment',$Null,$True)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord'
			$TestRecord.Name | should be 'testrecord.domain.com'
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $True
		}
		It "Sets the TTL but sets Use_TTL to False, which results in a null TTL" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			$TestRecord.Set('1.1.1.1','test comment',100,$False)
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.GetType().Name | should be 'IB_DNSARecord'
			$TestRecord.name | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.comment | should be 'test comment'
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
		It "Sets the comment to null" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			$TestRecord.Set('2.2.2.2',$Null,0,$False)
			$TestRecord.GetType().Name | should be 'IB_DNSARecord'
			$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			$TestRecord.Name | should be  'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '2.2.2.2'
			$TestRecord.Comment | should benullorempty
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
	}
	Context "Create Method" {
		It "Throws error with invalid credential paramter" {
			{[IB_DNSARecord]::Create($Gridmaster,"notacredential",'name','1.1.1.1',$Null,$Null,$Null,$Null)} | should throw
		}
		It "Throws error with invalid IP address parameter" {
			{[IB_DNSARecord]::Create($Gridmaster,$Credential,'name','notanipaddress',$Null,$Null,$Null,$Null)} | should throw
		}
		It "Throws error with invalid TTL parameter" {
			{[IB_DNSARecord]::Create($Gridmaster,$Credential,'name','notanipaddress',$Null,$Null,'NotATTL',$Null)} | should throw
		}
		It "Throws error with less than 8 parameters" {
			{[IB_DNSARecord]::Create($Gridmaster,$credential)} | should throw
		}
		It "Throws error with more than 8 parameters" {
			{[IB_DNSARecord]::Create($gridmaster,$Credential,'name','ipaddress',$Null,$Null,$Null,$Null,'9thproperty')} | should throw
		}
		It "Creates dns A record in default view with no comment or TTL" {
			$record = [IB_DNSARecord]::Create($Gridmaster,$Credential,'newtestrecord.domain.com','1.1.1.1',$Null,$Null,$Null,$False)
			$Record.GetType().Name | should be 'IB_DNSARecord'
			$Record.View | should be 'default'
			$Record.Name | should be 'newtestrecord.domain.com'
			$Record.IPAddress | should be '1.1.1.1'
			$Record.comment | should benullorempty
			$Record.TTL | should be 0
			$Record.Use_TTL | should be $False
		}
		It "Creates dns A record in default view with comment and TTL" {
			$record = [IB_DNSARecord]::Create($Gridmaster,$Credential,'newtestrecord2.domain.com','1.1.1.1','test comment',$Null,100,$True)
			$Record.GetType().Name | should be 'IB_DNSARecord'
			$Record.View | should be 'default'
			$Record.Name | should be 'newtestrecord2.domain.com'
			$Record.IPAddress | should be '1.1.1.1'
			$Record.comment | should be 'test comment'
			$Record.TTL | should be 100
			$Record.Use_TTL | should be $True
		}
		It "Creates dns A record in default view with TTL = 100 but Use_TTL = False, resulting in no TTL" {
			$record = [IB_DNSARecord]::Create($Gridmaster,$Credential,'newtestrecord3.domain.com','1.1.1.1',$Null,$Null,100,$False)
			$Record.GetType().Name | should be 'IB_DNSARecord'
			$Record.View | should be 'default'
			$Record.Name | should be 'newtestrecord3.domain.com'
			$Record.IPAddress | should be '1.1.1.1'
			$Record.comment | should benullorempty
			$Record.TTL | should be 0
			$Record.Use_TTL | should be $False
		}
		It "Creates dns A record in specified view with no comment or TTL" {
			$record = [IB_DNSARecord]::Create($Gridmaster,$Credential,'newtestrecord4.domain.com','1.1.1.1',$Null,'view2',$Null,$False)
			$Record.GetType().Name | should be 'IB_DNSARecord'
			$Record.View | should be 'view2'
			$Record.Name | should be 'newtestrecord4.domain.com'
			$Record.IPAddress | should be '1.1.1.1'
			$Record.comment | should benullorempty
			$Record.TTL | should be 0
			$Record.Use_TTL | should be $False
		}
	}
	Context "AddExtAttrib Method" {
		It "Adds extensible attribute" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3')
			$TestRecord.AddExtAttrib('Site','corp')
			$TestRecord.ExtAttrib.Name | should be 'Site'
			$TestRecord.ExtAttrib.value | should be 'corp'
		}
		It "Updates the value of an existing extensible attribute" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			$TestRecord.AddExtAttrib('Site','gulf')
			$TestRecord.ExtAttrib | measure-object | select -ExpandProperty Count | should be 1
			$TestRecord.ExtAttrib.Name | should be 'Site'
			$TestRecord.ExtAttrib.value | should be 'gulf'
		}
		It "Adds second extensible attribte to existing record" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			$TestRecord.AddExtAttrib('EA2','value2')
			$TestRecord.AddExtAttrib('EA3','value3')
			$TestRecord.ExtAttrib | measure-object | select -ExpandProperty Count | should be 3
			$TestRecord.ExtAttrib[0].Name | should be 'EA2'
			$TestRecord.ExtAttrib[0].value | should be 'value2'
			$TestRecord.ExtAttrib[1].Name | should be 'EA3'
			$TestRecord.ExtAttrib[1].value | should be 'value3'
			$TestRecord.ExtAttrib[2].Name | should be 'Site'
			$TestRecord.ExtAttrib[2].value | should be 'gulf'
		}
	}
	Context "RemoveExtAttrib Method" {
		It "Removes extensible attribute" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			$TestRecord.RemoveExtAttrib('Site')
			$TestRecord.ExtAttrib.Site | should benullorempty
			$TestRecord.ExtAttrib | measure-object | % Count | should be 2
		}
	}
	Context "Delete Method" {
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		It "Deletes record with refstring record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default" {
			$TestRecord.Delete() | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
			[IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default') |
				should benullorempty
		}
	}
}
Describe "IB_DNSCNameRecord Tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Put'} {
		Mock-InfobloxPut -uri $Uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Post'} {
		Mock-InfobloxPost -uri $uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Delete'} {
	$uri | Mock-InfobloxDelete
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	Context "Get Method" {

		It "Throws error with invalid credential object" {
			{[IB_DNSCNameRecord]::Get($Gridmaster,'notacredential','refstring')} | should throw
			{[IB_DNSCNameRecord]::Get($Gridmaster,'notacredential','name','testrecord.domain.com','comment','domain.com','view',$False,0)} | should throw
		}
		It "Throws error with invalid boolean object" {
			{[IB_DNSCNameRecord]::Get($Gridmaster,$Credential,'name','testrecord.domain.com','comment','zone','view','notabool',0)} | should throw
		}
		It "Throws error with invalid integer object" {
			{[IB_DNSCNameRecord]::Get($gridmaster,$Credential,'name','testrecord.domain.com','comment','zone','view',$False,'notanint')} | should throw
		}
		It "Throws error with less than 3 parameters" {
			{[IB_DNSCNameRecord]::Get($gridmaster,$Credential)} | should throw
		}
		It "Throws error with more than 3 but less than 10 parameters" {
			{[IB_DNSCNameRecord]::Get($gridmaster,$Credential,'param1','param2')} | should throw
		}
		It "Throws errror with more than 10 parameters" {
			{[IB_DNSCNameRecord]::Get($Gridmaster,$Credential,'name','testrecord.domain.com','comment','extattrib','zone','view',$False,0,'param10')} | should throw
		}
		It "returns CName Record from ref query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True
		}
		It "Returns CName Record from strict name query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,'testalias.domain.com',$Null,$Null,$Null,$Null,$Null,$True,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True
		}
		It "returns multiple CName Records from non-strict name query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,'testalias',$Null,$Null,$Null,$Null,$Null,$False,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.count | should be 3
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should be 'test comment'
			$testalias[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias[0].TTL | should be 1200
			$testalias[0].Use_TTL | should be $True
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias3.domain.com'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment 2'
			$testalias[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias[1].TTL | should be 1200
			$testalias[1].Use_TTL | should be $True
			#
			$testalias[2].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[2].Name | should be 'testalias2.domain.com'
			$testalias[2].View | should be 'view3'
			$testalias[2].canonical | should be 'testrecord2.domain.com'
			$testalias[2].Comment | should benullorempty
			$testalias[2]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJfZGVmY2:testalias2.domain.com/view3'
			$testalias[2].TTL | should be 0
			$testalias[2].Use_TTL | should be $False

		}
		It "returns multiple CName Records from non-strict canonical query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,$Null,'testrecord',$Null,$Null,$Null,$Null,$False,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.count | should be 3
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should be 'test comment'
			$testalias[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias[0].TTL | should be 1200
			$testalias[0].Use_TTL | should be $True
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias3.domain.com'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment 2'
			$testalias[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias[1].TTL | should be 1200
			$testalias[1].Use_TTL | should be $True
			#
			$testalias[2].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[2].Name | should be 'testalias2.domain.com'
			$testalias[2].View | should be 'view3'
			$testalias[2].canonical | should be 'testrecord2.domain.com'
			$testalias[2].Comment | should benullorempty
			$testalias[2]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJfZGVmY2:testalias2.domain.com/view3'
			$testalias[2].TTL | should be 0
			$testalias[2].Use_TTL | should be $False

		}
		It "Returns multiple CName Records from zone query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,'domain.com',$Null,$False,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.count | should be 3
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should be 'test comment'
			$testalias[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias[0].TTL | should be 1200
			$testalias[0].Use_TTL | should be $True
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias3.domain.com'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment 2'
			$testalias[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias[1].TTL | should be 1200
			$testalias[1].Use_TTL | should be $True
			#
			$testalias[2].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[2].Name | should be 'testalias2.domain.com'
			$testalias[2].View | should be 'view3'
			$testalias[2].canonical | should be 'testrecord2.domain.com'
			$testalias[2].Comment | should benullorempty
			$testalias[2]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJfZGVmY2:testalias2.domain.com/view3'
			$testalias[2].TTL | should be 0
			$testalias[2].Use_TTL | should be $False

		}
		It "Returns multiple CName Records from strict canonical query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,$Null,'testrecord.domain.com',$Null,$Null,$Null,$Null,$True,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.count | should be 2
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should be 'test comment'
			$testalias[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias[0].TTL | should be 1200
			$testalias[0].Use_TTL | should be $True
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias3.domain.com'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment 2'
			$testalias[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias[1].TTL | should be 1200
			$testalias[1].Use_TTL | should be $True

		}
		It "Returns CName Record from view query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$Null,'view3',$False,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.Name | should be 'testalias2.domain.com'
			$testalias.View | should be 'view3'
			$testalias.canonical | should be 'testrecord2.domain.com'
			$testalias.Comment | should benullorempty
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJfZGVmY2:testalias2.domain.com/view3'
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False

		}
		It "Returns CName Record from strict comment query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,$Null,$Null,'test comment',$Null,$Null,$Null,$True,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True

		}
		It "returns CName Record from non-strict comment query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,$Null,$Null,'test comment',$Null,$Null,$Null,$False,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.count | should be 2
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should be 'test comment'
			$testalias[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias[0].TTL | should be 1200
			$testalias[0].Use_TTL | should be $True
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias3.domain.com'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment 2'
			$testalias[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias[1].TTL | should be 1200
			$testalias[1].Use_TTL | should be $True
		}
		It "returns CName Record from non-strict name and comment query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,'testalias',$Null,'test comment 2',$Null,$Null,$Null,$False,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.Name | should be 'testalias3.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment 2'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True
		}
		It "returns CName Record from strict name and canonical query" {
			$testalias = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'testalias.domain.com','testrecord.domain.com',$Null,$Null,$Null,$Null,$True,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True
		}
		It "returns CName Record from strict name and view query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,'testalias.domain.com',$Null,$Null,$Null,$Null,'default',$True,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True
		}
		It "returns CName Record from strict name and zone query" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,'testalias.domain.com',$Null,$Null,$Null,'domain.com',$Null,$True,$Null)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True

		}
		It "returns CName Record from non-strict name query with results count of 1" {
			$testalias = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,'testalias',$Null,$Null,$Null,$Null,$Null,$False,1)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord[]'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True

		}
	}
	Context "Set Method" {
		It "Throws an error with an invalid TTL parameter" {
			$testalias = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
			{$testalias.Set('testrecord.domain.com',$Null,'NotATTL',$Null)} | should Throw
		}
		It "Throws an error with less than 4 parameters" {
			$testalias = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
			{$testalias.Set('testrecord.domain.com','comment','TTL')} | Should Throw
		}
		It "Throws an error with more than 4 parameters" {
			$testalias = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
			{$testalias.Set('l.l.l.l','comment','ttl',$True,'5thparameter')} | should Throw
		}
		It "Sets the comment and canonical on an existing DNS Record" {
			$testalias = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
			$testalias.Set('testrecord2.domain.com','new comment',0,$False)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$TestAlias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.Name | should be  'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord2.domain.com'
			$testalias.Comment | should be 'new comment'
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False
		}
		It "Sets the TTL on an existing record" {
			$testalias = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
			$testalias.Set('testrecord2.domain.com','new comment',100,$True)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$TestAlias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.Name | should be  'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord2.domain.com'
			$testalias.Comment | should be 'new comment'
			$testalias.TTL | should be 100
			$testalias.Use_TTL | should be $True

		}
		It "Sets the Use_TTL flag with a null TTL value, resulting in a 0 TTL" {
			$testalias = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
			$testalias.Set('testrecord.domain.com','test comment',$Null,$True)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$TestAlias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $True
		}
		It "Sets the TTL but sets Use_TTL to False, which results in a null TTL" {
			$testalias = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
			$testalias.Set('testrecord.domain.com','test comment',100,$False)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$TestAlias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.comment | should be 'test comment'
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False
		}
		It "Sets the comment to null" {
			$testalias = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
			$testalias.Set('testrecord2.domain.com',$Null,0,$False)
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$TestAlias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.Name | should be  'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord2.domain.com'
			$testalias.Comment | should benullorempty
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False
		}
	}
	Context "Create Method" {
		It "Throws error with invalid credential paramter" {
			{[IB_DNSCNameRecord]::Create($Gridmaster,"notacredential",'name','testrecord.domain.com',$Null,$Null,$Null,$Null)} | should throw
		}
		It "Throws error with invalid TTL parameter" {
			{[IB_DNSCNameRecord]::Create($Gridmaster,$Credential,'name','testrecord.domain.com',$Null,$Null,'NotATTL',$Null)} | should throw
		}
		It "Throws error with less than 8 parameters" {
			{[IB_DNSCNameRecord]::Create($Gridmaster,$credential)} | should throw
		}
		It "Throws error with more than 8 parameters" {
			{[IB_DNSCNameRecord]::Create($gridmaster,$Credential,'name','canonical',$Null,$Null,$Null,$Null,'9thproperty')} | should throw
		}
		It "Creates dns CName Record in default view with no comment or TTL" {
			$record = [IB_DNSCNameRecord]::Create($Gridmaster,$Credential,'newtestalias.domain.com','testrecord.domain.com',$Null,$Null,$Null,$False)
			$Record.GetType().Name | should be 'IB_DNSCNameRecord'
			$Record.View | should be 'default'
			$Record.Name | should be 'newtestalias.domain.com'
			$Record.canonical | should be 'testrecord.domain.com'
			$Record.comment | should benullorempty
			$Record.TTL | should be 0
			$Record.Use_TTL | should be $False
		}
		It "Creates dns CName Record in default view with comment and TTL" {
			$record = [IB_DNSCNameRecord]::Create($Gridmaster,$Credential,'newtestalias2.domain.com','testrecord.domain.com','test comment',$Null,100,$True)
			$Record.GetType().Name | should be 'IB_DNSCNameRecord'
			$Record.View | should be 'default'
			$Record.Name | should be 'newtestalias2.domain.com'
			$Record.canonical | should be 'testrecord.domain.com'
			$Record.comment | should be 'test comment'
			$Record.TTL | should be 100
			$Record.Use_TTL | should be $True
		}
		It "Creates dns CName Record in default view with TTL = 100 but Use_TTL = False, resulting in no TTL" {
			$record = [IB_DNSCNameRecord]::Create($Gridmaster,$Credential,'newtestalias3.domain.com','testrecord.domain.com',$Null,$Null,100,$False)
			$Record.GetType().Name | should be 'IB_DNSCNameRecord'
			$Record.View | should be 'default'
			$Record.Name | should be 'newtestalias3.domain.com'
			$Record.canonical | should be 'testrecord.domain.com'
			$Record.comment | should benullorempty
			$Record.TTL | should be 0
			$Record.Use_TTL | should be $False
		}
		It "Creates dns CName Record in specified view with no comment or TTL" {
			$record = [IB_DNSCNameRecord]::Create($Gridmaster,$Credential,'newtestalias4.domain.com','testrecord.domain.com',$Null,'view2',$Null,$False)
			$Record.GetType().Name | should be 'IB_DNSCNameRecord'
			$Record.View | should be 'view2'
			$Record.Name | should be 'newtestalias4.domain.com'
			$Record.canonical | should be 'testrecord.domain.com'
			$Record.comment | should benullorempty
			$Record.TTL | should be 0
			$Record.Use_TTL | should be $False
		}
	}
	Context "AddExtAttrib Method" {
		It "Adds extensible attribute" {
			$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJfZGVmY2:testalias2.domain.com/view3')
			$TestRecord.AddExtAttrib('Site','corp')
			$TestRecord.ExtAttrib.Name | should be 'Site'
			$TestRecord.ExtAttrib.value | should be 'corp'
		}
		It "Updates the value of an existing extensible attribute" {
			$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default')
			$TestRecord.AddExtAttrib('Site','gulf')
			$TestRecord.AddExtAttrib | measure-object | select -ExpandProperty Count | should be 1
			$TestRecord.ExtAttrib.Name | should be 'Site'
			$TestRecord.ExtAttrib.value | should be 'gulf'
		}
	}
	Context "RemoveExtAttrib Method" {
		It "Removes extensible attribute" {
			$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default')
			$TestRecord.RemoveExtAttrib('Site')
			$TestRecord.ExtAttrib | should benullorempty
		}	
	}
	Context "Delete Method" {
		It "Deletes record with refstring record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default" {
			$testalias = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
			$testalias.Delete() | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			[IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default') |
				should benullorempty
		}
	}
}
Describe "IB_DNSPTRRecord Tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Put'} {
		Mock-InfobloxPut -uri $Uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Delete'} {
		$uri | Mock-InfobloxDelete
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Post'} {
		Mock-InfobloxPost -uri $uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	Context "Get Method" {

		It "Throws error with invalid credential object" {
			{[IB_DNSPTRRecord]::Get($Gridmaster,'notacredential','refstring')} | should throw
			{[IB_DNSPTRRecord]::Get($Gridmaster,'notacredential','name','1.1.1.1','ptrdname','comment','domain.com','view',$False,0)} | should throw
		}
		It "Throws error with invalid IP Address object" {
			{[IB_DNSPTRRecord]::Get($Gridmaster,$Credential,'name','notanipaddress','ptrdname','comment','zone','view',$False,0)} | should throw
		}
		It "Throws error with invalid boolean object" {
			{[IB_DNSPTRRecord]::Get($Gridmaster,$Credential,'name','1.1.1.1','ptrdname','comment','zone','view','notabool',0)} | should throw
		}
		It "Throws error with invalid integer object" {
			{[IB_DNSPTRRecord]::Get($gridmaster,$Credential,'name','1.1.1.1','ptrdname','comment','zone','view',$False,'notanint')} | should throw
		}
		It "Throws error with less than 3 parameters" {
			{[IB_DNSPTRRecord]::Get($gridmaster,$Credential)} | should throw
		}
		It "Throws error with more than 3 but less than 11 parameters" {
			{[IB_DNSPTRRecord]::Get($gridmaster,$Credential,'param1','param2')} | should throw
			{[IB_DNSPTRRecord]::Get($Gridmaster,$Credential,'name','1.1.1.1','comment','zone','view',$False,0)} | should throw
		}
		It "Throws errror with more than 11 parameters" {
			{[IB_DNSPTRRecord]::Get($Gridmaster,$Credential,'name','1.1.1.1','ptrdname','comment','extattrib','zone','view',$False,0,'param10')} | should throw
		}
		It "returns PTR Record from ref query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "Returns PTR Record from strict name query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,'1.1.1.1.in-addr.arpa',$Null,$Null,$Null,$Null,$Null,$Null,$True,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "Returns multiple PTR Records from non-strict name query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,'1.',$Null,$Null,$Null,$Null,$Null,$Null,$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.Count | should be 3
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.2.3.4'
			$TestRecord[1].Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
			#
			$TestRecord[2].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[2].PTRDName | should be 'localhost'
			$TestRecord[2].View | should be 'default'
			$TestRecord[2].IPAddress | should benullorempty
			$TestRecord[2].Name | should be '1.0.0.0.in-addr.arpa'
			$TestRecord[2].Comment | should benullorempty
			$TestRecord[2]._ref | should be 'record:ptr/adfwejfojvkalfpjqpe:1.0.0.0.in-addr.arpa/default'
			$TestRecord[2].TTL | should be 1
			$TestRecord[2].Use_TTL | should be $True
		}
		It "Returns PTR Record from strict ptrdname query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,$Null,$Null,'testrecord.domain.com',$Null,$Null,$Null,$Null,$True,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.count | should be 2
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.2.3.4'
			$TestRecord[1].Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
		}
		It "returns multiple PTR Records from non-strict ptrdname query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,$Null,$Null,'testrecord',$Null,$Null,$Null,$Null,$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.count | should be 3
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.2.3.4'
			$TestRecord[1].Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
			#
			$TestRecord[2].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[2].PTRDName | should be 'testrecord2.domain.com'
			$TestRecord[2].View | should be 'view3'
			$TestRecord[2].IPAddress | should be '2.2.2.2'
			$TestRecord[2].Name | should be '2.2.2.2.in-addr.arpa'
			$TestRecord[2].Comment | should benullorempty
			$TestRecord[2]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2.in-addr.arpa/view3'
			$TestRecord[2].TTL | should be 0
			$TestRecord[2].Use_TTL | should be $False

		}
		It "Returns multiple PTR Records from zone query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$Null,'domain.com',$Null,$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.count | should be 3
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.2.3.4'
			$TestRecord[1].Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
			#
			$TestRecord[2].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[2].PTRDName | should be 'testrecord2.domain.com'
			$TestRecord[2].View | should be 'view3'
			$TestRecord[2].IPAddress | should be '2.2.2.2'
			$TestRecord[2].Name | should be '2.2.2.2.in-addr.arpa'
			$TestRecord[2].Comment | should benullorempty
			$TestRecord[2]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2.in-addr.arpa/view3'
			$TestRecord[2].TTL | should be 0
			$TestRecord[2].Use_TTL | should be $False

		}
		It "Returns PTR Record from IP Address query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,$Null,'1.1.1.1',$Null,$Null,$Null,$Null,$Null,$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "Returns PTR Record from view query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$Null,$Null,'view3',$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.PTRDName | should be 'testrecord2.domain.com'
			$TestRecord.View | should be 'view3'
			$TestRecord.IPAddress | should be '2.2.2.2'
			$TestRecord.Name | should be '2.2.2.2.in-addr.arpa'
			$TestRecord.Comment | should benullorempty
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2.in-addr.arpa/view3'
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False

		}
		It "Returns PTR Record from strict comment query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,$Null,$Null,$Null,'test comment',$Null,$Null,$Null,$True,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True

		}
		It "returns PTR Record from non-strict comment query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,$Null,$Null,$Null,'test comment',$Null,$Null,$Null,$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.count | should be 2
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.2.3.4'
			$TestRecord[1].Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
		}
		It "returns PTR Record from non-strict ptrdname and comment query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,$Null,$Null,'testrecord','test comment 2',$Null,$Null,$Null,$False,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.2.3.4'
			$TestRecord.Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment 2'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "returns PTR Record from strict ptrdname and IP Address query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,$Null,'1.1.1.1','testrecord.domain.com',$Null,$Null,$Null,$Null,$True,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "returns PTR Record from strict ptrdname and view query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,'1.1.1.1.in-addr.arpa',$Null,$Null,$Null,$Null,$Null,'default',$True,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "returns PTR Record from strict name and zone query" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,'1.1.1.1.in-addr.arpa',$Null,$Null,$Null,$Null,'domain.com',$Null,$True,$Null)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True

		}
		It "returns PTR Record from non-strict ptrdname query with results count of 1" {
			$TestRecord = [IB_DNSPTRRecord]::Get($Gridmaster,$Credential,$Null,$Null,'testrecord',$Null,$Null,$Null,$Null,$False,1)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord[]'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True

		}
	}
	Context "Set Method" {
		It "Throws an error with an invalid TTL parameter" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
			{$TestRecord.Set('testrecord.domain.com',$Null,'NotATTL',$Null)} | should Throw
		}
		It "Throws an error with less than 4 parameters" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
			{$TestRecord.Set('testrecord.domain.com','comment','TTL')} | Should Throw
		}
		It "Throws an error with more than 4 parameters" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
			{$TestRecord.Set('testrecord.domain.com','comment','ttl',$True,'5thparameter')} | should Throw
		}
		It "Sets the comment and PTRDName on an existing DNS Record" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
			$TestRecord.Set('testrecord2.domain.com','new comment',0,$False)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be  'testrecord2.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'new comment'
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
		It "Sets the TTL on an existing record" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.Set('testrecord2.domain.com','new comment',100,$True)
			$TestRecord.PTRDName | should be  'testrecord2.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'new comment'
			$TestRecord.TTL | should be 100
			$TestRecord.Use_TTL | should be $True

		}
		It "Sets the Use_TTL flag with a null TTL value, resulting in a 0 TTL" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
			$TestRecord.Set('testrecord.domain.com','test comment',$Null,$True)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $True
		}
		It "Sets the TTL but sets Use_TTL to False, which results in a null TTL" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
			$TestRecord.Set('testrecord.domain.com','test comment',100,$False)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.comment | should be 'test comment'
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
		It "Sets the comment to null" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
			$TestRecord.Set('testrecord2.domain.com',$Null,0,$False)
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be  'testrecord2.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should benullorempty
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
	}
	Context "Create Method" {
		It "Throws error with invalid credential paramter" {
			{[IB_DNSPTRRecord]::Create($Gridmaster,"notacredential",'name','1.1.1.1',$Null,$Null,$Null,$Null)} | should throw
		}
		It "Throws error with invalid IP address parameter" {
			{[IB_DNSPTRRecord]::Create($Gridmaster,$Credential,'name','notanipaddress',$Null,$Null,$Null,$Null)} | should throw
		}
		It "Throws error with invalid TTL parameter" {
			{[IB_DNSPTRRecord]::Create($Gridmaster,$Credential,'name','notanipaddress',$Null,$Null,'NotATTL',$Null)} | should throw
		}
		It "Throws error with less than 8 parameters" {
			{[IB_DNSPTRRecord]::Create($Gridmaster,$credential)} | should throw
		}
		It "Throws error with more than 8 parameters" {
			{[IB_DNSPTRRecord]::Create($gridmaster,$Credential,'name','ipaddress',$Null,$Null,$Null,$Null,'9thproperty')} | should throw
		}
		It "Creates dns PTR record in default view with no comment or TTL" {
			$record = [IB_DNSPTRRecord]::Create($Gridmaster,$Credential,'newtestrecord.domain.com','1.1.1.1',$Null,$Null,$Null,$False)
			$Record.GetType().Name | should be 'IB_DNSPTRRecord'
			$Record.View | should be 'default'
			$Record.PTRDName | should be 'newtestrecord.domain.com'
			$Record.IPAddress | should be '1.1.1.1'
			$Record.Name | should be '1.1.1.1.in-addr.arpa'
			$Record.comment | should benullorempty
			$Record.TTL | should be 0
			$Record.Use_TTL | should be $False
		}
		It "Creates dns PTR Record in default view with comment and TTL" {
			$record = [IB_DNSPTRRecord]::Create($Gridmaster,$Credential,'newtestrecord2.domain.com','1.1.1.1','test comment',$Null,100,$True)
			$Record.GetType().Name | should be 'IB_DNSPTRRecord'
			$Record.View | should be 'default'
			$Record.PTRDName | should be 'newtestrecord2.domain.com'
			$Record.IPAddress | should be '1.1.1.1'
			$Record.Name | should be '1.1.1.1.in-addr.arpa'
			$Record.comment | should be 'test comment'
			$Record.TTL | should be 100
			$Record.Use_TTL | should be $True
		}
		It "Creates dns PTR Record in default view with TTL = 100 but Use_TTL = False, resulting in no TTL" {
			$record = [IB_DNSPTRRecord]::Create($Gridmaster,$Credential,'newtestrecord.domain.com','1.1.1.1',$Null,$Null,100,$False)
			$Record.GetType().Name | should be 'IB_DNSPTRRecord'
			$Record.View | should be 'default'
			$Record.PTRDName | should be 'newtestrecord.domain.com'
			$Record.IPAddress | should be '1.1.1.1'
			$Record.name | should be '1.1.1.1.in-addr.arpa'
			$Record.comment | should benullorempty
			$Record.TTL | should be 0
			$Record.Use_TTL | should be $False
		}
		It "Creates dns PTR Record in specified view with no comment or TTL" {
			$record = [IB_DNSPTRRecord]::Create($Gridmaster,$Credential,'newtestrecord4.domain.com','1.1.1.2',$Null,'view2',$Null,$False)
			$Record.GetType().Name | should be 'IB_DNSPTRRecord'
			$Record.View | should be 'view2'
			$Record.PTRDName | should be 'newtestrecord4.domain.com'
			$Record.IPAddress | should be '1.1.1.2'
			$Record.Name | should be '2.1.1.1.in-addr.arpa'
			$Record.comment | should benullorempty
			$Record.TTL | should be 0
			$Record.Use_TTL | should be $False
		}
	}
	Context "AddExtAttrib Method" {
		It "Adds extensible attribute" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2.in-addr.arpa/view3')
			$TestRecord.AddExtAttrib('Site','corp')
			$TestRecord.ExtAttrib.Name | should be 'Site'
			$TestRecord.ExtAttrib.value | should be 'corp'
		}
		It "Updates the value of an existing extensible attribute" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default')
			$TestRecord.AddExtAttrib('Site','gulf')
			$TestRecord.AddExtAttrib | measure-object | select -ExpandProperty Count | should be 1
			$TestRecord.ExtAttrib.Name | should be 'Site'
			$TestRecord.ExtAttrib.value | should be 'gulf'
		}
	}
	Context "RemoveExtAttrib Method" {
		It "Removes extensible attribute" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default')
			$TestRecord.RemoveExtAttrib('Site')
			$TestRecord.ExtAttrib | should benullorempty
		}	
	}
	Context "Delete Method" {
		It "Deletes record with refstring record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default" {
			$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
			$TestRecord.Delete() | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			[IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default') |
				should benullorempty
		}
	}
}
Describe "IB_View tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}

	Context 'Get Method' {
		It "Throws error with invalid credential object" {
			{[IB_View]::Get($Gridmaster,'notacredential','name',$True,'comment',$True,1)} | should throw
		}
		It "Throws error with invalid integer object" {
			{[IB_View]::Get($Gridmaster,$credential,'name',$True,'comment',$True,'notanint')} | should throw
		}
		It "Throws error with less than 8 properties" {
			{[IB_View]::Get($Gridmaster,$credential,'name',$True,'comment',$True)} | should throw
		}
		It "Throws error with more than 8 properties" {
			{[IB_View]::Get($Gridmaster,$credential,'name',$True,'comment','extattrib',$True,1,'extra')} | should throw
		}
		It "Gets view by reference" {
			$Result = [IB_View]::Get($Gridmaster,$Credential,'view/asdfioaweo3893jco:view2/False')
			$Result.GetType().Name | should be 'IB_View'
			$Result.Name | should be 'view2'
			$Result.is_default | should be $False
			$Result.comment | should be 'Second View'
		}
		It "Gets all views" {
			$Result = [IB_View]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_View[]'
			$Result.Count | should be 3
			#
			$Result[0].GetType().Name | should be 'IB_View'
			$Result[0]._ref | should be 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result[0].Name | should be 'default'
			$Result[0].comment | should be 'Default view'
			$Result[0].is_default | should be $True
			#
			$Result[1].GetType().Name | should be 'IB_View'
			$Result[1]._ref | should be 'view/asdfioaweo3893jco:view2/False'
			$Result[1].Name | should be 'view2'
			$Result[1].comment | should be 'Second View'
			$Result[1].is_default | should be $False
			#
			$Result[2].GetType().Name | should be 'IB_View'
			$Result[2]._ref | should be 'view/jkdfjover89345jh934:view3/False'
			$Result[2].Name | should be 'view3'
			$Result[2].comment | should be 'Third View'
			$Result[2].is_default | should be $False
		}
		It "Gets default view" {
			$Result = [IB_View]::Get($Gridmaster,$Credential,$Null,$True,$Null,$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_View[]'
			$Result._ref | should be 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result.Name | should be 'default'
			$Result.comment | should be 'Default view'
			$Result.is_default | should be $True
		}
		It "gets view with strict name search" {
			$Result = [IB_View]::Get($Gridmaster,$Credential,'default',$Null,$Null,$Null,$True,$Null)
			$Result.GetType().Name | should be 'IB_View[]'
			$Result._ref | should be 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result.Name | should be 'default'
			$Result.comment | should be 'Default view'
			$Result.is_default | should be $True
		}
		It "gets views with non-strict name search" {
			$Result = [IB_View]::Get($Gridmaster,$Credential,'view',$Null,$Null,$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_View[]'
			$Result.count | should be 2
			#
			$Result[0].GetType().Name | should be 'IB_View'
			$Result[0]._ref | should be 'view/asdfioaweo3893jco:view2/False'
			$Result[0].Name | should be 'view2'
			$Result[0].comment | should be 'Second View'
			$Result[0].is_default | should be $False
			#
			$Result[1].GetType().Name | should be 'IB_View'
			$Result[1]._ref | should be 'view/jkdfjover89345jh934:view3/False'
			$Result[1].Name | should be 'view3'
			$Result[1].comment | should be 'Third View'
			$Result[1].is_default | should be $False
		}
		It "gets non-default views with is_default search" {
			$Result = [IB_View]::Get($gridmaster,$Credential,$Null,$False,$Null,$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_View[]'
			$Result.count | should be 2
			#
			$Result[0].GetType().Name | should be 'IB_View'
			$Result[0]._ref | should be 'view/asdfioaweo3893jco:view2/False'
			$Result[0].Name | should be 'view2'
			$Result[0].comment | should be 'Second View'
			$Result[0].is_default | should be $False
			#
			$Result[1].GetType().Name | should be 'IB_View'
			$Result[1]._ref | should be 'view/jkdfjover89345jh934:view3/False'
			$Result[1].Name | should be 'view3'
			$Result[1].comment | should be 'Third View'
			$Result[1].is_default | should be $False
		}
		It "gets first view with no query but resultscount of 1" {
			$Result = [IB_View]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$Null,1)
			$Result.GetType().Name | should be 'IB_View[]'
			$Result._ref | should be 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result.Name | should be 'default'
			$Result.comment | should be 'Default view'
			$Result.is_default | should be $True
		}
		It "gets view with strict comment search" {
			$Result = [IB_View]::Get($Gridmaster,$Credential,$Null,$Null,'Second View',$Null,$True,$Null)
			$Result.GetType().Name | should be 'IB_View[]'
			$Result._ref | should be 'view/asdfioaweo3893jco:view2/False'
			$Result.Name | should be 'view2'
			$Result.comment | should be 'Second View'
			$Result.is_default | should be $False
		}
		It "gets view with non-strict comment search" {
			$Result = [IB_View]::Get($Gridmaster,$Credential,$Null,$Null,'Second View',$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_View[]'
			$Result._ref | should be 'view/asdfioaweo3893jco:view2/False'
			$Result.Name | should be 'view2'
			$Result.comment | should be 'Second View'
			$Result.is_default | should be $False
		}
		It "gets view with non-strict name and comment search" {
			$Result = [IB_View]::Get($Gridmaster,$Credential,'default',$Null,'Default View',$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_View[]'
			$Result._ref | should be 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result.Name | should be 'default'
			$Result.comment | should be 'Default view'
			$Result.is_default | should be $True
		}
		It "gets view with strict name, comment and is_default search" {
			$Result = [IB_View]::Get($Gridmaster,$Credential,'default',$True,'Default View',$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_View[]'
			$Result._ref | should be 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result.Name | should be 'default'
			$Result.comment | should be 'Default view'
			$Result.is_default | should be $True
		}
	}
	Context 'ToString Method' {
		$Result = [IB_View]::Get($Gridmaster,$Credential,'view/asdfioaweo3893jco:view2/False')
		$Result.ToString() | should be 'view2'

	}
}
Describe "IB_ExtAttributeDef tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}

	Context 'Get Method' {
		It "Throws error with invalid credential object" {
			{[IB_ExtAttrsDef]::Get($Gridmaster,'notacredential','name','Type','comment','defaultvalue',$False,1)} | should throw
		}
		It "Throws error with invalid integer object" {
			{[IB_ExtAttrsDef]::Get($Gridmaster,$credential,'name','Type','comment','defaultvalue',$False,'notanINT')} | should throw
		}
		It "Throws error with less than 8 properties" {
			{[IB_ExtAttrsDef]::Get($Gridmaster,$credential,'name','Type','comment','defaultvalue',$False)} | should throw
		}
		It "Throws error with more than 8 properties" {
			{[IB_ExtAttrsDef]::Get($Gridmaster,$credential,'name','Type','comment','defaultvalue',$False,1,'extraparam')} | should throw
		}
		It "Gets ExtensibleAttributeDef by reference" {
			$Result = [IB_ExtAttrsDef]::Get($Gridmaster,$Credential,'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLkJ1aWxkaW5n:Building')
			$Result.GetType().Name | should be 'IB_ExtAttrsDef'
			$Result.Name | should be 'Building'
			$Result.Type | should be 'STRING'
			$Result.comment | should benullorempty
		}
		It "Gets all ExtensibleAttributeDefs" {
			$Result = [IB_ExtAttrsDef]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_ExtAttrsDef[]'
			$Result.Count | should be 10
			#
			$Result[0].GetType().Name | should be 'IB_ExtAttrsDef'
			$Result[0]._ref | should be 'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLkJ1aWxkaW5n:Building'
			$Result[0].Name | should be 'Building'
			$Result[0].Type | should be 'STRING'
			$Result[0].comment | should benullorempty
			$Result[0].DefaultValue | should benullorempty
		}
		It "gets ExtensibleAttributeDef with strict name search" {
			$Result = [IB_ExtAttrsDef]::Get($Gridmaster,$Credential,'IBScavenge',$Null,$Null,$Null,$True,$Null)
			$Result.GetType().Name | should be 'IB_ExtAttrsDef[]'
			$Result._ref | should be 'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLklCc2NhdmVuZ2U:IBscavenge'
			$Result.Name | should be 'IBScavenge'
			$Result.Type | should be 'ENUM'
			$Result.comment | should be "Y = Yes\r\nN = No\r\nAttribute to scavenge record"
			$Result.DefaultValue | should benullorempty
		}
		It "gets ExtensibleAttributeDefs with non-strict name search" {
			$Result = [IB_ExtAttrsDef]::Get($Gridmaster,$Credential,'IBScavenge',$Null,$Null,$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_ExtAttrsDef[]'
			$Result.count | should be 3
			#
			$Result[0].GetType().Name | should be 'IB_ExtAttrsDef'
			$Result[0]._ref | should be 'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLklCc2NhdmVuZ2U:IBscavenge'
			$Result[0].Name | should be 'IBScavenge'
			$Result[0].Type | should be 'ENUM'
			$Result[0].comment | should be "Y = Yes\r\nN = No\r\nAttribute to scavenge record"
			$Result[0].DefaultValue | should benullorempty
			#
			$Result[1].GetType().Name | should be 'IB_ExtAttrsDef'
			$Result[1]._ref | should be 'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLklCc2NhdmVuZ2VFeGNsdWRl:IBscavengeExclude'
			$Result[1].Name | should be 'IBScavengeExclude'
			$Result[1].Type | should be 'ENUM'
			$Result[1].comment | should be "Y = Yes\r\nN = No\r\nAttribute for scavenging"
			$Result[1].DefaultValue | should benullorempty
			#
			$Result[2].GetType().Name | should be 'IB_ExtAttrsDef'
			$Result[2]._ref | should be 'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLklCc2NhdmVuZ2VVbmRpc2NvdmVyZWRDb3VudA:IBscavengeUndiscoveredCount'
			$Result[2].Name | should be 'IBscavengeUndiscoveredCount'
			$Result[2].Type | should be 'INTEGER'
			$Result[2].comment | should be "Counter for devices identified by the scavenging script who have not ever been discovered by Network Discovery"
			$Result[2].DefaultValue | should benullorempty
		}
		It "gets first ExtensibleAttributeDef with no query but resultscount of 1" {
			$Result = [IB_ExtAttrsDef]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$Null,1)
			$Result.GetType().Name | should be 'IB_ExtAttrsDef[]'
			$Result._ref | should be 'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLkJ1aWxkaW5n:Building'
			$Result.Name | should be 'Building'
			$Result.Type | should be 'STRING'
			$Result.comment | should benullorempty
			$Result.DefaultValue | should benullorempty
		}
		It "gets ExtensibleAttributeDef with strict comment search" {
			$Result = [IB_ExtAttrsDef]::Get($Gridmaster,$Credential,$Null,$Null,'Networks for IB Script Testing',$Null,$True,$Null)
			$Result.GetType().Name | should be 'IB_ExtAttrsDef[]'
			$Result._ref | should be 'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLlRlc3QgTmV0d29ya3M:Test%20Networks'
			$Result.Name | should be 'Test Networks'
			$Result.Type | should be 'ENUM'
			$Result.comment | should be 'Networks for IB Script Testing'
			$Result.DefaultValue | should benullorempty
		}
		It "gets ExtensibleAttributeDef with non-strict comment search" {
			$Result = [IB_ExtAttrsDef]::Get($Gridmaster,$Credential,$Null,$Null,'IB Script Testing',$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_ExtAttrsDef[]'
			$Result._ref | should be 'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLlRlc3QgTmV0d29ya3M:Test%20Networks'
			$Result.Name | should be 'Test Networks'
			$Result.Type | should be 'ENUM'
			$Result.comment | should be 'Networks for IB Script Testing'
			$Result.DefaultValue | should benullorempty
		}
		It "gets ExtensibleAttributeDef with non-strict name and comment search" {
			$Result = [IB_ExtAttrsDef]::Get($Gridmaster,$Credential,'Undiscovered',$Null,'Scavenging',$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_ExtAttrsDef[]'
			$Result._ref | should be 'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLklCc2NhdmVuZ2VVbmRpc2NvdmVyZWRDb3VudA:IBscavengeUndiscoveredCount'
			$Result.Name | should be 'IBscavengeUndiscoveredCount'
			$Result.Type | should be 'INTEGER'
			$Result.comment | should be 'Counter for devices identified by the scavenging script who have not ever been discovered by Network Discovery'
			$Result.DefaultValue | should benullorempty
		}
		It "gets ExtensibleAttributeDef with Type search" {
			$Result = [IB_ExtAttrsDef]::Get($Gridmaster,$Credential,$Null,'INTEGER',$Null,$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_ExtAttrsDef[]'
			$Result._ref | should be 'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLklCc2NhdmVuZ2VVbmRpc2NvdmVyZWRDb3VudA:IBscavengeUndiscoveredCount'
			$Result.Name | should be 'IBscavengeUndiscoveredCount'
			$Result.Type | should be 'INTEGER'
			$Result.comment | should be 'Counter for devices identified by the scavenging script who have not ever been discovered by Network Discovery'
			$Result.DefaultValue | should benullorempty

		}
	}
	Context 'ToString Method' {
		$Result = [IB_ExtAttrsDef]::Get($Gridmaster,$Credential,'extensibleattributedef/b25lLmV4dGVuc2libGVfYXR0cmlidXRlc19kZWYkLkJ1aWxkaW5n:Building')
		$Result.ToString() | should be 'Building'

	}
}
Describe "IB_networkview tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	Context 'Get Method' {
		It "Throws error with invalid credential object" {
			{[IB_networkview]::Get($Gridmaster,'notacredential','name',$True,'comment',$True,1)} | should throw
		}
		It "Throws error with invalid integer object" {
			{[IB_networkview]::Get($Gridmaster,$credential,'name',$True,'comment',$True,'notanint')} | should throw
		}
		It "Throws error with less than 8 properties" {
			{[IB_networkview]::Get($Gridmaster,$credential,'name',$True,'comment',$True)} | should throw
		}
		It "Throws error with more than 8 properties" {
			{[IB_networkview]::Get($Gridmaster,$credential,'name',$True,'comment','extattrib',$True,1,'extra')} | should throw
		}
		It "Gets networkview by reference" {
			$Result = [IB_networkview]::Get($Gridmaster,$Credential,'networkview/asdfioaweo3893jco:networkview2/False')
			$Result.GetType().Name | should be 'IB_NetworkView'
			$Result.Name | should be 'networkview2'
			$Result.is_default | should be $False
			$Result.comment | should be 'Second networkview'
		}
		It "Gets all networkviews" {
			$Result = [IB_networkview]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_NetworkView[]'
			$Result.Count | should be 3
			#
			$Result[0].GetType().Name | should be 'IB_NetworkView'
			$Result[0]._ref | should be 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result[0].Name | should be 'default'
			$Result[0].comment | should be 'Default networkview'
			$Result[0].is_default | should be $True
			#
			$Result[1].GetType().Name | should be 'IB_NetworkView'
			$Result[1]._ref | should be 'networkview/asdfioaweo3893jco:networkview2/False'
			$Result[1].Name | should be 'networkview2'
			$Result[1].comment | should be 'Second networkview'
			$Result[1].is_default | should be $False
			#
			$Result[2].GetType().Name | should be 'IB_NetworkView'
			$Result[2]._ref | should be 'networkview/jkdfjover89345jh934:networkview3/False'
			$Result[2].Name | should be 'networkview3'
			$Result[2].comment | should be 'Third networkview'
			$Result[2].is_default | should be $False
		}
		It "Gets default networkview" {
			$Result = [IB_networkview]::Get($Gridmaster,$Credential,$Null,$True,$Null,$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_NetworkView[]'
			$Result._ref | should be 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result.Name | should be 'default'
			$Result.comment | should be 'Default networkview'
			$Result.is_default | should be $True
		}
		It "gets networkview with strict name search" {
			$Result = [IB_networkview]::Get($Gridmaster,$Credential,'default',$Null,$Null,$Null,$True,$Null)
			$Result.GetType().Name | should be 'IB_NetworkView[]'
			$Result._ref | should be 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result.Name | should be 'default'
			$Result.comment | should be 'Default networkview'
			$Result.is_default | should be $True
		}
		It "gets networkviews with non-strict name search" {
			$Result = [IB_networkview]::Get($Gridmaster,$Credential,'networkview',$Null,$Null,$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_NetworkView[]'
			$Result.count | should be 2
			#
			$Result[0].GetType().Name | should be 'IB_NetworkView'
			$Result[0]._ref | should be 'networkview/asdfioaweo3893jco:networkview2/False'
			$Result[0].Name | should be 'networkview2'
			$Result[0].comment | should be 'Second networkview'
			$Result[0].is_default | should be $False
			#
			$Result[1].GetType().Name | should be 'IB_NetworkView'
			$Result[1]._ref | should be 'networkview/jkdfjover89345jh934:networkview3/False'
			$Result[1].Name | should be 'networkview3'
			$Result[1].comment | should be 'Third networkview'
			$Result[1].is_default | should be $False
		}
		It "gets non-default networkviews with is_default search" {
			$Result = [IB_networkview]::Get($gridmaster,$Credential,$Null,$False,$Null,$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_NetworkView[]'
			$Result.count | should be 2
			#
			$Result[0].GetType().Name | should be 'IB_NetworkView'
			$Result[0]._ref | should be 'networkview/asdfioaweo3893jco:networkview2/False'
			$Result[0].Name | should be 'networkview2'
			$Result[0].comment | should be 'Second networkview'
			$Result[0].is_default | should be $False
			#
			$Result[1].GetType().Name | should be 'IB_NetworkView'
			$Result[1]._ref | should be 'networkview/jkdfjover89345jh934:networkview3/False'
			$Result[1].Name | should be 'networkview3'
			$Result[1].comment | should be 'Third networkview'
			$Result[1].is_default | should be $False
		}
		It "gets first networkview with no query but resultscount of 1" {
			$Result = [IB_networkview]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$Null,1)
			$Result.GetType().Name | should be 'IB_NetworkView[]'
			$Result._ref | should be 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result.Name | should be 'default'
			$Result.comment | should be 'Default networkview'
			$Result.is_default | should be $True
		}
		It "gets networkview with strict comment search" {
			$Result = [IB_networkview]::Get($Gridmaster,$Credential,$Null,$Null,'Second networkview',$Null,$True,$Null)
			$Result.GetType().Name | should be 'IB_NetworkView[]'
			$Result._ref | should be 'networkview/asdfioaweo3893jco:networkview2/False'
			$Result.Name | should be 'networkview2'
			$Result.comment | should be 'Second networkview'
			$Result.is_default | should be $False
		}
		It "gets networkview with non-strict comment search" {
			$Result = [IB_networkview]::Get($Gridmaster,$Credential,$Null,$Null,'Second networkview',$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_NetworkView[]'
			$Result._ref | should be 'networkview/asdfioaweo3893jco:networkview2/False'
			$Result.Name | should be 'networkview2'
			$Result.comment | should be 'Second networkview'
			$Result.is_default | should be $False
		}
		It "gets networkview with non-strict name and comment search" {
			$Result = [IB_networkview]::Get($Gridmaster,$Credential,'default',$Null,'Default networkview',$Null,$False,$Null)
			$Result.GetType().Name | should be 'IB_NetworkView[]'
			$Result._ref | should be 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result.Name | should be 'default'
			$Result.comment | should be 'Default networkview'
			$Result.is_default | should be $True
		}
		It "gets networkview with strict name, comment and is_default search" {
			$Result = [IB_networkview]::Get($Gridmaster,$Credential,'default',$True,'Default networkview',$Null,$True,$Null)
			$Result.GetType().Name | should be 'IB_NetworkView[]'
			$Result._ref | should be 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
			$Result.Name | should be 'default'
			$Result.comment | should be 'Default networkview'
			$Result.is_default | should be $True
		}
	}
	Context 'ToString Method' {
		$Result = [IB_networkview]::Get($Gridmaster,$Credential,'networkview/asdfioaweo3893jco:networkview2/False')
		$Result.ToString() | should be 'networkview2'

	}
}
Describe "IB_FixedAddress tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Put'} {
		Mock-InfobloxPut -uri $Uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Post'} {
		Mock-InfobloxPost -uri $uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Delete'} {
	$uri | Mock-InfobloxDelete
	}
	Context 'Get Method' {
		It "Throws error with invalid credential object" {
			{[IB_FixedAddress]::Get($Gridmaster,'notacredential','refstring')} | should Throw
			{[IB_FixedAddress]::Get($gridmaster,'notacredential',$null,$Null,$Null,$Null,$False,$Null)} | should throw
		}
		It "Throws error with invalid IP Address object" {
			{[IB_FixedAddress]::Get($gridmaster,$Credential,'notanIP',$Null,$Null,$Null,$False,$Null)} | should throw
		}
		It "Throws error with invalid integer object" {
			{[IB_FixedAddress]::Get($gridmaster,$Credential,'1.1.1.1',$Null,$Null,$Null,$False,'notanint')} | should throw		
		}
		It "Throws error with less than 3 parameters" {
			{[IB_FixedAddress]::Get($Gridmaster,$Credential)} | should Throw
		}
		It "Throws error with more than 3 but less than 9 parameters" {
			{[IB_FixedAddress]::Get($Gridmaster,$Credential,'refstring','extra')} | should Throw
		}
		It "Throws error with more than 9 parameters" {
			{[IB_FixedAddress]::Get($gridmaster,$Credential,$null,$Null,$Null,$Null,$Null,$False,$Null,'extra')} | should throw

		}
		It "returns fixed address from ref query" {
			$Return = [IB_FixedAddress]::Get($Gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "returns all fixed addresses from null query" {
			$Return = [IB_FixedAddress]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$Null,$Null,$Null)
			$Return.GetType().Name | should be 'IB_FixedAddress[]'
			$Return.Count | should be 3
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return[0].name | should be 'testrecord.domain.com'
			$Return[0].IPAddress | should be '1.1.1.1'
			$Return[0].comment | should be 'test comment'
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '00:00:00:00:00:00'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1]._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
			$Return[1].name | should be 'testrecord.domain.com'
			$Return[1].IPAddress | should be '1.2.3.4'
			$Return[1].comment | should be 'test comment 2'
			$Return[1].networkview | should be 'default'
			$Return[1].MAC | should be '00:00:00:00:00:00'
			#
			$Return[2].GetType().Name | should be 'IB_FixedAddress'
			$Return[2]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2/networkview3'
			$Return[2].name | should be 'testrecord2.domain.com'
			$Return[2].IPAddress | should be '2.2.2.2'
			$Return[2].comment | should benullorempty
			$Return[2].networkview | should be 'networkview3'
			$Return[2].MAC | should be '00:00:00:00:00:11'
		}
		It "Returns fixed address from IP Address query" {
			$Return = [IB_FixedAddress]::Get($Gridmaster,$Credential,'1.2.3.4',$Null,$Null,$Null,$Null,$Null,$Null)
			$Return.GetType().Name | should be 'IB_FixedAddress[]'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.IPAddress | should be '1.2.3.4'
			$Return.comment | should be 'test comment 2'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "Returns fixed addresses from MAC address query" {
			$Return = [IB_FixedAddress]::Get($Gridmaster,$Credential,$Null,'00:00:00:00:00:00',$Null,$Null,$Null,$Null,$Null)
			$Return.GetType().Name | should be 'IB_FixedAddress[]'
			$Return.Count | should be 2
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return[0].name | should be 'testrecord.domain.com'
			$Return[0].IPAddress | should be '1.1.1.1'
			$Return[0].comment | should be 'test comment'
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '00:00:00:00:00:00'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1]._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
			$Return[1].name | should be 'testrecord.domain.com'
			$Return[1].IPAddress | should be '1.2.3.4'
			$Return[1].comment | should be 'test comment 2'
			$Return[1].networkview | should be 'default'
			$Return[1].MAC | should be '00:00:00:00:00:00'
		}
		It "Returns fixed addresses from non-strict comment query" {
			$Return = [IB_FixedAddress]::Get($Gridmaster,$Credential,$Null,$Null,'test comment',$Null,$Null,$False,$Null)
			$Return.GetType().Name | should be 'IB_FixedAddress[]'
			$Return.Count | should be 2
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return[0].name | should be 'testrecord.domain.com'
			$Return[0].IPAddress | should be '1.1.1.1'
			$Return[0].comment | should be 'test comment'
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '00:00:00:00:00:00'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1]._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
			$Return[1].name | should be 'testrecord.domain.com'
			$Return[1].IPAddress | should be '1.2.3.4'
			$Return[1].comment | should be 'test comment 2'
			$Return[1].networkview | should be 'default'
			$Return[1].MAC | should be '00:00:00:00:00:00'
		}
		It "Returns fixed address from strict comment query" {
			$Return = [IB_FixedAddress]::Get($Gridmaster,$Credential,$Null,$Null,'test comment',$Null,$Null,$True,$Null)
			$Return.GetType().Name | should be 'IB_FixedAddress[]'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'

		}
		It "Returns fixed addresses from networkview query" {
			$Return = [IB_FixedAddress]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,'default',$False,$Null)
			$Return.GetType().Name | should be 'IB_FixedAddress[]'
			$Return.Count | should be 2
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return[0].name | should be 'testrecord.domain.com'
			$Return[0].IPAddress | should be '1.1.1.1'
			$Return[0].comment | should be 'test comment'
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '00:00:00:00:00:00'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1]._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
			$Return[1].name | should be 'testrecord.domain.com'
			$Return[1].IPAddress | should be '1.2.3.4'
			$Return[1].comment | should be 'test comment 2'
			$Return[1].networkview | should be 'default'
			$Return[1].MAC | should be '00:00:00:00:00:00'
		}
		It "returns fixed address from IP and MAC address query" {
			$Return = [IB_FixedAddress]::Get($Gridmaster,$Credential,'1.1.1.1','00:00:00:00:00:00',$Null,$Null,$Null,$False,$Null)
			$Return.GetType().Name | should be 'IB_FixedAddress[]'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "returns fixed address from IP and networkview query" {
			$Return = [IB_FixedAddress]::Get($Gridmaster,$Credential,'1.1.1.1',$Null,$Null,$Null,'default',$False,$Null)
			$Return.GetType().Name | should be 'IB_FixedAddress[]'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "returns fixed address from IP, comment and networkview query" {
			$Return = [IB_FixedAddress]::Get($Gridmaster,$Credential,'1.1.1.1',$Null,'test comment',$Null,'default',$False,$Null)
			$Return.GetType().Name | should be 'IB_FixedAddress[]'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "returns fixed address from no query but resultscount set to 1" {
			$Return = [IB_FixedAddress]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,$Null,$False,1)
			$Return.GetType().Name | should be 'IB_FixedAddress[]'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
	}
	Context 'Set Method' {
		It "Throws error with less than 3 parameters" {
			$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
			{$TestRecord.Set($Null,$Null)} | should throw
		}
		It "Throws error with more than 3 parameters" {
			$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
			{$TestRecord.Set($Null,$Null,$Null,$Null)} | should throw

		}
		It "sets name, comment and MAC on existing fixedaddress object" {
			$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
			$TestRecord.Set('newrecordname.domain.com','new record comment','00:00:00:00:00:00')
			$TestRecord.GetType().Name | should be 'IB_FixedAddress'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be 'newrecordname.domain.com'
			$TestRecord.comment | should be 'new record comment'
			$TestRecord.MAC | should be '00:00:00:00:00:00'
			$TestRecord.NetworkView | should be 'default'
		}
		It "sets comment to null on existing fixedaddress object" {
			$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
			$TestRecord.Set('newrecordname.domain.com',$Null,'00:00:00:00:00:00')
			$TestRecord.GetType().Name | should be 'IB_FixedAddress'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be 'newrecordname.domain.com'
			$TestRecord.comment | should benullorempty
			$TestRecord.MAC | should be '00:00:00:00:00:00'
			$TestRecord.NetworkView | should be 'default'

		}
		It "sets name to null on existing fixedaddress object" {
			$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
			$TestRecord.Set($Null,'new record comment','00:00:00:00:00:00')
			$TestRecord.GetType().Name | should be 'IB_FixedAddress'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should benullorempty
			$TestRecord.comment | should be 'new record comment'
			$TestRecord.MAC | should be '00:00:00:00:00:00'
			$TestRecord.NetworkView | should be 'default'
		}
		It "sets MAC to non-zero value on existing fixedaddress object" {
			$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
			$TestRecord.Set('newrecordname.domain.com','new record comment','11:11:11:11:11:11')
			$TestRecord.GetType().Name | should be 'IB_FixedAddress'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be 'newrecordname.domain.com'
			$TestRecord.comment | should be 'new record comment'
			$TestRecord.MAC | should be '11:11:11:11:11:11'
			$TestRecord.NetworkView | should be 'default'
		}
		It "Sets MAC to zero value on existing fixedaddress object" {
			$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2/networkview3')
			$TestRecord.Set('newrecordname.domain.com','new record comment','00:00:00:00:00:00')
			$TestRecord.GetType().Name | should be 'IB_FixedAddress'
			$TestRecord.IPAddress | should be '2.2.2.2'
			$TestRecord.Name | should be 'newrecordname.domain.com'
			$TestRecord.comment | should be 'new record comment'
			$TestRecord.MAC | should be '00:00:00:00:00:00'
			$TestRecord.NetworkView | should be 'networkview3'
		}
	}
	Context 'Create Method' {
		It "Throws error with invalid credential object" {
			{[IB_FixedAddress]::Create($Gridmaster,'notacredential','name','1.1.1.1',$Null,$Null,$Null)} | should throw
		}
		It "Throws error with invalid IP Address object" {
			{[IB_FixedAddress]::Create($Gridmaster,$Credential,'name','notanIP',$Null,$Null,$Null)} | should throw
		}
		It "throws error with less than 7 properties" {
			{[IB_FixedAddress]::Create($Gridmaster,$Credential,'name','1.1.1.1',$Null,$Null)} | should throw
		}
		It "throws error with more than 7 properties" {
			{[IB_FixedAddress]::Create($Gridmaster,$Credential,'name','1.1.1.1',$Null,$Null,$Null,'extra')} | should throw
		}
		It "creates fixedaddress with no name or comment and zero mac in default view" {
			$TestRecord = [IB_FixedAddress]::Create($Gridmaster,$Credential,$Null,'10.1.1.1',$Null,$Null,$Null)
			$TestRecord.GetType().name | Should be 'IB_FixedAddress'
			$TestRecord.IPAddress | should be '10.1.1.1'
			$TestRecord.Name | should benullorempty
			$TestRecord.Comment | should benullorempty
			$TestRecord.mac | should be '00:00:00:00:00:00'
			$TestRecord.NetworkView | should be 'default'
		}
		It "creates fixedaddress with no name or comment and non-zero mac in default view" {
			$TestRecord = [IB_FixedAddress]::Create($Gridmaster,$Credential,$Null,'10.1.1.2',$Null,$Null,'11:11:11:11:11:11')
			$TestRecord.GetType().name | Should be 'IB_FixedAddress'
			$TestRecord.IPAddress | should be '10.1.1.2'
			$TestRecord.Name | should benullorempty
			$TestRecord.Comment | should benullorempty
			$TestRecord.mac | should be '11:11:11:11:11:11'
			$TestRecord.NetworkView | should be 'default'
		}
		It "Creates fixedaddress with name, no comment and zero mac in default view" {
			$TestRecord = [IB_FixedAddress]::Create($Gridmaster,$Credential,'newtestrecord','10.1.1.3',$Null,$Null,'00:00:00:00:00:00')
			$TestRecord.GetType().name | Should be 'IB_FixedAddress'
			$TestRecord.IPAddress | should be '10.1.1.3'
			$TestRecord.Name | should be 'newtestrecord'
			$TestRecord.Comment | should benullorempty
			$TestRecord.mac | should be '00:00:00:00:00:00'
			$TestRecord.NetworkView | should be 'default'
		}
		It "Creates fixedaddress with name and comment and non-zero mac in default view" {
			$TestRecord = [IB_FixedAddress]::Create($Gridmaster,$Credential,'newtestrecord','10.1.1.4','comment',$Null,'11:11:11:11:11:11')
			$TestRecord.GetType().name | Should be 'IB_FixedAddress'
			$TestRecord.IPAddress | should be '10.1.1.4'
			$TestRecord.Name | should be 'newtestrecord'
			$TestRecord.Comment | should be 'comment'
			$TestRecord.mac | should be '11:11:11:11:11:11'
			$TestRecord.NetworkView | should be 'default'
		}
		It "creates fixedaddress with comment, no name and non-zero mac in specified view" {
			$TestRecord = [IB_FixedAddress]::Create($Gridmaster,$Credential,$Null,'10.1.1.5','comment','networkview3','11:11:11:11:11:11')
			$TestRecord.GetType().name | Should be 'IB_FixedAddress'
			$TestRecord.IPAddress | should be '10.1.1.5'
			$TestRecord.Name | should benullorempty
			$TestRecord.Comment | should be 'comment'
			$TestRecord.mac | should be '11:11:11:11:11:11'
			$TestRecord.NetworkView | should be 'networkview3'
		}
	}
	Context "AddExtAttrib Method" {
		It "Adds extensible attribute" {
			$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default')
			$TestRecord.AddExtAttrib('Site','corp')
			$TestRecord.ExtAttrib.Name | should be 'Site'
			$TestRecord.ExtAttrib.value | should be 'corp'
		}
		It "Updates the value of an existing extensible attribute" {
			$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
			$TestRecord.AddExtAttrib('Site','gulf')
			$TestRecord.AddExtAttrib | measure-object | select -ExpandProperty Count | should be 1
			$TestRecord.ExtAttrib.Name | should be 'Site'
			$TestRecord.ExtAttrib.value | should be 'gulf'
		}
	}
	Context "RemoveExtAttrib Method" {
		It "Removes extensible attribute" {
			$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
			$TestRecord.RemoveExtAttrib('Site')
			$TestRecord.ExtAttrib | should benullorempty
		}	
	}
	Context 'Delete Method' {
		$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
		It "Deletes record with refstring fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default" {
			$TestRecord.Delete() | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			[IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default') |
				should benullorempty
		}
	}
}
Describe "IB_ReferenceObject tests" {
$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Delete'} {
		$uri | Mock-InfobloxDelete
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	Context 'Get Method' {
		It 'Throws error with invalid credential property' {
			{[IB_ReferenceObject]::Get($Gridmaster,'notacredential','record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')} |
				Should Throw
		}
		It 'Throws error with less than 3 parameters' {
			{[IB_ReferenceObject]::Get($gridmaster,$Credential)} | should Throw
		}
		It 'Throws error with more than 3 parameters' {
			{[IB_ReferenceObject]::Get($Gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default','extra')} |
				Should Throw
		}
		It 'returns ReferenceObject from Get by ref' {
			$Return = [IB_ReferenceObject]::Get($Gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
			$Return.GetType().Name | should be 'IB_ReferenceObject'
			$Return._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		}
	}
	Context 'Delete Method' {
		It "Deletes record with refstring record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default" {
			$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default')
			$TestRecord.Delete() | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
			[IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default') |
				should benullorempty
		}

	}
}
Describe "Get-InfobloxView tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}

	It "returns dnsview with specified refstring" {
		$Result = Get-InfobloxView -Gridmaster $gridmaster -Credential $credential -_Ref 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result.GetType().Name | should be 'IB_View'
		$Result.Name | should be 'default'
		$Result.Comment | should be 'Default view'
		$Result.is_default | should be $True
	}
	It "returns networkview with specified refstring" {
		$Result = Get-InfobloxView -Gridmaster $gridmaster -Credential $credential -_Ref 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result.GetType().Name | should be 'IB_networkView'
		$Result.Name | should be 'default'
		$Result.Comment | should be 'Default networkview'
		$Result.is_default | should be $True
	}
	It "returns default networkview" {
		$Result = Get-InfobloxView -Gridmaster $gridmaster -credential $credential -Type NetworkView -IsDefault $True
		$Result.GetType().Name | should be 'IB_networkView'
		$Result.Name | should be 'default'
		$Result.Comment | should be 'Default networkview'
		$Result.is_default | should be $True
	}
	It "returns non-default networkviews" {
		$Result = Get-InfobloxView -Gridmaster $gridmaster -Credential $credential -Type NetworkView -IsDefault $False
		$Result.count | should be 2
		#
		$Result[0].GetType().Name | should be 'IB_NetworkView'
		$Result[0]._ref | should be 'networkview/asdfioaweo3893jco:networkview2/False'
		$Result[0].Name | should be 'networkview2'
		$Result[0].comment | should be 'Second networkview'
		$Result[0].is_default | should be $False
		#
		$Result[1].GetType().Name | should be 'IB_NetworkView'
		$Result[1]._ref | should be 'networkview/jkdfjover89345jh934:networkview3/False'
		$Result[1].Name | should be 'networkview3'
		$Result[1].comment | should be 'Third networkview'
		$Result[1].is_default | should be $False

	}
	It "returns default dnsview" {
		$Result = Get-InfobloxView -Gridmaster $gridmaster -credential $credential -Type DNSView -IsDefault $True
		$Result.GetType().Name | should be 'IB_View'
		$Result.Name | should be 'default'
		$Result.Comment | should be 'Default view'
		$Result.is_default | should be $True

	}
	It "returns non-default dnsviews" {
		$Result = Get-InfobloxView -Gridmaster $gridmaster -credential $credential -Type DNSView -IsDefault $False
		$Result.count | should be 2
		#
		$Result[0].GetType().Name | should be 'IB_View'
		$Result[0]._ref | should be 'view/asdfioaweo3893jco:view2/False'
		$Result[0].Name | should be 'view2'
		$Result[0].comment | should be 'Second View'
		$Result[0].is_default | should be $False
		#
		$Result[1].GetType().Name | should be 'IB_View'
		$Result[1]._ref | should be 'view/jkdfjover89345jh934:view3/False'
		$Result[1].Name | should be 'view3'
		$Result[1].comment | should be 'Third View'
		$Result[1].is_default | should be $False
	}
	It "throws error with invalid Type value" {
		{Get-infobloxview -Gridmaster $gridmaster -Credential $credential -type 'badtype'} | should throw
	}
	It "returns all dns views with no other parameters" {
		$Result = Get-infobloxview -gridmaster $Gridmaster -Credential $Credential -Type DNSView
		$Result.Count | should be 3
		#
		$Result[0].GetType().Name | should be 'IB_View'
		$Result[0]._ref | should be 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result[0].Name | should be 'default'
		$Result[0].comment | should be 'Default view'
		$Result[0].is_default | should be $True
		#
		$Result[1].GetType().Name | should be 'IB_View'
		$Result[1]._ref | should be 'view/asdfioaweo3893jco:view2/False'
		$Result[1].Name | should be 'view2'
		$Result[1].comment | should be 'Second View'
		$Result[1].is_default | should be $False
		#
		$Result[2].GetType().Name | should be 'IB_View'
		$Result[2]._ref | should be 'view/jkdfjover89345jh934:view3/False'
		$Result[2].Name | should be 'view3'
		$Result[2].comment | should be 'Third View'
		$Result[2].is_default | should be $False

	}
	It "returns all network views with no other parameters" {
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView
		$Result.Count | should be 3
		#
		$Result[0].GetType().Name | should be 'IB_NetworkView'
		$Result[0]._ref | should be 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result[0].Name | should be 'default'
		$Result[0].comment | should be 'Default networkview'
		$Result[0].is_default | should be $True
		#
		$Result[1].GetType().Name | should be 'IB_NetworkView'
		$Result[1]._ref | should be 'networkview/asdfioaweo3893jco:networkview2/False'
		$Result[1].Name | should be 'networkview2'
		$Result[1].comment | should be 'Second networkview'
		$Result[1].is_default | should be $False
		#
		$Result[2].GetType().Name | should be 'IB_NetworkView'
		$Result[2]._ref | should be 'networkview/jkdfjover89345jh934:networkview3/False'
		$Result[2].Name | should be 'networkview3'
		$Result[2].comment | should be 'Third networkview'
		$Result[2].is_default | should be $False
	}
	It "returns dns view with specified name parameter" {
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -Name 'default'
		$Result.GetType().Name | should be 'IB_View'
		$Result._ref | should be 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result.Name | should be 'default'
		$Result.comment | should be 'Default view'
		$Result.is_default | should be $True
	}
	It "returns network view with specified name parameter" {
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Name 'default'
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result._ref | should be 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result.Name | should be 'default'
		$Result.comment | should be 'Default networkview'
		$Result.is_default | should be $True
	}
	It "returns dns views with non-strict name search" {
		$result = Get-InfobloxView -Gridmaster $gridmaster -Credential $Credential -Type DNSView -Name 'view'
		$result.count | should be 2
		#
		$Result[0].GetType().Name | should be 'IB_View'
		$Result[0]._ref | should be 'view/asdfioaweo3893jco:view2/False'
		$Result[0].Name | should be 'view2'
		$Result[0].comment | should be 'Second View'
		$Result[0].is_default | should be $False
		#
		$Result[1].GetType().Name | should be 'IB_View'
		$Result[1]._ref | should be 'view/jkdfjover89345jh934:view3/False'
		$Result[1].Name | should be 'view3'
		$Result[1].comment | should be 'Third View'
		$Result[1].is_default | should be $False
	}
	It "returns network views with non-strict name search" {
		$result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Name 'networkview'
		$result.count | should be 2
		#
		$Result[0].GetType().Name | should be 'IB_NetworkView'
		$Result[0]._ref | should be 'networkview/asdfioaweo3893jco:networkview2/False'
		$Result[0].Name | should be 'networkview2'
		$Result[0].comment | should be 'Second networkview'
		$Result[0].is_default | should be $False
		#
		$Result[1].GetType().Name | should be 'IB_NetworkView'
		$Result[1]._ref | should be 'networkview/jkdfjover89345jh934:networkview3/False'
		$Result[1].Name | should be 'networkview3'
		$Result[1].comment | should be 'Third networkview'
		$Result[1].is_default | should be $False
	}
	It "returns null from dnsview type strict name search with zero matches" {
		$result = Get-InfobloxView -Gridmaster $gridmaster -Credential $Credential -Type DNSView -Name 'view' -Strict
		$Result | should benullorempty
	}
	It "returns null from networkview type strict name search with zero matches" {
		$result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Name 'networkview' -Strict
		$Result | should benullorempty
	}
	It "gets first dnsview with no query but resultscount of 1" {
		#$Result = [IB_View]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,1)
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -MaxResults 1
		$Result.GetType().Name | should be 'IB_View'
		$Result._ref | should be 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result.Name | should be 'default'
		$Result.comment | should be 'Default view'
		$Result.is_default | should be $True
	}
	It "gets dnsview with strict comment search" {
		#$Result = [IB_View]::Get($Gridmaster,$Credential,$Null,$Null,'Second View',$True,$Null)
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -Comment 'Second View' -Strict
		$Result.GetType().Name | should be 'IB_View'
		$Result._ref | should be 'view/asdfioaweo3893jco:view2/False'
		$Result.Name | should be 'view2'
		$Result.comment | should be 'Second View'
		$Result.is_default | should be $False
	}
	It "gets dnsview with non-strict comment search" {
		#$Result = [IB_View]::Get($Gridmaster,$Credential,$Null,$Null,'Second View',$False,$Null)
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -Comment 'Second View'
		$Result.GetType().Name | should be 'IB_View'
		$Result._ref | should be 'view/asdfioaweo3893jco:view2/False'
		$Result.Name | should be 'view2'
		$Result.comment | should be 'Second View'
		$Result.is_default | should be $False
	}
	It "gets dnsview with non-strict name and comment search" {
		#$Result = [IB_View]::Get($Gridmaster,$Credential,'default',$Null,'Default View',$False,$Null)
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -Name 'default' -Comment 'Default View'
		$Result.GetType().Name | should be 'IB_View'
		$Result._ref | should be 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result.Name | should be 'default'
		$Result.comment | should be 'Default view'
		$Result.is_default | should be $True
	}
	It "gets dnsview with strict name, comment and is_default search" {
		#$Result = [IB_View]::Get($Gridmaster,$Credential,'default',$True,'Default View',$False,$Null)
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -Name 'default' -Comment 'Default View' -IsDefault 'True'
		$Result.GetType().Name | should be 'IB_View'
		$Result._ref | should be 'view/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result.Name | should be 'default'
		$Result.comment | should be 'Default view'
		$Result.is_default | should be $True
	}
	It "gets first networkview with no query but resultscount of 1" {
		#$Result = [IB_networkview]::Get($Gridmaster,$Credential,$Null,$Null,$Null,$Null,1)
		$Result = get-infobloxview -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -MaxResults 1
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result._ref | should be 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result.Name | should be 'default'
		$Result.comment | should be 'Default networkview'
		$Result.is_default | should be $True
	}
	It "gets networkview with strict comment search" {
		#$Result = [IB_networkview]::Get($Gridmaster,$Credential,$Null,$Null,'Second networkview',$True,$Null)
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -comment 'Second networkview' -strict
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result._ref | should be 'networkview/asdfioaweo3893jco:networkview2/False'
		$Result.Name | should be 'networkview2'
		$Result.comment | should be 'Second networkview'
		$Result.is_default | should be $False
	}
	It "gets networkview with non-strict comment search" {
		#$Result = [IB_networkview]::Get($Gridmaster,$Credential,$Null,$Null,'Second networkview',$False,$Null)
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Comment 'Second networkview'
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result._ref | should be 'networkview/asdfioaweo3893jco:networkview2/False'
		$Result.Name | should be 'networkview2'
		$Result.comment | should be 'Second networkview'
		$Result.is_default | should be $False
	}
	It "gets networkview with non-strict name and comment search" {
		#$Result = [IB_networkview]::Get($Gridmaster,$Credential,'default',$Null,'Default networkview',$False,$Null)
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Name default -comment 'Default networkview'
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result._ref | should be 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result.Name | should be 'default'
		$Result.comment | should be 'Default networkview'
		$Result.is_default | should be $True
	}
	It "gets networkview with strict name, comment and is_default search" {
		#$Result = [IB_networkview]::Get($Gridmaster,$Credential,'default',$True,'Default networkview',$False,$Null)
		$Result = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Name default -comment 'Default networkview' -Strict -isdefault True
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result._ref | should be 'networkview/ZG5zLm5ldHdvcmtfdmlldyQw:default/true'
		$Result.Name | should be 'default'
		$Result.comment | should be 'Default networkview'
		$Result.is_default | should be $True
	}

}
Describe "Find-InfobloxRecord" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "returns records from non-strict Name search" {
		$return = Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString testrecord
		$Return.count | should be 12
		#
		$Return[0].GetType().Name | should be 'IB_DNSARecord'
		$Return[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		#
		$Return[2].GetType().Name | should be 'IB_DNSARecord'
		$Return[2]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3'
		#
		$Return[3].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[3]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		#
		$Return[4].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[4]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
		#
		$Return[5].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[5]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJfZGVmY2:testalias2.domain.com/view3'
		#
		$Return[6].GetType().Name | should be 'IB_FixedAddress'
		$Return[6]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		#
		$Return[7].GetType().Name | should be 'IB_FixedAddress'
		$Return[7]._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
		#
		$Return[8].GetType().Name | should be 'IB_FixedAddress'
		$Return[8]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2/networkview3'
		#
		$Return[9].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[9]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		#
		$Return[10].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[10]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
		#
		$Return[11].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[11]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2.in-addr.arpa/view3'
	}
	It "returns a records with non-strict name and type search" {
		$return = Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString testrecord -Recordtype 'record:a'
		$return.count | should be 3
		#
		$Return[0].GetType().Name | should be 'IB_DNSARecord'
		$Return[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		#
		$Return[2].GetType().Name | should be 'IB_DNSARecord'
		$Return[2]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3'
	}
	It "returns records from IPAddress search" {
		$Return = Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress '1.1.1.1'
		$Return.count | should be 4
		#
		$Return[0].GetType().Name | should be 'IB_DNSARecord'
		$Return[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		#
		$Return[2].GetType().Name | should be 'IB_FixedAddress'
		$Return[2]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		#
		$Return[3].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[3]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "throws error from IPAddress and type search" {
		{Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress '1.1.1.1' -Recordtype fixedaddress} | should throw
	}
	It "returns records from strict name search" {
		$return = Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString testrecord.domain.com -Strict
		$Return.count | should be 7
		#
		$Return[0].GetType().Name | should be 'IB_DNSARecord'
		$Return[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[1]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		#
		$Return[2].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[2]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
		#
		$Return[3].GetType().Name | should be 'IB_FixedAddress'
		$Return[3]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		#
		$Return[4].GetType().Name | should be 'IB_FixedAddress'
		$Return[4]._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
		#
		$Return[5].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[5]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		#
		$Return[6].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[6]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
	}
	It "returns cname records from strict name and type search" {
		$return = Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString testrecord.domain.com -Strict -Recordtype 'record:cname'
		$Return.count | should be 2
		$Return[0].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
	}
	It "returns records from IPAddress search through the pipeline" {
		$Return = '1.1.1.1' | Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential
		$Return.count | should be 4
		#
		$Return[0].GetType().Name | should be 'IB_DNSARecord'
		$Return[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		#
		$Return[2].GetType().Name | should be 'IB_FixedAddress'
		$Return[2]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		#
		$Return[3].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[3]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "returns records from multiple IPAddress search through the pipeline" {
		$Return = @('1.1.1.1','2.2.2.2') | Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential
		$Return.count | should be 7
		#
		$Return[0].GetType().Name | should be 'IB_DNSARecord'
		$Return[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		#
		$Return[2].GetType().Name | should be 'IB_FixedAddress'
		$Return[2]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		#
		$Return[3].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[3]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		#
		$Return[4].GetType().Name | should be 'IB_DNSARecord'
		$Return[4]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3'
		#
		$Return[5].GetType().Name | should be 'IB_FixedAddress'
		$Return[5]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2/networkview3'
		#
		$Return[6].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[6]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2.in-addr.arpa/view3'
	}
	It "returns records from strict name search through the pipeline" {
		$Return = 'testrecord3.domain.com' | Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -Strict
		$Return.Count | should be 1
		$Return.GetType().Name | should be 'IB_DNSARecord'
		$Return._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
	}
	It "returns records from multiple strict name search through the pipeline" {
		$Return = @('testrecord3.domain.com','testrecord2.domain.com') | Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -Strict
		$Return.Count | should be 5
		#
		$Return[0].GetType().Name | should be 'IB_DNSARecord'
		$Return[0]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3'
		#
		$Return[2].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[2]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJfZGVmY2:testalias2.domain.com/view3'
		#
		$Return[3].GetType().Name | should be 'IB_FixedAddress'
		$Return[3]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2/networkview3'
		#
		$Return[4].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[4]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2.in-addr.arpa/view3'
	}
	It "throws error with both name and IPAddress parameter" {
		{Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -Name 'name' -ipaddress '1.1.1.1'} | should throw
	}
	It "throws error with invalid IPAddress object" {
		{Find-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress 'notanIP'} | should throw
	}
}
Describe "Get-DNSARecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData

	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws error with invalid credential object" {
		{Get-DNSARecord -gridmaster $gridmaster -credential 'notacredential'} | should throw
	}
	It "Throws error with invalid IP Address object" {
		{Get-DNSARecord -gridmaster $gridmaster -credential $Credential -IPAddress 'notanIPAddress'} | should throw
	}
	It "Throws error with invalid integer object" {
		{Get-DNSARecord -gridmaster $gridmaster -credential $Credential -maxResults 'notanInt'} | should throw
	}
	It "Throws error with empty gridmaster" {
		{Get-DNSARecord -gridmaster $Null -credential $Credential} | should throw
	}
	It "returns A record from ref query" {
		$TestRecord = Get-DNSARecord -gridmaster $Gridmaster -credential $Credential -_Ref 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.extattrib.Name | should be 'Site'
		$TestRecord.extattrib.Value | should be 'corp'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
	}
	It "Returns A record from strict name query" {
		$TestRecord = Get-DNSARecord -gridmaster $gridmaster -credential $credential -name 'testrecord.domain.com' -strict
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.extattrib.Name | should be 'Site'
		$TestRecord.extattrib.Value | should be 'corp'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
	}
	It "returns multiple A records from non-strict name query" {
		$TestRecord = Get-DNSARecord -gridmaster $gridmaster -credential $credential -name 'testrecord'
		$TestRecord.count | should be 3
		#
		$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[0].Name | should be 'testrecord.domain.com'
		$TestRecord[0].extattrib.Name | should be 'Site'
		$TestRecord[0].extattrib.Value | should be 'corp'
		$TestRecord[0].View | should be 'default'
		$TestRecord[0].IPAddress | should be '1.1.1.1'
		$TestRecord[0].Comment | should be 'test comment'
		$TestRecord[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord[0].TTL | should be 1200
		$TestRecord[0].Use_TTL | should be $True
		#
		$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[1].extattrib.Name | should be 'Site'
		$TestRecord[1].extattrib.Value | should be 'corp'
		$TestRecord[1].Name | should be 'testrecord3.domain.com'
		$TestRecord[1].View | should be 'default'
		$TestRecord[1].IPAddress | should be '1.1.1.1'
		$TestRecord[1].Comment | should be 'test comment 2'
		$TestRecord[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		$TestRecord[1].TTL | should be 1200
		$TestRecord[1].Use_TTL | should be $True
		#
		$TestRecord[2].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[2].Name | should be 'testrecord2.domain.com'
		$TestRecord[2].View | should be 'view3'
		$TestRecord[2].IPAddress | should be '2.2.2.2'
		$TestRecord[2].Comment | should benullorempty
		$TestRecord[2]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3'
		$TestRecord[2].TTL | should be 0
		$TestRecord[2].Use_TTL | should be $False

	}
	It "Returns multiple A records from zone query" {
		$TestRecord = Get-DNSARecord -gridmaster $gridmaster -credential $Credential -zone 'domain.com'
		$TestRecord.count | should be 3
		#
		$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[0].Name | should be 'testrecord.domain.com'
		$TestRecord[0].extattrib.Name | should be 'Site'
		$TestRecord[0].extattrib.Value | should be 'corp'
		$TestRecord[0].View | should be 'default'
		$TestRecord[0].IPAddress | should be '1.1.1.1'
		$TestRecord[0].Comment | should be 'test comment'
		$TestRecord[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord[0].TTL | should be 1200
		$TestRecord[0].Use_TTL | should be $True
		#
		$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[1].Name | should be 'testrecord3.domain.com'
		$TestRecord[1].extattrib.Name | should be 'Site'
		$TestRecord[1].extattrib.Value | should be 'corp'
		$TestRecord[1].View | should be 'default'
		$TestRecord[1].IPAddress | should be '1.1.1.1'
		$TestRecord[1].Comment | should be 'test comment 2'
		$TestRecord[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		$TestRecord[1].TTL | should be 1200
		$TestRecord[1].Use_TTL | should be $True
		#
		$TestRecord[2].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[2].Name | should be 'testrecord2.domain.com'
		$TestRecord[2].View | should be 'view3'
		$TestRecord[2].IPAddress | should be '2.2.2.2'
		$TestRecord[2].Comment | should benullorempty
		$TestRecord[2]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3'
		$TestRecord[2].TTL | should be 0
		$TestRecord[2].Use_TTL | should be $False

	}
	It "Returns multiple A records from IP Address query" {
		$TestRecord = Get-DNSARecord -gridmaster $gridmaster -credential $Credential -ipaddress '1.1.1.1'
		$TestRecord.count | should be 2
		#
		$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[0].Name | should be 'testrecord.domain.com'
		$TestRecord[0].extattrib.Name | should be 'Site'
		$TestRecord[0].extattrib.Value | should be 'corp'
		$TestRecord[0].View | should be 'default'
		$TestRecord[0].IPAddress | should be '1.1.1.1'
		$TestRecord[0].Comment | should be 'test comment'
		$TestRecord[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord[0].TTL | should be 1200
		$TestRecord[0].Use_TTL | should be $True
		#
		$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[1].Name | should be 'testrecord3.domain.com'
		$TestRecord[1].extattrib.Name | should be 'Site'
		$TestRecord[1].extattrib.Value | should be 'corp'
		$TestRecord[1].View | should be 'default'
		$TestRecord[1].IPAddress | should be '1.1.1.1'
		$TestRecord[1].Comment | should be 'test comment 2'
		$TestRecord[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		$TestRecord[1].TTL | should be 1200
		$TestRecord[1].Use_TTL | should be $True

	}
	It "Returns A record from view query" {
		$TestRecord = Get-DNSARecord -gridmaster $Gridmaster -credential $Credential -view 'view3'
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.View | should be 'view3'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.Comment | should benullorempty
		$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False

	}
	It "Returns A record from strict comment query" {
		$TestRecord = Get-DNSARecord -gridmaster $Gridmaster -credential $Credential -comment 'test comment' -strict
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.extattrib.Name | should be 'Site'
		$TestRecord.extattrib.Value | should be 'corp'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True

	}
	It "returns A record from non-strict comment query" {
		$TestRecord = Get-DNSARecord -gridmaster $Gridmaster -credential $Credential -comment 'test comment'
		$TestRecord.count | should be 2
		#
		$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[0].Name | should be 'testrecord.domain.com'
		$TestRecord[0].extattrib.Name | should be 'Site'
		$TestRecord[0].extattrib.Value | should be 'corp'
		$TestRecord[0].View | should be 'default'
		$TestRecord[0].IPAddress | should be '1.1.1.1'
		$TestRecord[0].Comment | should be 'test comment'
		$TestRecord[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord[0].TTL | should be 1200
		$TestRecord[0].Use_TTL | should be $True
		#
		$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[1].Name | should be 'testrecord3.domain.com'
		$TestRecord[1].View | should be 'default'
		$TestRecord[1].extattrib.Name | should be 'Site'
		$TestRecord[1].extattrib.Value | should be 'corp'
		$TestRecord[1].IPAddress | should be '1.1.1.1'
		$TestRecord[1].Comment | should be 'test comment 2'
		$TestRecord[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		$TestRecord[1].TTL | should be 1200
		$TestRecord[1].Use_TTL | should be $True
	}
	It "returns A record from extensible attribute search" {
		$TestRecord = Get-DNSARecord -gridmaster $Gridmaster -credential $Credential -ExtAttributeQuery {Site -eq 'corp'}
		$TestRecord.count | should be 2
		#
		$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[0].Name | should be 'testrecord.domain.com'
		$TestRecord[0].extattrib.Name | should be 'Site'
		$TestRecord[0].extattrib.Value | should be 'corp'
		$TestRecord[0].View | should be 'default'
		$TestRecord[0].IPAddress | should be '1.1.1.1'
		$TestRecord[0].Comment | should be 'test comment'
		$TestRecord[0]._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord[0].TTL | should be 1200
		$TestRecord[0].Use_TTL | should be $True
		#
		$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[1].Name | should be 'testrecord3.domain.com'
		$TestRecord[1].View | should be 'default'
		$TestRecord[1].extattrib.Name | should be 'Site'
		$TestRecord[1].extattrib.Value | should be 'corp'
		$TestRecord[1].IPAddress | should be '1.1.1.1'
		$TestRecord[1].Comment | should be 'test comment 2'
		$TestRecord[1]._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		$TestRecord[1].TTL | should be 1200
		$TestRecord[1].Use_TTL | should be $True
	}
	It "returns A record from non-strict name and comment query" {
		$TestRecord = Get-DNSARecord -credential $Credential -gridmaster $Gridmaster -name 'testrecord' -comment 'test comment 2'
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord3.domain.com'
		$TestRecord.extattrib.Name | should be 'Site'
		$TestRecord.extattrib.Value | should be 'corp'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment 2'
		$TestRecord._ref | should be 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
	}
	It "returns A record from strict name and IP Address query" {
		$TestRecord = Get-DNSARecord -gridmaster $Gridmaster -credential $Credential -name 'testrecord.domain.com' -ipaddress '1.1.1.1' -Strict
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.extattrib.Name | should be 'Site'
		$TestRecord.extattrib.Value | should be 'corp'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
	}
	It "returns A record from strict name and view query" {
		$TestRecord = Get-DNSARecord -gridmaster $Gridmaster -credential $Credential -name 'testrecord.domain.com' -view 'default' -strict
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.extattrib.Name | should be 'Site'
		$TestRecord.extattrib.Value | should be 'corp'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
	}
	It "returns A record from strict name and zone query" {
		$TestRecord = Get-DNSARecord -gridmaster $Gridmaster -credential $Credential -name 'testrecord.domain.com' -zone 'domain.com' -strict
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.extattrib.Name | should be 'Site'
		$TestRecord.extattrib.Value | should be 'corp'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True

	}
	It "returns A record from non-strict name query with results count of 1" {
		$TestRecord = Get-DNSARecord -gridmaster $gridmaster -credential $Credential -name 'testrecord' -maxResults 1
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.extattrib.Name | should be 'Site'
		$TestRecord.extattrib.Value | should be 'corp'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True

	}
}
Describe "Get-DNSCNameRecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	Context "Get Method" {

		It "Throws error with invalid credential object" {
			{Get-DNSCNameRecord -Gridmaster $gridmaster -credential 'notacredential'} | should throw
		}
		It "Throws error with invalid integer object" {
			{Get-DNSCNameRecord -gridmaster $gridmaster -credential $Credential -maxResults 'notanInt'} | should throw
		}
		It "throws error with empty gridmaster" {
			{Get-DNSCNameRecord -gridmaster $Null -credential $Credential} | should throw
		}
		It "returns CName Record from ref query" {
			$testalias = Get-DNSCNameRecord -gridmaster $gridmaster -credential $Credential -_Ref 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$Testalias.extattrib.Name | should be 'Site'
			$Testalias.extattrib.Value | should be 'corp'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True
		}
		It "Returns CName Record from strict name query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -name 'testalias.domain.com' -strict
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$Testalias.extattrib.Name | should be 'Site'
			$Testalias.extattrib.Value | should be 'corp'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True
		}
		It "returns multiple CName Records from non-strict name query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -name 'testalias'
			$testalias.count | should be 3
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$Testalias[0].extattrib.Name | should be 'Site'
			$Testalias[0].extattrib.Value | should be 'corp'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should be 'test comment'
			$testalias[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias[0].TTL | should be 1200
			$testalias[0].Use_TTL | should be $True
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias3.domain.com'
			$Testalias[1].extattrib.Name | should be 'Site'
			$Testalias[1].extattrib.Value | should be 'corp'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment 2'
			$testalias[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias[1].TTL | should be 1200
			$testalias[1].Use_TTL | should be $True
			#
			$testalias[2].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[2].Name | should be 'testalias2.domain.com'
			$testalias[2].View | should be 'view3'
			$testalias[2].canonical | should be 'testrecord2.domain.com'
			$testalias[2].Comment | should benullorempty
			$testalias[2]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJfZGVmY2:testalias2.domain.com/view3'
			$testalias[2].TTL | should be 0
			$testalias[2].Use_TTL | should be $False

		}
		It "returns multiple CName Records from non-strict canonical query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -canonical 'testrecord'
			$testalias.count | should be 3
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$Testalias[0].extattrib.Name | should be 'Site'
			$Testalias[0].extattrib.Value | should be 'corp'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should be 'test comment'
			$testalias[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias[0].TTL | should be 1200
			$testalias[0].Use_TTL | should be $True
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias3.domain.com'
			$Testalias[1].extattrib.Name | should be 'Site'
			$Testalias[1].extattrib.Value | should be 'corp'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment 2'
			$testalias[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias[1].TTL | should be 1200
			$testalias[1].Use_TTL | should be $True
			#
			$testalias[2].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[2].Name | should be 'testalias2.domain.com'
			$testalias[2].View | should be 'view3'
			$testalias[2].canonical | should be 'testrecord2.domain.com'
			$testalias[2].Comment | should benullorempty
			$testalias[2]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJfZGVmY2:testalias2.domain.com/view3'
			$testalias[2].TTL | should be 0
			$testalias[2].Use_TTL | should be $False

		}
		It "Returns multiple CName Records from zone query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -zone 'domain.com'
			$testalias.count | should be 3
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$Testalias[0].extattrib.Name | should be 'Site'
			$Testalias[0].extattrib.Value | should be 'corp'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should be 'test comment'
			$testalias[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias[0].TTL | should be 1200
			$testalias[0].Use_TTL | should be $True
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias3.domain.com'
			$Testalias[1].extattrib.Name | should be 'Site'
			$Testalias[1].extattrib.Value | should be 'corp'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment 2'
			$testalias[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias[1].TTL | should be 1200
			$testalias[1].Use_TTL | should be $True
			#
			$testalias[2].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[2].Name | should be 'testalias2.domain.com'
			$testalias[2].View | should be 'view3'
			$testalias[2].canonical | should be 'testrecord2.domain.com'
			$testalias[2].Comment | should benullorempty
			$testalias[2]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJfZGVmY2:testalias2.domain.com/view3'
			$testalias[2].TTL | should be 0
			$testalias[2].Use_TTL | should be $False

		}
		It "Returns multiple CName Records from strict canonical query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -canonical 'testrecord.domain.com' -strict
			$testalias.count | should be 2
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$Testalias[0].extattrib.Name | should be 'Site'
			$Testalias[0].extattrib.Value | should be 'corp'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should be 'test comment'
			$testalias[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias[0].TTL | should be 1200
			$testalias[0].Use_TTL | should be $True
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias3.domain.com'
			$Testalias[1].extattrib.Name | should be 'Site'
			$Testalias[1].extattrib.Value | should be 'corp'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment 2'
			$testalias[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias[1].TTL | should be 1200
			$testalias[1].Use_TTL | should be $True

		}
		It "Returns CName Record from view query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -view 'view3'
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias2.domain.com'
			$testalias.View | should be 'view3'
			$testalias.canonical | should be 'testrecord2.domain.com'
			$testalias.Comment | should benullorempty
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJfZGVmY2:testalias2.domain.com/view3'
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False

		}
		It "Returns CName Record from strict comment query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -comment 'test comment' -strict
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$Testalias.extattrib.Name | should be 'Site'
			$Testalias.extattrib.Value | should be 'corp'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True

		}
		It "returns CName Record from non-strict comment query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -comment 'test comment'
			$testalias.count | should be 2
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$Testalias[0].extattrib.Name | should be 'Site'
			$Testalias[0].extattrib.Value | should be 'corp'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should be 'test comment'
			$testalias[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias[0].TTL | should be 1200
			$testalias[0].Use_TTL | should be $True
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias3.domain.com'
			$Testalias[1].extattrib.Name | should be 'Site'
			$Testalias[1].extattrib.Value | should be 'corp'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment 2'
			$testalias[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias[1].TTL | should be 1200
			$testalias[1].Use_TTL | should be $True
		}
		It "returns CName Record from extensible attribute query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -ExtAttributeQuery {Site -eq 'corp'}
			$testalias.count | should be 2
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$Testalias[0].extattrib.Name | should be 'Site'
			$Testalias[0].extattrib.Value | should be 'corp'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should be 'test comment'
			$testalias[0]._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias[0].TTL | should be 1200
			$testalias[0].Use_TTL | should be $True
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias3.domain.com'
			$Testalias[1].extattrib.Name | should be 'Site'
			$Testalias[1].extattrib.Value | should be 'corp'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment 2'
			$testalias[1]._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias[1].TTL | should be 1200
			$testalias[1].Use_TTL | should be $True
		}
		It "returns CName Record from non-strict name and comment query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -name 'testalias' -comment 'test comment 2'
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias3.domain.com'
			$Testalias.extattrib.Name | should be 'Site'
			$Testalias.extattrib.Value | should be 'corp'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment 2'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True
		}
		It "returns CName Record from strict name and canonical query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -name 'testalias.domain.com' -canonical 'testrecord.domain.com' -strict
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$Testalias.extattrib.Name | should be 'Site'
			$Testalias.extattrib.Value | should be 'corp'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True
		}
		It "returns CName Record from strict name and view query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -name 'testalias.domain.com' -view 'default' -strict
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$Testalias.extattrib.Name | should be 'Site'
			$Testalias.extattrib.Value | should be 'corp'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True
		}
		It "returns CName Record from strict name and zone query" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -name 'testalias.domain.com' -zone 'domain.com' -strict
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$Testalias.extattrib.Name | should be 'Site'
			$Testalias.extattrib.Value | should be 'corp'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True

		}
		It "returns CName Record from non-strict name query with results count of 1" {
			$testalias = get-dnscnamerecord -gridmaster $gridmaster -credential $Credential -name 'testalias' -maxresults 1
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$Testalias.extattrib.Name | should be 'Site'
			$Testalias.extattrib.Value | should be 'corp'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
			$testalias.TTL | should be 1200
			$testalias.Use_TTL | should be $True

		}
	}
}
Describe "Get-DNSPTRRecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	Context "Get Method" {
		It "Throws error with invalid credential object" {
			{Get-DNSPTRRecord -gridmaster $gridmaster -credential 'notacredential'} | should throw
		}
		It "Throws error with invalid IP Address object" {
			{Get-DNSPTRRecord -gridmaster $gridmaster -credential $Credential -ipaddress 'notanipaddress'} | should throw
		}
		It "Throws error with invalid integer object" {
			{Get-DNSPTRRecord -gridmaster $gridmaster -credential $Credential -maxresults 'notanInt'} | should throw
		}
		It "Throws error with empty gridmaster" {
			{Get-DNSPTRRecord -gridmaster $Null -credential $credential} | should throw
		}
		It "returns PTR Record from ref query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.extattrib.Name | should be 'Site'
			$TestRecord.extattrib.Value | should be 'corp'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "Returns PTR Record from strict name query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -name '1.1.1.1.in-addr.arpa' -strict
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.extattrib.Name | should be 'Site'
			$TestRecord.extattrib.Value | should be 'corp'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "Returns multiple PTR Records from non-strict name query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -name '1.'
			$TestRecord.Count | should be 3
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].extattrib.Name | should be 'Site'
			$TestRecord[0].extattrib.Value | should be 'corp'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].extattrib.Name | should be 'Site'
			$TestRecord[1].extattrib.Value | should be 'corp'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.2.3.4'
			$TestRecord[1].Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
			#
			$TestRecord[2].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[2].PTRDName | should be 'localhost'
			$TestRecord[2].View | should be 'default'
			$TestRecord[2].IPAddress | should benullorempty
			$TestRecord[2].Name | should be '1.0.0.0.in-addr.arpa'
			$TestRecord[2].Comment | should benullorempty
			$TestRecord[2]._ref | should be 'record:ptr/adfwejfojvkalfpjqpe:1.0.0.0.in-addr.arpa/default'
			$TestRecord[2].TTL | should be 1
			$TestRecord[2].Use_TTL | should be $True
		}
		It "Returns PTR Record from strict ptrdname query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ptrdname 'testrecord.domain.com' -strict
			$TestRecord.count | should be 2
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].extattrib.Name | should be 'Site'
			$TestRecord[0].extattrib.Value | should be 'corp'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].extattrib.Name | should be 'Site'
			$TestRecord[1].extattrib.Value | should be 'corp'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.2.3.4'
			$TestRecord[1].Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
		}
		It "returns multiple PTR Records from non-strict ptrdname query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ptrdname 'testrecord'
			$TestRecord.count | should be 3
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].extattrib.Name | should be 'Site'
			$TestRecord[0].extattrib.Value | should be 'corp'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].extattrib.Name | should be 'Site'
			$TestRecord[1].extattrib.Value | should be 'corp'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.2.3.4'
			$TestRecord[1].Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
			#
			$TestRecord[2].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[2].PTRDName | should be 'testrecord2.domain.com'
			$TestRecord[2].View | should be 'view3'
			$TestRecord[2].IPAddress | should be '2.2.2.2'
			$TestRecord[2].Name | should be '2.2.2.2.in-addr.arpa'
			$TestRecord[2].Comment | should benullorempty
			$TestRecord[2]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2.in-addr.arpa/view3'
			$TestRecord[2].TTL | should be 0
			$TestRecord[2].Use_TTL | should be $False

		}
		It "Returns multiple PTR Records from zone query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -zone 'domain.com'
			$TestRecord.count | should be 3
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].extattrib.Name | should be 'Site'
			$TestRecord[0].extattrib.Value | should be 'corp'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].extattrib.Name | should be 'Site'
			$TestRecord[1].extattrib.Value | should be 'corp'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.2.3.4'
			$TestRecord[1].Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
			#
			$TestRecord[2].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[2].PTRDName | should be 'testrecord2.domain.com'
			$TestRecord[2].View | should be 'view3'
			$TestRecord[2].IPAddress | should be '2.2.2.2'
			$TestRecord[2].Name | should be '2.2.2.2.in-addr.arpa'
			$TestRecord[2].Comment | should benullorempty
			$TestRecord[2]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2.in-addr.arpa/view3'
			$TestRecord[2].TTL | should be 0
			$TestRecord[2].Use_TTL | should be $False

		}
		It "Returns PTR Record from IP Address query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ipaddress '1.1.1.1'
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.extattrib.Name | should be 'Site'
			$TestRecord.extattrib.Value | should be 'corp'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "Returns PTR Record from view query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -view 'view3'
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord2.domain.com'
			$TestRecord.View | should be 'view3'
			$TestRecord.IPAddress | should be '2.2.2.2'
			$TestRecord.Name | should be '2.2.2.2.in-addr.arpa'
			$TestRecord.Comment | should benullorempty
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2.in-addr.arpa/view3'
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False

		}
		It "Returns PTR Record from strict comment query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'test comment' -strict
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.extattrib.Name | should be 'Site'
			$TestRecord.extattrib.Value | should be 'corp'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True

		}
		It "returns PTR Record from non-strict comment query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'test comment'
			$TestRecord.count | should be 2
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].extattrib.Name | should be 'Site'
			$TestRecord[0].extattrib.Value | should be 'corp'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].extattrib.Name | should be 'Site'
			$TestRecord[1].extattrib.Value | should be 'corp'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.2.3.4'
			$TestRecord[1].Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
		}
		It "returns PTR Record from extensible attribute query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ExtAttributeQuery {Site -eq 'corp'}
			$TestRecord.count | should be 2
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].extattrib.Name | should be 'Site'
			$TestRecord[0].extattrib.Value | should be 'corp'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '1.1.1.1'
			$TestRecord[0].Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord[0].Comment | should be 'test comment'
			$TestRecord[0]._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord[0].TTL | should be 1200
			$TestRecord[0].Use_TTL | should be $True
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].extattrib.Name | should be 'Site'
			$TestRecord[1].extattrib.Value | should be 'corp'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '1.2.3.4'
			$TestRecord[1].Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment 2'
			$TestRecord[1]._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord[1].TTL | should be 1200
			$TestRecord[1].Use_TTL | should be $True
		}
		It "returns PTR Record from non-strict ptrdname and comment query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ptrdname 'testrecord' -comment 'test comment 2'
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.extattrib.Name | should be 'Site'
			$TestRecord.extattrib.Value | should be 'corp'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.2.3.4'
			$TestRecord.Name | should be '4.3.2.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment 2'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "returns PTR Record from strict ptrdname and IP Address query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ptrdname 'testrecord.domain.com' -ipaddress '1.1.1.1' -strict
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.extattrib.Name | should be 'Site'
			$TestRecord.extattrib.Value | should be 'corp'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "returns PTR Record from strict name and view query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -name '1.1.1.1.in-addr.arpa' -view 'default' -strict
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.extattrib.Name | should be 'Site'
			$TestRecord.extattrib.Value | should be 'corp'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True
		}
		It "returns PTR Record from strict name and zone query" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -name '1.1.1.1.in-addr.arpa' -zone 'domain.com' -strict
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.extattrib.Name | should be 'Site'
			$TestRecord.extattrib.Value | should be 'corp'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True

		}
		It "returns PTR Record from non-strict ptrdname query with results count of 1" {
			$TestRecord = Get-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ptrdname 'testrecord' -maxresults 1
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.extattrib.Name | should be 'Site'
			$TestRecord.extattrib.Value | should be 'corp'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '1.1.1.1'
			$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
			$TestRecord.TTL | should be 1200
			$TestRecord.Use_TTL | should be $True

		}
	}
}
Describe "Get-FixedAddress tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	Context 'Get Method' {
		It "Throws error with invalid credential object" {
			{Get-FixedAddress -Gridmaster $gridmaster -credential 'notacredential'} | should Throw
		}
		It "Throws error with invalid IP Address object" {
			{Get-FixedAddress -gridmaster $gridmaster -credential $Credential -ipaddress 'notanIP'} | should Throw
		}
		It "Throws error with invalid integer object" {
			{Get-FixedAddress -gridmaster $gridmaster -credential $Credential -maxresults 'notanint'} | should throw
		}
		It "Throws error with empty gridmaster" {
			{Get-FixedAddress -gridmaster '' -credential $Credential} | should throw
		}
		It "returns fixed address from ref query" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -_Ref 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.extattrib.Name | should be 'Site'
			$Return.extattrib.Value | should be 'corp'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "returns all fixed addresses from null query" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential
			$Return.Count | should be 3
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return[0].name | should be 'testrecord.domain.com'
			$Return[0].IPAddress | should be '1.1.1.1'
			$Return[0].extattrib.Name | should be 'Site'
			$Return[0].extattrib.Value | should be 'corp'
			$Return[0].comment | should be 'test comment'
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '00:00:00:00:00:00'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1]._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
			$Return[1].name | should be 'testrecord.domain.com'
			$Return[1].IPAddress | should be '1.2.3.4'
			$Return[1].comment | should be 'test comment 2'
			$Return[1].networkview | should be 'default'
			$Return[1].MAC | should be '00:00:00:00:00:00'
			#
			$Return[2].GetType().Name | should be 'IB_FixedAddress'
			$Return[2]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJfZGVmY2:2.2.2.2/networkview3'
			$Return[2].name | should be 'testrecord2.domain.com'
			$Return[2].IPAddress | should be '2.2.2.2'
			$Return[2].comment | should benullorempty
			$Return[2].networkview | should be 'networkview3'
			$Return[2].MAC | should be '00:00:00:00:00:11'
		}
		It "Returns fixed address from IP Address query" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -IPAddress '1.2.3.4'
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.IPAddress | should be '1.2.3.4'
			$Return.comment | should be 'test comment 2'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "Returns fixed addresses from MAC address query" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -mac '00:00:00:00:00:00'
			$Return.Count | should be 2
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return[0].name | should be 'testrecord.domain.com'
			$Return[0].extattrib.Name | should be 'Site'
			$Return[0].extattrib.Value | should be 'corp'
			$Return[0].IPAddress | should be '1.1.1.1'
			$Return[0].comment | should be 'test comment'
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '00:00:00:00:00:00'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1]._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
			$Return[1].name | should be 'testrecord.domain.com'
			$Return[1].IPAddress | should be '1.2.3.4'
			$Return[1].comment | should be 'test comment 2'
			$Return[1].networkview | should be 'default'
			$Return[1].MAC | should be '00:00:00:00:00:00'
		}
		It "Returns fixed addresses from non-strict comment query" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -comment 'test comment'
			$Return.Count | should be 2
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return[0].name | should be 'testrecord.domain.com'
			$Return[0].extattrib.Name | should be 'Site'
			$Return[0].extattrib.Value | should be 'corp'
			$Return[0].IPAddress | should be '1.1.1.1'
			$Return[0].comment | should be 'test comment'
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '00:00:00:00:00:00'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1]._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
			$Return[1].name | should be 'testrecord.domain.com'
			$Return[1].IPAddress | should be '1.2.3.4'
			$Return[1].comment | should be 'test comment 2'
			$Return[1].networkview | should be 'default'
			$Return[1].MAC | should be '00:00:00:00:00:00'
		}
		It "Returns fixed address from strict comment query" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -comment 'test comment' -Strict
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.extattrib.Name | should be 'Site'
			$Return.extattrib.Value | should be 'corp'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "Returns fixed address from extensible attribute query" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -ExtAttributeQuery {Site -eq 'corp'}
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.extattrib.Name | should be 'Site'
			$Return.extattrib.Value | should be 'corp'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "Returns fixed addresses from networkview query" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -networkView 'default'
			$Return.Count | should be 2
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0]._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return[0].name | should be 'testrecord.domain.com'
			$Return[0].extattrib.Name | should be 'Site'
			$Return[0].extattrib.Value | should be 'corp'
			$Return[0].IPAddress | should be '1.1.1.1'
			$Return[0].comment | should be 'test comment'
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '00:00:00:00:00:00'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1]._ref | should be 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
			$Return[1].name | should be 'testrecord.domain.com'
			$Return[1].IPAddress | should be '1.2.3.4'
			$Return[1].comment | should be 'test comment 2'
			$Return[1].networkview | should be 'default'
			$Return[1].MAC | should be '00:00:00:00:00:00'
		}
		It "returns fixed address from IP and MAC address query" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -IPAddress '1.1.1.1' -mac '00:00:00:00:00:00'
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.extattrib.Name | should be 'Site'
			$Return.extattrib.Value | should be 'corp'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "returns fixed address from IP and networkview query" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -IPAddress '1.1.1.1' -networkview 'default'
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.extattrib.Name | should be 'Site'
			$Return.extattrib.Value | should be 'corp'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "returns fixed address from IP, comment and networkview query" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -IPAddress '1.1.1.1' -comment 'test comment' -Networkview 'default'
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.extattrib.Name | should be 'Site'
			$Return.extattrib.Value | should be 'corp'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "returns fixed address from no query but resultscount set to 1" {
			$Return = Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -maxresults 1
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
			$Return.name | should be 'testrecord.domain.com'
			$Return.extattrib.Name | should be 'Site'
			$Return.extattrib.Value | should be 'corp'
			$Return.IPAddress | should be '1.1.1.1'
			$Return.comment | should be 'test comment'
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
	}
}
Describe "New-DNSARecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Post'} {
		Mock-InfobloxPost -uri $uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws error with invalid credential paramter" {
		{New-DNSARecord -Gridmaster $gridmaster -Credential 'notacredential'} | should throw
	}
	It "Throws error with invalid IP address parameter" {
		{New-DNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name 'testrecord' -IPAddress 'notanipaddress'} | should throw
	}
	It "Throws error with invalid TTL parameter" {
		{New-DNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name 'testrecord' -IPAddress '1.1.1.1' -TTL 'notaTTL'} | should Throw
	}
	It "Throws with empty gridmaster" {
		{New-DNSARecord -Gridmaster '' -Credential $Credential -Name 'testrecord' -IPAddress '1.1.1.1'} | should throw
	}
	It "Throws with empty name" {
		{New-DNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name '' -IPAddress '1.1.1.1'} | should throw
	}
	It "Creates dns A record in default view with no comment or TTL" {
		$Record = New-DNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name 'newtestrecord.domain.com' -IPAddress '1.1.1.1' -Confirm:$False
		$Record.GetType().Name | should be 'IB_DNSARecord'
		$Record.View | should be 'default'
		$Record.Name | should be 'newtestrecord.domain.com'
		$Record.IPAddress | should be '1.1.1.1'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}
	It "Creates dns A record in default view with comment and TTL" {
		$Record = New-DNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name 'newtestrecord2.domain.com' -IPAddress '1.1.1.1' -Comment 'test comment' -TTL 100 -Confirm:$False
		$Record.GetType().Name | should be 'IB_DNSARecord'
		$Record.View | should be 'default'
		$Record.Name | should be 'newtestrecord2.domain.com'
		$Record.IPAddress | should be '1.1.1.1'
		$Record.comment | should be 'test comment'
		$Record.TTL | should be 100
		$Record.Use_TTL | should be $True
	}
	It "Creates dns A record in specified view with no comment or TTL" {
		$Record = New-DNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name 'newtestrecord4.domain.com' -IPAddress '1.1.1.1' -View 'view2' -Confirm:$False
		$Record.GetType().Name | should be 'IB_DNSARecord'
		$Record.View | should be 'view2'
		$Record.Name | should be 'newtestrecord4.domain.com'
		$Record.IPAddress | should be '1.1.1.1'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}

}
Describe "New-DNSCNameRecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Post'} {
		Mock-InfobloxPost -uri $uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws error with invalid credential parameter" {
		{New-DNSCNameRecord -Gridmaster $Gridmaster -Credential 'notacredential' -Name 'testalias' -Canonical 'testrecord.domain.com' } | should throw
	}
	It "Throws error with invalid TTL parameter" {
		{New-DNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Name 'testalias' -Canonical 'testrecord.domain.com' -TTL 'notaTTL'} | should throw
	}
	It "throws error with empty gridmaster" {
		{New-DNSCNameRecord -Gridmaster '' -Credential $Credential -Name 'testalias' -Canonical 'testrecord.domain.com'} | should throw
	}
	It "throws error with empty name" {
		{New-DNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Name '' -Canonical 'testrecord.domain.com'} | should throw
	}
	It "throws error with empty canonical" {
		{New-DNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Name 'testalias' -Canonical ''} | should throw
	}
	It "Creates dns CName Record in default view with no comment or TTL" {
		$Record = New-DNSCNameRecord -Confirm:$False -Gridmaster $Gridmaster -Credential $Credential -Name 'newtestalias.domain.com' -Canonical 'testrecord.domain.com'
		$Record.GetType().Name | should be 'IB_DNSCNameRecord'
		$Record.View | should be 'default'
		$Record.Name | should be 'newtestalias.domain.com'
		$Record.canonical | should be 'testrecord.domain.com'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}
	It "Creates dns CName Record in default view with comment and TTL" {
		$Record = New-DNSCNameRecord -Confirm:$False -Gridmaster $Gridmaster -Credential $Credential -Name 'newtestalias2.domain.com' -Canonical 'testrecord.domain.com' -Comment 'test comment' -TTL 100
		$Record.GetType().Name | should be 'IB_DNSCNameRecord'
		$Record.View | should be 'default'
		$Record.Name | should be 'newtestalias2.domain.com'
		$Record.canonical | should be 'testrecord.domain.com'
		$Record.comment | should be 'test comment'
		$Record.TTL | should be 100
		$Record.Use_TTL | should be $True
	}
	It "Creates dns CName Record in specified view with no comment or TTL" {
		$Record = New-DNSCNameRecord -Confirm:$False -Gridmaster $Gridmaster -Credential $Credential -Name 'newtestalias4.domain.com' -Canonical 'testrecord.domain.com' -View 'view2'
		$Record.GetType().Name | should be 'IB_DNSCNameRecord'
		$Record.View | should be 'view2'
		$Record.Name | should be 'newtestalias4.domain.com'
		$Record.canonical | should be 'testrecord.domain.com'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}

}
Describe "New-DNSPTRRecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Post'} {
		Mock-InfobloxPost -uri $uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws error with invalid credential paramter" {
		{New-DNSPTRRecord -Gridmaster $Gridmaster -Credential 'notacredential' -PTRDName 'testrecord' -IPAddress '1.1.1.1'} | should throw
	}
	It "Throws error with invalid IP address parameter" {
		{New-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'testrecord' -IPAddress 'notanIP'} | should throw
	}
	It "Throws error with invalid TTL parameter" {
		{New-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'testrecord' -IPAddress '1.1.1.1' -TTL 'notaTTL'} | should throw
	}
	It "Throws error with empty gridmaster" {
		{New-DNSPTRRecord -Gridmaster '' -Credential $Credential -PTRDName 'testrecord' -IPAddress '1.1.1.1'} | should throw
	}
	It "Throws error with empty PTRDName" {
		{New-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -PTRDName '' -IPAddress '1.1.1.1'} | should throw
	}
	It "Throws error with empty IPAddress" {
		{New-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'testrecord' -IPAddress ''} | should throw
	}
	It "Creates dns PTR record in default view with no comment or TTL" {
		$record = New-DNSPTRRecord -Confirm:$False -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'newtestrecord.domain.com' -IPAddress '1.1.1.1'
		$Record.GetType().Name | should be 'IB_DNSPTRRecord'
		$Record.View | should be 'default'
		$Record.PTRDName | should be 'newtestrecord.domain.com'
		$Record.IPAddress | should be '1.1.1.1'
		$Record.Name | should be '1.1.1.1.in-addr.arpa'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}
	It "Creates dns PTR Record in default view with comment and TTL" {
		$record = New-DNSPTRRecord -Confirm:$False -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'newtestrecord2.domain.com' -IPAddress '1.1.1.1' -Comment 'test comment' -TTL 100
		$Record.GetType().Name | should be 'IB_DNSPTRRecord'
		$Record.View | should be 'default'
		$Record.PTRDName | should be 'newtestrecord2.domain.com'
		$Record.IPAddress | should be '1.1.1.1'
		$Record.Name | should be '1.1.1.1.in-addr.arpa'
		$Record.comment | should be 'test comment'
		$Record.TTL | should be 100
		$Record.Use_TTL | should be $True
	}
	It "Creates dns PTR Record in specified view with no comment or TTL" {
		$record = New-DNSPTRRecord -Confirm:$False -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'newtestrecord4.domain.com' -IPAddress '1.1.1.1' -View 'view2'
		$Record.GetType().Name | should be 'IB_DNSPTRRecord'
		$Record.View | should be 'view2'
		$Record.PTRDName | should be 'newtestrecord4.domain.com'
		$Record.IPAddress | should be '1.1.1.1'
		$Record.Name | should be '1.1.1.1.in-addr.arpa'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}

}
Describe "New-FixedAddress tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Post'} {
		Mock-InfobloxPost -uri $uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws error with invalid credential object" {
		{New-FixedAddress -Gridmaster $Gridmaster -Credential 'notacredential' -Name 'testrecord' -IPAddress '1.1.1.1'} | should Throw
	}
	It "Throws error with invalid IP Address object" {
		{New-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -Name 'testrecord' -IPAddress 'notanIP'} | should Throw
	}
	It "Throws error with empty gridmaster" {
		{New-FixedAddress -Gridmaster '' -Credential $Credential -Name 'testrecord' -IPAddress '1.1.1.1'} | should Throw
	}
	It "Throws error with empty IP" {
		{New-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -Name 'testrecord' -IPAddress ''} | should Throw
	}
	It "creates fixedaddress with no name or comment and zero mac in default view" {
		$TestRecord = New-FixedAddress -Confirm:$False -Gridmaster $Gridmaster -Credential $Credential -IPAddress '10.1.1.1'
		$TestRecord.GetType().name | Should be 'IB_FixedAddress'
		$TestRecord.IPAddress | should be '10.1.1.1'
		$TestRecord.Name | should benullorempty
		$TestRecord.Comment | should benullorempty
		$TestRecord.mac | should be '00:00:00:00:00:00'
		$TestRecord.NetworkView | should be 'default'
	}
	It "creates fixedaddress with no name or comment and non-zero mac in default view" {
		$TestRecord = New-FixedAddress -Confirm:$False -Gridmaster $Gridmaster -Credential $Credential -IPAddress '10.1.1.2' -MAC '11:11:11:11:11:11'
		$TestRecord.GetType().name | Should be 'IB_FixedAddress'
		$TestRecord.IPAddress | should be '10.1.1.2'
		$TestRecord.Name | should benullorempty
		$TestRecord.Comment | should benullorempty
		$TestRecord.mac | should be '11:11:11:11:11:11'
		$TestRecord.NetworkView | should be 'default'
	}
	It "Creates fixedaddress with name, no comment and zero mac in default view" {
		$TestRecord = New-FixedAddress -Confirm:$False -Gridmaster $Gridmaster -Credential $Credential -Name 'newtestrecord' -IPAddress '10.1.1.3' -MAC "00:00:00:00:00:00"
		$TestRecord.GetType().name | Should be 'IB_FixedAddress'
		$TestRecord.IPAddress | should be '10.1.1.3'
		$TestRecord.Name | should be 'newtestrecord'
		$TestRecord.Comment | should benullorempty
		$TestRecord.mac | should be '00:00:00:00:00:00'
		$TestRecord.NetworkView | should be 'default'
	}
	It "Creates fixedaddress with name and comment and non-zero mac in default view" {
		$TestRecord = New-FixedAddress -Confirm:$False -Gridmaster $Gridmaster -Credential $Credential -Name 'newtestrecord' -IPAddress '10.1.1.4' -Comment 'comment' -MAC '11:11:11:11:11:11'
		$TestRecord.GetType().name | Should be 'IB_FixedAddress'
		$TestRecord.IPAddress | should be '10.1.1.4'
		$TestRecord.Name | should be 'newtestrecord'
		$TestRecord.Comment | should be 'comment'
		$TestRecord.mac | should be '11:11:11:11:11:11'
		$TestRecord.NetworkView | should be 'default'
	}
	It "creates fixedaddress with comment, no name and non-zero mac in specified view" {
		$TestRecord = New-FixedAddress -Confirm:$False -Gridmaster $Gridmaster -Credential $Credential -Comment 'comment' -NetworkView 'networkview3' -IPAddress '10.1.1.5' -MAC '11:11:11:11:11:11'
		$TestRecord.GetType().name | Should be 'IB_FixedAddress'
		$TestRecord.IPAddress | should be '10.1.1.5'
		$TestRecord.Name | should benullorempty
		$TestRecord.Comment | should be 'comment'
		$TestRecord.mac | should be '11:11:11:11:11:11'
		$TestRecord.NetworkView | should be 'networkview3'
	}

}
Describe "Set-DNSARecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Put'} {
		Mock-InfobloxPut -uri $Uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws an error with an invalid IP Address parameter" {
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		{$TestRecord | Set-DNSARecord -IPAddress 'notanIP'} | should Throw
	}
	It "Throws an error with an invalid TTL parameter" {
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		{$TestRecord | Set-DNSARecord -TTL 'notaTTL'} | should Throw
	}
	It "Throws an error with an empty gridmaster" {
		{Set-DNSARecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "Throws an error with invalid credential object" {
		{Set-DNSARecord -Gridmaster $Gridmaster -Credential 'notaCred' -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Set-DNSARecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Set-dnsarecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		{Set-DNSARecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Set-DNSARecord -ea Stop} | should Throw
	}
	It "makes no changes when set-dnsarecord is called with no parameters" {
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		$TestRecord | Set-DNSARecord -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
	}
	It "Sets the comment and IPAddress on an existing DNS Record with passthru" {
		$Record = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		$TestRecord = $Record | Set-DNSARecord -IPAddress '2.2.2.2' -Comment 'new comment' -Confirm:$False -Passthru
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
	}
	It "Sets the TTL on an existing record" {
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		$TestRecord | Set-DNSARecord -TTL 100 -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True

	}
	It "Clears the TTL on an existing Record" {
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		$TestRecord | Set-DNSARecord -ClearTTL -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the TTL to 0 with Use_TTL set to True" {
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		$TestRecord | Set-DNSARecord -TTL 0 -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL" {
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		$TestRecord | Set-DNSARecord -TTL 100 -ClearTTL -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment to null" {
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		$TestRecord | Set-DNSARecord -Comment $Null -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
#
	It "Sets the comment and IPAddress on an existing DNS Record - using byRef method" {
		$Refstring = 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		Set-DNSARecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring -IPAddress '2.2.2.2' -Comment 'new comment'
		$TestRecord = Get-DNSARecord -gridmaster $gridmaster -credential $credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be $Refstring
	}
	It "Sets the TTL on an existing record - using byRef method" {
		$RefString = 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		Set-DNSARecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring  -TTL 100
		$TestRecord = Get-dnsarecord -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be $Refstring

	}
	It "Clears the TTL on an existing Record - using byRef method" {
		$Refstring = 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		Set-DNSARecord -Confirm:$False -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -ClearTTL
		$TestRecord = Get-DNSARecord  -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be $Refstring
	}
	It "Sets the TTL to 0 with Use_TTL set to True - using byRef method" {
		$RefString = 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		Set-DNSARecord -Confirm:$False -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -TTL 0
		$TestRecord = Get-DNSARecord  -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be $Refstring
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL - using byRef method and passthru" {
		$RefString = 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord = Set-DNSARecord -Confirm:$False -PassThru -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -TTL 100 -ClearTTL
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be $Refstring
	}
	It "Sets the comment to null - using byRef method" {
		$Refstring = 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		Set-DNSARecord -Confirm:$False -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -Comment $Null
		$TestRecord = Get-DNSARecord  -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '2.2.2.2'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be $Refstring
	}

}
Describe "Set-DNSCNameRecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Put'} {
		Mock-InfobloxPut -uri $Uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws an error with an invalid TTL parameter" {
		$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		{$TestRecord | Set-DNSCNameRecord -TTL 'notaTTL'} | should Throw
	}
	It "Throws an error with an empty gridmaster" {
		{Set-DNSCNameRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "Throws an error with invalid credential object" {
		{Set-DNSCNameRecord -Gridmaster $Gridmaster -Credential 'notaCred' -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Set-DNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Set-DNSCNameRecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		{Set-DNSCNameRecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Set-DNSCNameRecord -ea Stop} | should Throw
	}
	It "makes no changes when set-DNSCNameRecord is called with no parameters" {
		$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		$TestRecord | Set-DNSCNameRecord -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.Canonical | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
	It "Sets the comment and canonical on an existing DNS Record with passthru" {
		$Record = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		$TestRecord = $Record | Set-DNSCNameRecord -Canonical 'testrecord2.domain.com' -Comment 'new comment' -Confirm:$False -Passthru
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
	It "Sets the TTL on an existing record" {
		$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		$TestRecord | Set-DNSCNameRecord -TTL 100 -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
	It "Clears the TTL on an existing Record" {
		$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		$TestRecord | Set-DNSCNameRecord -ClearTTL -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
	It "Sets the TTL to 0 with Use_TTL set to True" {
		$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		$TestRecord | Set-DNSCNameRecord -TTL 0 -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL" {
		$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		$TestRecord | Set-DNSCNameRecord -TTL 100 -ClearTTL -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
	It "Sets the comment to null" {
		$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		$TestRecord | Set-DNSCNameRecord -Comment $Null -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
#
	It "Sets the comment and canonical on an existing DNS Record - using byRef method" {
		$Refstring = 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		Set-DNSCNameRecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring -canonical 'testrecord2.domain.com' -Comment 'new comment'
		$TestRecord = Get-DNSCNameRecord -gridmaster $gridmaster -credential $credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
	It "Sets the TTL on an existing record - using byRef method" {
		$RefString = 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		Set-DNSCNameRecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring  -TTL 100
		$TestRecord = Get-DNSCNameRecord -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
	It "Clears the TTL on an existing Record - using byRef method" {
		$Refstring = 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		Set-DNSCNameRecord -Confirm:$False -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -ClearTTL
		$TestRecord = Get-DNSCNameRecord  -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
	It "Sets the TTL to 0 with Use_TTL set to True - using byRef method" {
		$RefString = 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		Set-DNSCNameRecord -Confirm:$False -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -TTL 0
		$TestRecord = Get-DNSCNameRecord  -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL - using byRef method and passthru" {
		$RefString = 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		$TestRecord = Set-DNSCNameRecord -Confirm:$False -PassThru -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -TTL 100 -ClearTTL
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}
	It "Sets the comment to null - using byRef method" {
		$Refstring = 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		Set-DNSCNameRecord -Confirm:$False -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -Comment $Null
		$TestRecord = Get-DNSCNameRecord  -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
	}

}
Describe "Set-DNSPTRRecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Put'} {
		Mock-InfobloxPut -uri $Uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws an error with an invalid TTL parameter" {
		$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		{$TestRecord | Set-DNSPTRRecord -TTL 'notaTTL'} | should Throw
	}
	It "Throws an error with an empty gridmaster" {
		{Set-DNSPTRRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "Throws an error with invalid credential object" {
		{Set-DNSPTRRecord -Gridmaster $Gridmaster -Credential 'notaCred' -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Set-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Set-DNSPTRRecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		{Set-DNSPTRRecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Set-DNSPTRRecord -ea Stop} | should Throw
	}
	It "makes no changes when set-DNSPTRRecord is called with no parameters" {
		$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		$TestRecord | Set-DNSPTRRecord -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Sets the comment and canonical on an existing DNS Record with passthru" {
		$Record = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		$TestRecord = $Record | Set-DNSPTRRecord -PTRDName 'testrecord2.domain.com' -Comment 'new comment' -Confirm:$False -Passthru
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Sets the TTL on an existing record" {
		$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		$TestRecord | Set-DNSPTRRecord -TTL 100 -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Clears the TTL on an existing Record" {
		$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		$TestRecord | Set-DNSPTRRecord -ClearTTL -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Sets the TTL to 0 with Use_TTL set to True" {
		$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		$TestRecord | Set-DNSPTRRecord -TTL 0 -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL" {
		$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		$TestRecord | Set-DNSPTRRecord -TTL 100 -ClearTTL -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Sets the comment to null" {
		$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		$TestRecord | Set-DNSPTRRecord -Comment $Null -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Sets the comment and PTRDName on an existing DNS Record - using byRef method" {
		$Refstring = 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		Set-DNSPTRRecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring -PTRDName 'testrecord2.domain.com' -Comment 'new comment'
		$TestRecord = Get-DNSPTRRecord -gridmaster $gridmaster -credential $credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Sets the TTL on an existing record - using byRef method" {
		$RefString = 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		Set-DNSPTRRecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring  -TTL 100
		$TestRecord = Get-DNSPTRRecord -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Clears the TTL on an existing Record - using byRef method" {
		$Refstring = 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		Set-DNSPTRRecord -Confirm:$False -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -ClearTTL
		$TestRecord = Get-DNSPTRRecord  -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Sets the TTL to 0 with Use_TTL set to True - using byRef method" {
		$RefString = 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		Set-DNSPTRRecord -Confirm:$False -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -TTL 0
		$TestRecord = Get-DNSPTRRecord  -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL - using byRef method and passthru" {
		$RefString = 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		$TestRecord = Set-DNSPTRRecord -Confirm:$False -PassThru -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -TTL 100 -ClearTTL
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}
	It "Sets the comment to null - using byRef method" {
		$Refstring = 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		Set-DNSPTRRecord -Confirm:$False -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -Comment $Null
		$TestRecord = Get-DNSPTRRecord  -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
	}

}
Describe "Set-FixedAddress tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Put'} {
		Mock-InfobloxPut -uri $Uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws an error with an invalid TTL parameter" {
		$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
		{$TestRecord | Set-FixedAddress -TTL 'notaTTL'} | should Throw
	}
	It "Throws an error with an empty gridmaster" {
		{Set-FixedAddress -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "Throws an error with invalid credential object" {
		{Set-FixedAddress -Gridmaster $Gridmaster -Credential 'notaCred' -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Set-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Set-FixedAddress -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
		{Set-FixedAddress -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Set-FixedAddress -ea Stop} | should Throw
	}
	It "makes no changes when set-FixedAddress is called with no parameters" {
		$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
		$TestRecord | Set-FixedAddress -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '00:00:00:00:00:00'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
	}
	It "Sets the comment and Name on an existing DNS Record with passthru" {
		$Record = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
		$TestRecord = $Record | Set-FixedAddress -Name 'testrecord2.domain.com' -Comment 'new comment' -Confirm:$False -Passthru
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '00:00:00:00:00:00'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
	}
	It "Sets the MAC on an existing record" {
		$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
		$TestRecord | Set-FixedAddress -MAC '11:11:11:11:11:11' -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '11:11:11:11:11:11'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
	}
	It "Sets the comment to null" {
		$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
		$TestRecord | Set-FixedAddress -Comment $Null -Confirm:$False
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '11:11:11:11:11:11'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
	}
#
	It "Sets the comment and Name on an existing DNS Record - using byRef method" {
		$Refstring = 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		Set-FixedAddress -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring -Name 'testrecord2.domain.com' -Comment 'new comment'
		$TestRecord = Get-FixedAddress -gridmaster $gridmaster -credential $credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '11:11:11:11:11:11'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
	}
	It "Sets the MAC on an existing record - using byRef method" {
		$RefString = 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		Set-FixedAddress -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring  -MAC '00:00:00:00:00:00'
		$TestRecord = Get-FixedAddress -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '00:00:00:00:00:00'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
	}
	It "Sets the comment to null - using byRef method" {
		$Refstring = 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		Set-FixedAddress -Confirm:$False -gridmaster $gridmaster -credential $Credential -_Ref $Refstring -Comment $Null
		$TestRecord = Get-FixedAddress  -gridmaster $gridmaster -credential $Credential -_Ref $Refstring
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '00:00:00:00:00:00'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
	}

}
Describe "Remove-DNSARecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Delete'} {
		$uri | Mock-InfobloxDelete
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws an error with an empty gridmaster" {
		{Remove-DNSARecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "Throws an error with invalid credential object" {
		{Remove-DNSARecord -Gridmaster $Gridmaster -Credential 'notaCred' -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Remove-DNSARecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Remove-DNSARecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		{Remove-DNSARecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Remove-DNSARecord -ea Stop} | should Throw
	}
	It "Deletes the record using byObject method" {
		$Record = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		$Return = $Record | Remove-DNSARecord -Confirm:$False
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default')
		$Return.GetType().Name | Should be 'String'
		$Return | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord | should benullorempty
	}
	It "Deletes the record using byRef method" {
		$Refstring = 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		$Return = Remove-DNSARecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring
		$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,$Refstring)
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Refstring
		$TestRecord | should benullorempty
	}
}
Describe "Remove-DNSCNameRecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Delete'} {
		$uri | Mock-InfobloxDelete
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws an error with an empty gridmaster" {
		{Remove-DNSCNameRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "Throws an error with invalid credential object" {
		{Remove-DNSCNameRecord -Gridmaster $Gridmaster -Credential 'notaCred' -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Remove-DNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Remove-DNSCNameRecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		{Remove-DNSCNameRecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Remove-DNSCNameRecord -ea Stop} | should Throw
	}
	It "Deletes the record using byObject method" {
		$Record = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		$Return = $Record | Remove-DNSCNameRecord -Confirm:$False
		$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default')
		$Return.GetType().Name | Should be 'String'
		$Return | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		$TestRecord | should benullorempty
	}
	It "Deletes the record using byRef method" {
		$Refstring = 'record:cname/ZG5zLmJpbcHRyJC5fZGVmYX:testalias3.domain.com/default'
		$Return = Remove-DNSCNameRecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring
		$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,$Refstring)
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Refstring
		$TestRecord | should benullorempty
	}
}
Describe "Remove-DNSPTRRecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Delete'} {
		$uri | Mock-InfobloxDelete
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws an error with an empty gridmaster" {
		{Remove-DNSPTRRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "Throws an error with invalid credential object" {
		{Remove-DNSPTRRecord -Gridmaster $Gridmaster -Credential 'notaCred' -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Remove-DNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Remove-DNSPTRRecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		{Remove-DNSPTRRecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Remove-DNSPTRRecord -ea Stop} | should Throw
	}
	It "Deletes the record using byObject method" {
		$Record = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		$Return = $Record | Remove-DNSPTRRecord -Confirm:$False
		$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default')
		$Return.GetType().Name | Should be 'String'
		$Return | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		$TestRecord | should benullorempty
	}
	It "Deletes the record using byRef method" {
		$Refstring = 'record:ptr/ZG5zLmJpbcHRyJC5fZGVmYX:4.3.2.1.in-addr.arpa/default'
		$Return = Remove-DNSPTRRecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring
		$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,$Refstring)
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Refstring
		$TestRecord | should benullorempty
	}
}
Describe "Remove-FixedAddress tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Delete'} {
		$uri | Mock-InfobloxDelete
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws an error with an empty gridmaster" {
		{Remove-FixedAddress -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "Throws an error with invalid credential object" {
		{Remove-FixedAddress -Gridmaster $Gridmaster -Credential 'notaCred' -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Remove-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Remove-FixedAddress -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
		{Remove-FixedAddress -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Remove-FixedAddress -ea Stop} | should Throw
	}
	It "Deletes the record using byObject method" {
		$Record = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
		$Return = $Record | Remove-FixedAddress -Confirm:$False
		$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default')
		$Return.GetType().Name | Should be 'String'
		$Return | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		$TestRecord | should benullorempty
	}
#
	It "Deletes the record using byRef method" {
		$Refstring = 'fixedAddress/ZG5zLmJpbcHRyJC5fZGVmYX:1.2.3.4/default'
		$Return = Remove-FixedAddress -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring
		$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,$Refstring)
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Refstring
		$TestRecord | should benullorempty
	}
}
Describe "Remove-InfobloxRecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Delete'} {
		$uri | Mock-InfobloxDelete
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws an error with an empty gridmaster" {
		{Remove-InfobloxRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "Throws an error with invalid credential object" {
		{Remove-InfobloxRecord -Gridmaster $Gridmaster -Credential 'notaCred' -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Remove-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Remove-InfobloxRecord -ea Stop} | should Throw
	}
	It "finds no record to delete and returns nothing" {
		$Refstring = 'record:a/ZG5zLmJGVmYX:testrecord3.domain.com/default'
		$Return = Remove-InfobloxRecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring
		$TestRecord = [IB_ReferenceObject]::Get($gridmaster,$Credential,$Refstring)
		$Return | should benullorempty
		$TestRecord | should benullorempty
	}
	It "Deletes an A record using byRef method" {
		$Refstring = 'record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default'
		$Return = Remove-InfobloxRecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring
		$TestRecord = [IB_ReferenceObject]::Get($gridmaster,$Credential,$Refstring)
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Refstring
		$TestRecord | should benullorempty
	}
	It "Deletes an PTR record using byRef method" {
		$Refstring = 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		$Return = Remove-InfobloxRecord -Confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Refstring
		$TestRecord = [IB_ReferenceObject]::Get($gridmaster,$Credential,$Refstring)
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Refstring
		$TestRecord | should benullorempty
	}
	It "deletes CName Record using object through pipeline" {
		$refstring = 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		$Record = Get-DNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref $refstring
		$return = $Record | Remove-InfobloxRecord -confirm:$False
		$TestRecord = [IB_ReferenceObject]::Get($gridmaster,$Credential,$Refstring)
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Refstring
		$TestRecord | should benullorempty
	}
}
Describe "Get-InfobloxRecord tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws an error with an empty gridmaster" {
		{Get-InfobloxRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "Throws an error with invalid credential object" {
		{Get-InfobloxRecord -Gridmaster $Gridmaster -Credential 'notaCred' -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Get-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Get-InfobloxRecord -ea Stop} | should Throw
	}
	It "returns A record from ref query" {
		$TestRecord = Get-InfobloxRecord -gridmaster $Gridmaster -credential $Credential -_Ref 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
	}
	It "returns CName Record from ref query" {
		$testalias = Get-InfobloxRecord -gridmaster $gridmaster -credential $Credential -_Ref 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
		$testalias.Name | should be 'testalias.domain.com'
		$testalias.View | should be 'default'
		$testalias.canonical | should be 'testrecord.domain.com'
		$testalias.Comment | should be 'test comment'
		$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		$testalias.TTL | should be 1200
		$testalias.Use_TTL | should be $True
	}
	It "returns PTR Record from ref query" {
		$TestRecord = Get-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
	}
	It "returns fixed address from ref query" {
		$Return = Get-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		$Return.GetType().Name | should be 'IB_FixedAddress'
		$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		$Return.name | should be 'testrecord.domain.com'
		$Return.IPAddress | should be '1.1.1.1'
		$Return.comment | should be 'test comment'
		$Return.networkview | should be 'default'
		$Return.MAC | should be '00:00:00:00:00:00'
	}
	It "returns A record from ref query through pipeline" {
		$Refstring = 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$object = new-object PSObject -Property @{
			gridmaster = $Gridmaster
			credential = $Credential
			_ref = $Refstring
		}
		$TestRecord = $object | Get-InfobloxRecord
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
	}
	It "returns CName Record from ref query through pipeline" {
		$Refstring = 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		$object = new-object PSObject -Property @{
			gridmaster = $Gridmaster
			credential = $Credential
			_ref = $Refstring
		}
		$Testalias = $object | Get-InfobloxRecord
		$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
		$testalias.Name | should be 'testalias.domain.com'
		$testalias.View | should be 'default'
		$testalias.canonical | should be 'testrecord.domain.com'
		$testalias.Comment | should be 'test comment'
		$testalias._ref | should be 'record:cname/ZG5zLmJpbmRfcHRyJC5fZGVa:testalias.domain.com/default'
		$testalias.TTL | should be 1200
		$testalias.Use_TTL | should be $True
	}
	It "returns PTR Record from ref query through pipeline" {
		$Refstring = 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		$object = new-object PSObject -Property @{
			gridmaster = $Gridmaster
			credential = $Credential
			_ref = $Refstring
		}
		$TestRecord = $object | Get-InfobloxRecord
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '1.1.1.1'
		$TestRecord.Name | should be '1.1.1.1.in-addr.arpa'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord._ref | should be 'record:ptr/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1.in-addr.arpa/default'
		$TestRecord.TTL | should be 1200
		$TestRecord.Use_TTL | should be $True
	}
	It "returns fixed address from ref query through pipeline" {
		$Refstring = 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		$object = new-object PSObject -Property @{
			gridmaster = $Gridmaster
			credential = $Credential
			_ref = $Refstring
		}
		$Return = $object | Get-InfobloxRecord
		$Return.GetType().Name | should be 'IB_FixedAddress'
		$Return._ref | should be 'fixedAddress/ZG5zLmJpbmRfcHRyJC5fZGVa:1.1.1.1/default'
		$Return.name | should be 'testrecord.domain.com'
		$Return.IPAddress | should be '1.1.1.1'
		$Return.comment | should be 'test comment'
		$Return.networkview | should be 'default'
		$Return.MAC | should be '00:00:00:00:00:00'
	}
}
Describe "Add-ExtensibleAttribute, Remove-ExtensibleAttribute tests" {
	$script:Recordlist = Get-Content "$ScriptLocation\TestData.txt" -Raw | ConvertFrom-Json | select -ExpandProperty TestData
	Mock Test-Connection {$True}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Put'} {
		Mock-InfobloxPut -uri $Uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Post'} {
		Mock-InfobloxPost -uri $uri -body $Body
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq 'Delete'} {
	$uri | Mock-InfobloxDelete
	}
	Mock Invoke-RestMethod -ParameterFilter {$Method -eq $Null} {
		$URI | Mock-InfobloxGet
	}
	It "Throws an error with an empty gridmaster" {
		{Add-ExtensibleAttribute -Gridmaster '' -Credential $Credential -_Ref 'refstring' -eaname 'EA' -eavalue 'value'} | should throw
	}
	It "Throws an error with invalid credential object" {
		{Get-InfobloxRecord -Gridmaster $Gridmaster -Credential 'notaCred' -_Ref 'refstring' -eaname 'EA' -eavalue 'value'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Get-InfobloxRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref  -eaname 'EA' -eavalue 'value'} | should throw
	}
	It "throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Get-InfobloxRecord -ea Stop -eaname 'EA' -eavalue 'value'} | should Throw
	}
	It "Adds extensible attribute by object pipeline with passthru option" {
		$TestRecord = Get-DNSARecord -Gridmaster $gridmaster -Credential $Credential -_ref 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3'
		$TestRecord = $TestRecord | add-ExtensibleAttribute -EAName Site -EAValue corp -Passthru
		$TestRecord.ExtAttrib.Name | should be 'Site'
		$TestRecord.ExtAttrib.value | should be 'corp'
	}
	It "Updates the value of an existing extensible attribute by object pipeline with passthru option" {
		$TestRecord = Get-DNSARecord -Gridmaster $gridmaster -Credential $Credential -_ref 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord = $TestRecord | add-extensibleattribute -eaname Site -eavalue gulf -Passthru
		$TestRecord.ExtAttrib | measure-object | select -ExpandProperty Count | should be 1
		$TestRecord.ExtAttrib.Name | should be 'Site'
		$TestRecord.ExtAttrib.value | should be 'gulf'
	}
	It "Adds extensible attribute by ref" {
		Add-ExtensibleAttribute -gridmaster $gridmaster -credential $credential -_ref 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default' -EAName 'EA2' -EAValue 'Value2'
		$TestRecord = Get-DNSARecord -Gridmaster $gridmaster -Credential $Credential -_ref 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord.ExtAttrib | measure-object | select -ExpandProperty Count | should be 2
		$TestRecord.ExtAttrib[0].Name | should be 'EA2'
		$TestRecord.ExtAttrib[0].Value | should be 'Value2'
		$TestRecord.ExtAttrib[1].Name | should be 'Site'
		$TestRecord.ExtAttrib[1].Value | should be 'gulf'
	}
	It "Adds extensible attribute by object" {
		$TestRecord = Get-DNSARecord -Gridmaster $gridmaster -Credential $Credential -_ref 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord = add-ExtensibleAttribute -Record $testrecord -Passthru -EAName 'EA3' -EAValue 'Value3'
		$TestRecord.ExtAttrib | measure-object | % count | should be 3
		$TestRecord.ExtAttrib[0].Name | should be 'EA2'
		$TestRecord.ExtAttrib[0].Value | should be 'Value2'
		$TestRecord.ExtAttrib[1].Name | should be 'EA3'
		$TestRecord.ExtAttrib[1].Value | should be 'Value3'
		$TestRecord.ExtAttrib[2].Name | should be 'Site'
		$TestRecord.ExtAttrib[2].Value | should be 'gulf'
	}
	It "Removes specified extensible attribute by ref" {
		$TestRecord = Remove-extensibleAttribute -EAName Site -gridmaster $gridmaster -credential $credential -_ref 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default' -Passthru
		$TestRecord.ExtAttrib | measure-object | % Count | should be 2
		$TestRecord.ExtAttrib[0].Name | should be 'EA2'
		$TestRecord.ExtAttrib[0].Value | should be 'Value2'
		$TestRecord.ExtAttrib[1].Name | should be 'EA3'
		$TestRecord.ExtAttrib[1].Value | should be 'Value3'
	}
	It "Removes all extensible attributes by object" {
		$TestRecord = Get-DNSARecord -Gridmaster $gridmaster -Credential $Credential -_ref 'record:a/ZG5zLmJpbmRfcHRyJC5fZGVa:testrecord.domain.com/default'
		$TestRecord = $TestRecord | Remove-ExtensibleAttribute -RemoveAll -Passthru
		$TestReecord.Extattrib | should benullorempty
	}
	It "Removes all extensible attributes by ref" {
		$TestRecord = Remove-extensibleattribute -Gridmaster $gridmaster -Credential $Credential -_ref 'record:a/ZG5zLmJpbmRfcHRyJfZGVmY2:testrecord2.domain.com/view3' -removeall -passthru
		$TestRecord.Extattrib | should benullorempty
	}
	It "Removes specified extensible attribute by object" {
		$TestRecord = Get-DNSARecord -Gridmaster $gridmaster -Credential $Credential -_ref "record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default"
		Add-ExtensibleAttribute -Record $TestRecord -EAName EA2 -EAValue 'Value2'
		Remove-ExtensibleAttribute -Record $TestRecord -EAName Site
		$TestRecord = Get-DNSARecord -Gridmaster $gridmaster -Credential $Credential -_ref "record:a/ZG5zLmJpbcHRyJC5fZGVmYX:testrecord3.domain.com/default"
		$TestRecord.Extattrib | measure-object | % Count | should be 1
		$TestRecord.ExtAttrib.Name | should be 'EA2'
		$TestRecord.ExtAttrib.Value | should be 'Value2'
	}
}