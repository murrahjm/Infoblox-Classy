#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests. 
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#
#
#order tests as below
#create extensible attribute definitions
#create dns views
#create network views
#create dns zones
#create ipam networks
#create dns records
#create fixed address records
#all get tests
#all set tests
#all delete tests
$Recordlist = @()
write-output "Gridmaster:  $gridmaster"
write-output "wapi version:  $Wapiversion"

Describe "Test-Gridmaster" {
	It "Tests accessibility to infoblox gridmaster" {
		Test-IBGridMaster -gridmaster $Gridmaster | should be $True
	}
}
Describe "New-IBExtensibleAttributeDefinition tests" {
	It "Creates new extensible attribute definition with value type String" {
		$Record = New-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -Name 'EA2' -Type 'String' -DefaultValue 'Corp' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_ExtAttrsDef'
		$Record.Name | should be 'EA2'
		$Record.Type | should be 'String'
		$Record.Comment | should benullorempty
		$Record.DefaultValue | should be 'Corp'
	}
	It "Creates new extensible attribute definition with value type String" {
		$Record = New-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -Name 'EA3' -Type 'String' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_ExtAttrsDef'
		$Record.Name | should be 'EA3'
		$Record.Type | should be 'String'
		$Record.Comment | should benullorempty
		$Record.DefaultValue | should benullorempty
	}
	It "Creates new extensible attribute with value type Int and comment" {
		$Record = New-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -Name 'extattr2' -Type 'Integer' -comment 'test comment' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_ExtAttrsDef'
		$Record.Name | should be 'extattr2'
		$Record.Type | should be 'Integer'
		$Record.Comment | should be 'test comment'
		$Record.DefaultValue | should benullorempty
	}
}
Describe "New-IBView tests" {
	It "Creates new dns view" {
		$Record = New-IBView -Gridmaster $Gridmaster -credential $Credential -Name 'view2' -comment 'Second View' -Type 'DNSView' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_View'
		$Record.Name | should be 'view2'
		$Record.Comment | should be 'Second View'
		$Record.is_default | should be $False
	}
	It "Creates dns view with no comment" {
		$Record = New-IBView -Gridmaster $Gridmaster -credential $Credential -Name 'view3' -Type 'DNSView' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_View'
		$Record.Name | should be 'view3'
		$Record.Comment | should benullorempty
		$Record.is_default | should be $False
	}
	It "Creates new network view" {
		$Record = New-IBView -Gridmaster $Gridmaster -credential $Credential -Name 'networkview2' -comment 'Second networkview' -Type 'NetworkView' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_NetworkView'
		$Record.Name | should be 'networkview2'
		$Record.Comment | should be 'Second networkview'
		$Record.is_default | should be $False
	}
	It "Creates network view with no comment" {
		$Record = New-IBView -Gridmaster $Gridmaster -credential $Credential -Name 'networkview3' -Type 'NetworkView' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_NetworkView'
		$Record.Name | should be 'networkview3'
		$Record.Comment | should benullorempty
		$Record.is_default | should be $False
	}

}
Describe "New-IBNetwork tests" {
	It "Creates network in the default view with comment" {
		$Record = New-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -Network '12.0.0.0/8' -comment 'network 1' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_Network'
		$Record.Network | should be '12.0.0.0/8'
		$Record.comment | should be 'network 1'
		$Record.networkview | should be 'default'
		$Record.networkcontainer | should be '/'
	}
	It "Creates network in the alternate view with no comment" {
		$Record = New-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -Network '12.0.0.0/8' -networkview 'networkview2' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_Network'
		$Record.Network | should be '12.0.0.0/8'
		$Record.comment | should benullorempty
		$Record.networkview | should be 'networkview2'
		$Record.networkcontainer | should be '/'
	}
	It "Creates network with above network as container in default view with no comment" {
		$Record = New-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -Network '12.12.0.0/16' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_Network'
		$Record.Network | should be '12.12.0.0/16'
		$Record.comment | should benullorempty
		$Record.networkview | should be 'default'
		$Record.networkcontainer | should be '12.0.0.0/8'
	}
	It "Creates network with network container in a non-default view with no comment" {
		$Record = New-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -Network '12.12.0.0/16' -networkview 'networkview2' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_Network'
		$Record.Network | should be '12.12.0.0/16'
		$Record.comment | should benullorempty
		$Record.networkview | should be 'networkview2'
		$Record.networkcontainer | should be '12.0.0.0/8'
	}
	It "Creates network with no network container in a third view with no comment" {
		$Record = New-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -Network '12.12.0.0/16' -networkview 'networkview3' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_Network'
		$Record.Network | should be '12.12.0.0/16'
		$Record.comment | should benullorempty
		$Record.networkview | should be 'networkview3'
		$Record.networkcontainer | should be '/'
	}
	It "Creates network with network container in a second view with a comment" {
		$Record = New-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -Network '192.168.1.0/24' -comment 'view2 comment' -networkview 'networkview2' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_Network'
		$Record.Network | should be '192.168.1.0/24'
		$Record.comment | should be 'view2 comment'
		$Record.networkview | should be 'networkview2'
		$Record.networkcontainer | should be '/'
	}
}

Describe "New-IBDNSZone tests" {
	It "Creates forward lookup DNS zone in default view" {
		$Record = New-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -FQDN 'domain.com' -zoneFormat 'forward' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_ZoneAuth'
		$Record.FQDN | should be 'domain.com'
		$Record.comment | should benullorempty
		$Record.view | should be 'default'
		$Record.zoneFormat | should be 'forward'
	}
	It "Creates forward lookup zone in second view with comment and default type (forward)" {
		$Record = New-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -FQDN 'domain.com' -view 'view2' -comment 'test zone' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_ZoneAuth'
		$Record.FQDN | should be 'domain.com'
		$Record.comment | should be 'test zone'
		$Record.view | should be 'view2'
		$Record.zoneFormat | should be 'forward'
	}
	It "Creates forward lookup zone in third view with no comment and default type" {
		$Record = New-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -FQDN 'domain.com' -view 'view3' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_ZoneAuth'
		$Record.FQDN | should be 'domain.com'
		$Record.comment | should benullorempty
		$Record.view | should be 'view3'
		$Record.zoneFormat | should be 'forward'
	}
	It "Creates reverse lookup zone in default view with no comment" {
		$Record = New-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -FQDN '12.0.0.0/8' -zoneformat 'IPv4' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_ZoneAuth'
		$Record.FQDN | should be '12.0.0.0/8'
		$Record.comment | should benullorempty
		$Record.view | should be 'default'
		$Record.zoneFormat | should be 'ipv4'
	}
	It "Creates reverse lookup zone in second view with no comment" {
		$Record = New-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -FQDN '12.0.0.0/8' -zoneformat 'IPv4' -view view2 -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_ZoneAuth'
		$Record.FQDN | should be '12.0.0.0/8'
		$Record.comment | should benullorempty
		$Record.view | should be 'view2'
		$Record.zoneFormat | should be 'ipv4'
	}
	It "Creates reverse lookup zone in default view with comment" {
		$Record = New-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -FQDN '192.168.0.0/16' -zoneformat 'IPv4' -comment "PTR Zone" -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_ZoneAuth'
		$Record.FQDN | should be '192.168.0.0/16'
		$Record.comment | should be 'PTR Zone'
		$Record.view | should be 'default'
		$Record.zoneFormat | should be 'ipv4'
	}
}
Describe "New-IBDNSARecord tests" {
	It "Throws error with invalid IP address parameter" {
		{New-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name 'testrecord' -IPAddress 'notanipaddress'} | should throw
	}
	It "Throws error with invalid TTL parameter" {
		{New-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name 'testrecord' -IPAddress '12.12.1.1' -TTL 'notaTTL'} | should Throw
	}
	It "Throws with empty gridmaster" {
		{New-IBDNSARecord -Gridmaster '' -Credential $Credential -Name 'testrecord' -IPAddress '12.12.1.1'} | should throw
	}
	It "Throws with empty name" {
		{New-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name '' -IPAddress '12.12.1.1'} | should throw
	}
	It "Creates dns A record in default view with no comment or TTL" {
		$Record = New-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name 'testrecord.domain.com' -IPAddress '12.12.1.1' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_DNSARecord'
		$Record.View | should be 'default'
		$Record.Name | should be 'testrecord.domain.com'
		$Record.IPAddress | should be '12.12.1.1'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}
	It "Creates dns A record in default view with comment and TTL" {
		$Record = New-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name 'testrecord2.domain.com' -IPAddress '12.12.1.1' -Comment 'test comment' -TTL 100 -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_DNSARecord'
		$Record.View | should be 'default'
		$Record.Name | should be 'testrecord2.domain.com'
		$Record.IPAddress | should be '12.12.1.1'
		$Record.comment | should be 'test comment'
		$Record.TTL | should be 100
		$Record.Use_TTL | should be $True
	}
	It "Creates dns A record in specified view with no comment or TTL" {
		$Record = New-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name 'testrecord4.domain.com' -IPAddress '12.12.1.1' -View 'view2' -confirm:$False 
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_DNSARecord'
		$Record.View | should be 'view2'
		$Record.Name | should be 'testrecord4.domain.com'
		$Record.IPAddress | should be '12.12.1.1'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}

}
Describe "New-IBDNSCNameRecord tests" {
	It "Throws error with invalid TTL parameter" {
		{New-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Name 'testalias' -Canonical 'testrecord.domain.com' -TTL 'notaTTL'} | should throw
	}
	It "Throws error with empty gridmaster" {
		{New-IBDNSCNameRecord -Gridmaster '' -Credential $Credential -Name 'testalias' -Canonical 'testrecord.domain.com'} | should throw
	}
	It "Throws error with empty name" {
		{New-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Name '' -Canonical 'testrecord.domain.com'} | should throw
	}
	It "Throws error with empty canonical" {
		{New-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Name 'testalias' -Canonical ''} | should throw
	}
	It "Creates dns CName Record in default view with no comment or TTL" {
		$Record = New-IBDNSCNameRecord -confirm:$False  -Gridmaster $Gridmaster -Credential $Credential -Name 'testalias.domain.com' -Canonical 'testrecord.domain.com'
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_DNSCNameRecord'
		$Record.View | should be 'default'
		$Record.Name | should be 'testalias.domain.com'
		$Record.canonical | should be 'testrecord.domain.com'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}
	It "Creates dns CName Record in default view with comment and TTL" {
		$Record = New-IBDNSCNameRecord -confirm:$False  -Gridmaster $Gridmaster -Credential $Credential -Name 'testalias2.domain.com' -Canonical 'testrecord.domain.com' -Comment 'test comment' -TTL 100
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_DNSCNameRecord'
		$Record.View | should be 'default'
		$Record.Name | should be 'testalias2.domain.com'
		$Record.canonical | should be 'testrecord.domain.com'
		$Record.comment | should be 'test comment'
		$Record.TTL | should be 100
		$Record.Use_TTL | should be $True
	}
	It "Creates dns CName Record in specified view with no comment or TTL" {
		$Record = New-IBDNSCNameRecord -confirm:$False  -Gridmaster $Gridmaster -Credential $Credential -Name 'testalias4.domain.com' -Canonical 'testrecord.domain.com' -View 'view2'
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_DNSCNameRecord'
		$Record.View | should be 'view2'
		$Record.Name | should be 'testalias4.domain.com'
		$Record.canonical | should be 'testrecord.domain.com'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}

}
Describe "New-IBDNSPTRRecord tests" {
	It "Throws error with invalid IP address parameter" {
		{New-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'testrecord' -IPAddress 'notanIP'} | should throw
	}
	It "Throws error with invalid TTL parameter" {
		{New-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'testrecord' -IPAddress '12.12.1.1' -TTL 'notaTTL'} | should throw
	}
	It "Throws error with empty gridmaster" {
		{New-IBDNSPTRRecord -Gridmaster '' -Credential $Credential -PTRDName 'testrecord' -IPAddress '12.12.1.1'} | should throw
	}
	It "Throws error with empty PTRDName" {
		{New-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -PTRDName '' -IPAddress '12.12.1.1'} | should throw
	}
	It "Throws error with empty IPAddress" {
		{New-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'testrecord' -IPAddress ''} | should throw
	}
	It "Creates dns PTR record in default view with no comment or TTL" {
		$record = New-IBDNSPTRRecord -confirm:$False  -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'testrecord.domain.com' -IPAddress '12.12.1.1'
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_DNSPTRRecord'
		$Record.View | should be 'default'
		$Record.PTRDName | should be 'testrecord.domain.com'
		$Record.IPAddress | should be '12.12.1.1'
		$Record.Name | should be '1.1.12.12.in-addr.arpa'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}
	It "Creates dns PTR Record in default view with comment and TTL" {
		$record = New-IBDNSPTRRecord -confirm:$False  -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'testrecord2.domain.com' -IPAddress '12.12.1.2' -Comment 'test comment' -TTL 100
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_DNSPTRRecord'
		$Record.View | should be 'default'
		$Record.PTRDName | should be 'testrecord2.domain.com'
		$Record.IPAddress | should be '12.12.1.2'
		$Record.Name | should be '2.1.12.12.in-addr.arpa'
		$Record.comment | should be 'test comment'
		$Record.TTL | should be 100
		$Record.Use_TTL | should be $True
	}
	It "Creates dns PTR Record in specified view with no comment or TTL" {
		$record = New-IBDNSPTRRecord -confirm:$False  -Gridmaster $Gridmaster -Credential $Credential -PTRDName 'testrecord4.domain.com' -IPAddress '12.12.1.1' -View 'view2'
		$Script:Recordlist += $Record
		$Record.GetType().Name | should be 'IB_DNSPTRRecord'
		$Record.View | should be 'view2'
		$Record.PTRDName | should be 'testrecord4.domain.com'
		$Record.IPAddress | should be '12.12.1.1'
		$Record.Name | should be '1.1.12.12.in-addr.arpa'
		$Record.comment | should benullorempty
		$Record.TTL | should be 0
		$Record.Use_TTL | should be $False
	}

}
Describe "New-IBFixedAddress tests" {
	It "Throws error with invalid IP Address object" {
		{New-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -Name 'testrecord' -IPAddress 'notanIP'} | should Throw
	}
	It "Throws error with empty gridmaster" {
		{New-IBFixedAddress -Gridmaster '' -Credential $Credential -Name 'testrecord' -IPAddress '12.12.1.1'} | should Throw
	}
	It "Throws error with empty IP" {
		{New-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -Name 'testrecord' -IPAddress ''} | should Throw
	}
	It "Creates fixedaddress with no name or comment and zero mac in default view" {
		$TestRecord = New-IBFixedAddress -confirm:$False  -Gridmaster $Gridmaster -Credential $Credential -IPAddress '12.12.1.1'
		$Script:Recordlist += $TestRecord
		$TestRecord.GetType().name | Should be 'IB_FixedAddress'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Name | should benullorempty
		$TestRecord.Comment | should benullorempty
		$TestRecord.mac | should be '00:00:00:00:00:00'
		$TestRecord.NetworkView | should be 'default'
	}
	It "Creates fixedaddress with no name or comment and non-zero mac in default view" {
		$TestRecord = New-IBFixedAddress -confirm:$False  -Gridmaster $Gridmaster -Credential $Credential -IPAddress '12.12.1.2' -MAC '12:12:12:12:12:12'
		$Script:Recordlist += $TestRecord
		$TestRecord.GetType().name | Should be 'IB_FixedAddress'
		$TestRecord.IPAddress | should be '12.12.1.2'
		$TestRecord.Name | should benullorempty
		$TestRecord.Comment | should benullorempty
		$TestRecord.mac | should be '12:12:12:12:12:12'
		$TestRecord.NetworkView | should be 'default'
	}
	It "Creates fixedaddress with name, no comment and zero mac in default view" {
		$TestRecord = New-IBFixedAddress -confirm:$False  -Gridmaster $Gridmaster -Credential $Credential -Name 'newtestrecord' -IPAddress '12.12.1.3' -MAC "00:00:00:00:00:00"
		$Script:Recordlist += $TestRecord
		$TestRecord.GetType().name | Should be 'IB_FixedAddress'
		$TestRecord.IPAddress | should be '12.12.1.3'
		$TestRecord.Name | should be 'newtestrecord'
		$TestRecord.Comment | should benullorempty
		$TestRecord.mac | should be '00:00:00:00:00:00'
		$TestRecord.NetworkView | should be 'default'
	}
	It "Creates fixedaddress with name and comment and non-zero mac in default view" {
		$TestRecord = New-IBFixedAddress -confirm:$False  -Gridmaster $Gridmaster -Credential $Credential -Name 'newtestrecord' -IPAddress '12.12.1.4' -Comment 'comment' -MAC '22:22:22:22:22:22'
		$Script:Recordlist += $TestRecord
		$TestRecord.GetType().name | Should be 'IB_FixedAddress'
		$TestRecord.IPAddress | should be '12.12.1.4'
		$TestRecord.Name | should be 'newtestrecord'
		$TestRecord.Comment | should be 'comment'
		$TestRecord.mac | should be '22:22:22:22:22:22'
		$TestRecord.NetworkView | should be 'default'
	}
	It "Creates fixedaddress with comment, no name and non-zero mac in specified view" {
		$TestRecord = New-IBFixedAddress -confirm:$False  -Gridmaster $Gridmaster -Credential $Credential -Comment 'comment' -NetworkView 'networkview3' -IPAddress '12.12.1.5' -MAC '12:12:12:12:12:12'
		$Script:Recordlist += $TestRecord
		$TestRecord.GetType().name | Should be 'IB_FixedAddress'
		$TestRecord.IPAddress | should be '12.12.1.5'
		$TestRecord.Name | should benullorempty
		$TestRecord.Comment | should be 'comment'
		$TestRecord.mac | should be '12:12:12:12:12:12'
		$TestRecord.NetworkView | should be 'networkview3'
	}

}
Describe "Get-IBExtensibleAttributeDefinition tests" {
	$AllEADs = get-ibextensibleattributedefinition -gridmaster $gridmaster -credential $Credential
	It "Returns extensible attributes with specified refstring" {
		$Ref = $AllEADs.where{$_._ref -like 'extensibleattributedef/*:EA2'}._ref
		$Result = Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -_Ref $ref
		$Result.GetType().Name | should be 'IB_ExtAttrsDef'
		$Result.Name | should be 'EA2'
	}
	It "Returns all extensible attribute definitions" {
		$Result = Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential
		$Result[0].GetType().Name | should be 'IB_ExtAttrsDef'
	}
}
Describe "Get-IBView tests" {
	[array]$AllIBViews = get-ibview -Gridmaster $gridmaster -Credential $credential -Type NetworkView
	[array]$AllIBViews += get-ibview -gridmaster $gridmaster -Credential $credential -Type DNSView
	It "Returns dnsview with specified refstring" {
		$ref = $AllIBViews.where{$_._ref -like 'view/*/true'}._ref
		$Result = Get-IBView -Gridmaster $gridmaster -Credential $credential -_Ref $ref
		$Result.GetType().Name | should be 'IB_View'
		$Result._ref | should be $ref
		$Result.Name | should be 'default'
		$Result.Comment | should benullorempty
		$Result.is_default | should be $True
	}
	It "Returns networkview with specified refstring" {
		$ref = $AllIBViews.where{$_._ref -like 'networkview/*/true'}._ref
		$Result = Get-IBView -Gridmaster $gridmaster -Credential $credential -_Ref $ref
		$Result.GetType().Name | should be 'IB_networkView'
		$Result._ref | should be $ref
		$Result.Name | should be 'default'
		$Result.Comment | should benullorempty
		$Result.is_default | should be $True
	}
	It "Returns default networkview" {
		$Result = Get-IBView -Gridmaster $gridmaster -credential $credential -Type NetworkView -IsDefault $True
		$Result.GetType().Name | should be 'IB_networkView'
		$Result.Name | should be 'default'
		$Result.Comment | should benullorempty
		$Result.is_default | should be $True
	}
	It "Returns non-default networkviews" {
		$Result = Get-IBView -Gridmaster $gridmaster -Credential $credential -Type NetworkView -IsDefault $False
		$Result.count | should be 2
		#
		$Result[0].GetType().Name | should be 'IB_NetworkView'
		$Result[0].Name | should be 'networkview2'
		$Result[0].comment | should be 'Second networkview'
		$Result[0].is_default | should be $False
		#
		$Result[1].GetType().Name | should be 'IB_NetworkView'
		$Result[1].Name | should be 'networkview3'
		$Result[1].comment | should benullorempty
		$Result[1].is_default | should be $False

	}
	It "Returns default dnsview" {
		$Result = Get-IBView -Gridmaster $gridmaster -credential $credential -Type DNSView -IsDefault $True
		$Result.GetType().Name | should be 'IB_View'
		$Result.Name | should be 'default'
		$Result.Comment | should benullorempty
		$Result.is_default | should be $True

	}
	It "Returns non-default dnsviews" {
		$Result = Get-IBView -Gridmaster $gridmaster -credential $credential -Type DNSView -IsDefault $False
		$Result.count | should be 4
		#
		$Result[0].GetType().Name | should be 'IB_View'
		$Result[0].Name | should be 'view2'
		$Result[0].comment | should be 'Second View'
		$Result[0].is_default | should be $False
		#
		$Result[1].GetType().Name | should be 'IB_View'
		$Result[1].Name | should be 'view3'
		$Result[1].comment | should benullorempty
		$Result[1].is_default | should be $False
		#
		$Result[2].GetType().Name | should be 'IB_View'
		$Result[2].Name | should be 'default.networkview2'
		$Result[2].comment | should benullorempty
		$Result[2].is_default | should be $False
		#
		$Result[3].GetType().Name | should be 'IB_View'
		$Result[3].Name | should be 'default.networkview3'
		$Result[3].comment | should benullorempty
		$Result[3].is_default | should be $False
	}
	It "Throws error with invalid Type value" {
		{Get-IBView -Gridmaster $gridmaster -Credential $credential -type 'badtype'} | should throw
	}
	It "Returns all dns views with no other parameters" {
		$Result = Get-IBView -gridmaster $Gridmaster -Credential $Credential -Type DNSView
		$Result.Count | should be 5
		#
		$Result[0].GetType().Name | should be 'IB_View'
		$Result[0].Name | should be 'default'
		$Result[0].comment | should benullorempty
		$Result[0].is_default | should be $True
		#
		$Result[1].GetType().Name | should be 'IB_View'
		$Result[1].Name | should be 'view2'
		$Result[1].comment | should be 'Second View'
		$Result[1].is_default | should be $False
		#
		$Result[2].GetType().Name | should be 'IB_View'
		$Result[2].Name | should be 'view3'
		$Result[2].comment | should benullorempty
		$Result[2].is_default | should be $False
		#
		$Result[3].GetType().Name | should be 'IB_View'
		$Result[3].Name | should be 'default.networkview2'
		$Result[3].comment | should benullorempty
		$Result[3].is_default | should be $False
		#
		$Result[4].GetType().Name | should be 'IB_View'
		$Result[4].Name | should be 'default.networkview3'
		$Result[4].comment | should benullorempty
		$Result[4].is_default | should be $False

	}
	It "Returns all network views with no other parameters" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView
		$Result.Count | should be 3
		#
		$Result[0].GetType().Name | should be 'IB_NetworkView'
		$Result[0].Name | should be 'default'
		$Result[0].comment | should benullorempty
		$Result[0].is_default | should be $True
		#
		$Result[1].GetType().Name | should be 'IB_NetworkView'
		$Result[1].Name | should be 'networkview2'
		$Result[1].comment | should be 'Second networkview'
		$Result[1].is_default | should be $False
		#
		$Result[2].GetType().Name | should be 'IB_NetworkView'
		$Result[2].Name | should be 'networkview3'
		$Result[2].comment | should benullorempty
		$Result[2].is_default | should be $False
	}
	It "Returns dns view with specified name parameter" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -Name 'default' -Strict
		$Result[0].GetType().Name | should be 'IB_View'
		$Result.Name | should be 'default'
		$Result.comment | should benullorempty
		$Result.is_default | should be $True
	}
	It "Returns network view with specified name parameter" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Name 'default' -Strict
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result.Name | should be 'default'
		$Result.comment | should benullorempty
		$Result.is_default | should be $True
	}
	It "Returns dns views with non-strict name search" {
		$result = Get-IBView -Gridmaster $gridmaster -Credential $Credential -Type DNSView -Name 'view'
		$result.count | should be 4
		#
		$Result[2].GetType().Name | should be 'IB_View'
		$Result[2].Name | should be 'view2'
		$Result[2].comment | should be 'Second View'
		$Result[2].is_default | should be $False
		#
		$Result[3].GetType().Name | should be 'IB_View'
		$Result[3].Name | should be 'view3'
		$Result[3].comment | should benullorempty
		$Result[3].is_default | should be $False
		#
		$Result[0].GetType().Name | should be 'IB_View'
		$Result[0].Name | should be 'default.networkview2'
		$Result[0].comment | should benullorempty
		$Result[0].is_default | should be $False
		#
		$Result[1].GetType().Name | should be 'IB_View'
		$Result[1].Name | should be 'default.networkview3'
		$Result[1].comment | should benullorempty
		$Result[1].is_default | should be $False
	}
	It "Returns network views with non-strict name search" {
		$result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Name 'networkview'
		$result.count | should be 2
		#
		$Result[0].GetType().Name | should be 'IB_NetworkView'
		$Result[0].Name | should be 'networkview2'
		$Result[0].comment | should be 'Second networkview'
		$Result[0].is_default | should be $False
		#
		$Result[1].GetType().Name | should be 'IB_NetworkView'
		$Result[1].Name | should be 'networkview3'
		$Result[1].comment | should benullorempty
		$Result[1].is_default | should be $False
	}
	It "Returns null from dnsview type strict name search with zero matches" {
		$result = Get-IBView -Gridmaster $gridmaster -Credential $Credential -Type DNSView -Name 'view' -Strict
		$Result | should benullorempty
	}
	It "Returns null from networkview type strict name search with zero matches" {
		$result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Name 'networkview' -Strict
		$Result | should benullorempty
	}
	It "gets first dnsview with no query but resultscount of 1" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -MaxResults 1
		$Result.GetType().Name | should be 'IB_View'
		$Result.Name | should be 'default'
		$Result.comment | should benullorempty
		$Result.is_default | should be $True
	}
	It "gets dnsview with strict comment search" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -Comment 'Second View' -Strict
		$Result.GetType().Name | should be 'IB_View'
		$Result.Name | should be 'view2'
		$Result.comment | should be 'Second View'
		$Result.is_default | should be $False
	}
	It "gets dnsview with non-strict comment search" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -Comment 'Second View'
		$Result.GetType().Name | should be 'IB_View'
		$Result.Name | should be 'view2'
		$Result.comment | should be 'Second View'
		$Result.is_default | should be $False
	}
	It "gets dnsview with non-strict name and comment search" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -Name 'view' -Comment 'Second'
		$Result[0].GetType().Name | should be 'IB_View'
		$Result.Name | should be 'view2'
		$Result.comment | should be 'Second View'
		$Result.is_default | should be $False
	}
	It "gets dnsview with strict name, comment and is_default search" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView -Name 'view2' -Comment 'Second View' -IsDefault 'False'
		$Result[0].GetType().Name | should be 'IB_View'
		$Result.Name | should be 'view2'
		$Result.comment | should be 'Second View'
		$Result.is_default | should be $False
	}
	It "gets first networkview with no query but resultscount of 1" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -MaxResults 1
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result.Name | should be 'default'
		$Result.comment | should benullorempty
		$Result.is_default | should be $True
	}
	It "gets networkview with strict comment search" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -comment 'Second networkview' -strict
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result.Name | should be 'networkview2'
		$Result.comment | should be 'Second networkview'
		$Result.is_default | should be $False
	}
	It "gets networkview with non-strict comment search" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Comment 'Second networkview'
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result.Name | should be 'networkview2'
		$Result.comment | should be 'Second networkview'
		$Result.is_default | should be $False
	}
	It "gets networkview with non-strict name and comment search" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Name 'networkview' -comment 'Second networkview'
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result.Name | should be 'networkview2'
		$Result.comment | should be 'Second Networkview'
		$Result.is_default | should be $False
	}
	It "gets networkview with strict name, comment and is_default search" {
		$Result = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -Name 'networkview2' -comment 'Second networkview' -Strict -isdefault False
		$Result.GetType().Name | should be 'IB_NetworkView'
		$Result.Name | should be 'networkview2'
		$Result.comment | should be 'Second networkview'
		$Result.is_default | should be $false
	}

}
Describe "Get-IBDNSZone tests" {
	It "Gets forward zones in default view" {
		$Result = get-IBDNSZone -gridmaster $gridmaster -credential $Credential -zoneformat forward -view default
		$Result.Count | should be 1
		$Result[0].GetType().Name | should be 'IB_ZoneAuth'
		$Result[0].fqdn | should be 'domain.com'
		$Result[0].view | should be 'default'
	}
	It "Gets reverse zones by fqdn search" {
		$Result = Get-IBDNSZone -gridmaster $gridmaster -credential $Credential -zoneformat ipv4 -fqdn 12.0.0.0/8
		$Result.count | should be 2
		$Result[0].GetType().Name | should be 'IB_ZoneAuth'
		$Result[0].fqdn | should be '12.0.0.0/8'
		$Result[0].view | should be 'default'
		#
		$Result[1].GetType().Name | should be 'IB_ZoneAuth'
		$Result[1].fqdn | should be '12.0.0.0/8'
		$Result[1].view | should be 'view2'
	}
}
Describe "Get-IBNetwork tests" {
	
}
Describe "Find-IBRecord" {
	It "Returns records from non-strict Name search" {
		$return = Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString testrecord
		$Return.count | should be 9
		#
		$Return[0].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[0].Name | should be '1.1.12.12.in-addr.arpa'
		$Return[0].view | should be 'view2'
		#
		$Return[1].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[1].name | should be '1.1.12.12.in-addr.arpa'
		$Return[1].view | should be 'default'
		#
		$Return[2].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[2].name | should be '2.1.12.12.in-addr.arpa'
		$Return[2].view | should be 'default'
		#
		$Return[3].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[3].name | should be 'testalias4.domain.com'
		$Return[3].view | should be 'view2'
		#
		$Return[4].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[4].name | should be 'testalias.domain.com'
		$Return[4].view | should be 'default'
		#
		$Return[5].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[5].name | should be 'testalias2.domain.com'
		$Return[5].view | should be 'default'
		#
		$Return[6].GetType().Name | should be 'IB_DNSARecord'
		$Return[6].name | should be 'testrecord4.domain.com'
		$Return[6].view | should be 'view2'
		#
		$Return[7].GetType().Name | should be 'IB_DNSARecord'
		$Return[7].name | should be 'testrecord.domain.com'
		$Return[7].view | should be 'default'
		#
		$Return[8].GetType().Name | should be 'IB_DNSARecord'
		$Return[8].name | should be 'testrecord2.domain.com'
		$Return[8].view | should be 'default'
	}
	It "Returns a records with non-strict name and type search" {
		$return = Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString testrecord -Recordtype 'record:a'
		$return.count | should be 3
		#
		$Return[0].GetType().Name | should be 'IB_DNSARecord'
		$Return[0].name | should be 'testrecord4.domain.com'
		$Return[0].view | should be 'view2'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1].name | should be 'testrecord.domain.com'
		$Return[1].view | should be 'default'
		#
		$Return[2].GetType().Name | should be 'IB_DNSARecord'
		$Return[2].name | should be 'testrecord2.domain.com'
		$Return[2].view | should be 'default'
	}
	It "Returns records from IPAddress search" {
		$Return = Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress '12.12.1.1'
		$Return.count | should be 11
		#
		$Return[0].GetType().Name | should be 'IB_FixedAddress'
		$Return[0].ipaddress | should be '12.12.1.1'
		$Return[0].networkview | should be 'default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1].name | should be 'testrecord.domain.com'
		$Return[1].view | should be 'default'
		#
		$Return[2].GetType().Name | should be 'IB_DNSARecord'
		$Return[2].name | should be 'testrecord4.domain.com'
		$Return[2].view | should be 'view2'
		#
		$Return[3].GetType().Name | should be 'IB_DNSARecord'
		$Return[3].name | should be 'testrecord2.domain.com'
		$Return[3].view | should be 'default'
		#
		$Return[4].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[4].name | should be '1.1.12.12.in-addr.arpa'
		$Return[4].view | should be 'view2'
		#
		$Return[5].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[5].name | should be '1.1.12.12.in-addr.arpa'
		$Return[5].view | should be 'default'
	}
	It "Throws error from IPAddress and type search" {
		{Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress '12.12.1.1' -Recordtype fixedaddress} | should throw
	}
	It "Returns records from strict name search" {
		$return = Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString testrecord.domain.com -Strict
		$Return.count | should be 5
		#
		$Return[0].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[0].name | should be '1.1.12.12.in-addr.arpa'
		$Return[0].view | should be 'default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[1].name | should be 'testalias4.domain.com'
		$Return[1].view | should be 'view2'
		#
		$Return[2].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[2].name | should be 'testalias.domain.com'
		$Return[2].view | should be 'default'
		#
		$Return[3].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[3].name | should be 'testalias2.domain.com'
		$Return[3].view | should be 'default'
		#
		$Return[4].GetType().Name | should be 'IB_DNSARecord'
		$Return[4].name | should be 'testrecord.domain.com'
		$Return[4].view | should be 'default'
	}
	It "Returns cname records from strict name and type search" {
		$return = Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString testrecord.domain.com -Strict -Recordtype 'record:cname'
		$Return.count | should be 3
		#
		$Return[0].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[0].name | should be 'testalias4.domain.com'
		$Return[0].view | should be 'view2'
		#
		$Return[1].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[1].name | should be 'testalias.domain.com'
		$Return[1].view | should be 'default'
		#
		$Return[2].GetType().Name | should be 'IB_DNSCNameRecord'
		$Return[2].name | should be 'testalias2.domain.com'
		$Return[2].view | should be 'default'
	}
	It "Returns records from IPAddress search through the pipeline" {
		$Return = '12.12.1.1' | Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential
		$Return.count | should be 11
		#
		$Return[0].GetType().Name | should be 'IB_FixedAddress'
		$Return[0].ipaddress | should be '12.12.1.1'
		$Return[0].networkview | should be 'default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1].name | should be 'testrecord.domain.com'
		$Return[1].view | should be 'default'
		#
		$Return[2].GetType().Name | should be 'IB_DNSARecord'
		$Return[2].name | should be 'testrecord4.domain.com'
		$Return[2].view | should be 'view2'
		#
		$Return[3].GetType().Name | should be 'IB_DNSARecord'
		$Return[3].name | should be 'testrecord2.domain.com'
		$Return[3].view | should be 'default'
		#
		$Return[4].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[4].name | should be '1.1.12.12.in-addr.arpa'
		$Return[4].view | should be 'view2'
		#
		$Return[5].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[5].name | should be '1.1.12.12.in-addr.arpa'
		$Return[5].view | should be 'default'
	}
	It "Returns records from multiple IPAddress search through the pipeline" {
		$Return = @('12.12.1.1','12.12.2.2') | Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential
		$Return.count | should be 16
		#
		$Return[0].GetType().Name | should be 'IB_FixedAddress'
		$Return[0].ipaddress | should be '12.12.1.1'
		$Return[0].networkview | should be 'default'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1].name | should be 'testrecord.domain.com'
		$Return[1].view | should be 'default'
		#
		$Return[2].GetType().Name | should be 'IB_DNSARecord'
		$Return[2].name | should be 'testrecord4.domain.com'
		$Return[2].view | should be 'view2'
		#
		$Return[3].GetType().Name | should be 'IB_DNSARecord'
		$Return[3].name | should be 'testrecord2.domain.com'
		$Return[3].view | should be 'default'
		#
		$Return[4].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[4].name | should be '1.1.12.12.in-addr.arpa'
		$Return[4].view | should be 'view2'
		#
		$Return[5].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[5].name | should be '1.1.12.12.in-addr.arpa'
		$Return[5].view | should be 'default'
	}
	It "Returns records from strict name search through the pipeline" {
		$Return = 'testrecord4.domain.com' | Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -Strict
		$Return.Count | should be 2
		#
		$Return[0].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[0].ptrdname | should be 'testrecord4.domain.com'
		$Return[0].view | should be 'view2'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1].name | should be 'testrecord4.domain.com'
		$Return[1].view | should be 'view2'

	}
	It "Returns records from multiple strict name search through the pipeline" {
		$Return = @('testrecord4.domain.com','testrecord2.domain.com') | Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -Strict
		$Return.Count | should be 4
		#
		$Return[0].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[0].ptrdname | should be 'testrecord4.domain.com'
		$Return[0].view | should be 'view2'
		#
		$Return[1].GetType().Name | should be 'IB_DNSARecord'
		$Return[1].name | should be 'testrecord4.domain.com'
		$Return[1].view | should be 'view2'
		#
		$Return[2].GetType().Name | should be 'IB_DNSPTRRecord'
		$Return[2].ptrdname | should be 'testrecord2.domain.com'
		$Return[2].view | should be 'default'
		#
		$Return[3].GetType().Name | should be 'IB_DNSARecord'
		$Return[3].IPAddress | should be '12.12.1.1'
		$Return[3].view | should be 'default'
	}
	It "Throws error with both name and IPAddress parameter" {
		{Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -Name 'name' -ipaddress '12.12.1.1'} | should throw
	}
	It "Throws error with invalid IPAddress object" {
		{Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress 'notanIP'} | should throw
	}
}
Describe "Get-IBDNSARecord tests" {
	It "Throws error with invalid IP Address object" {
		{Get-IBDNSARecord -gridmaster $gridmaster -credential $Credential -IPAddress 'notanIPAddress'} | should throw
	}
	It "Throws error with invalid integer object" {
		{Get-IBDNSARecord -gridmaster $gridmaster -credential $Credential -maxResults 'notanInt'} | should throw
	}
	It "Throws error with empty gridmaster" {
		{Get-IBDNSARecord -gridmaster $Null -credential $Credential} | should throw
	}
	It "Returns A record from ref query" {
		$Ref = $script:Recordlist.where{$_._ref -like "record:a/*:testrecord.domain.com/default"}._ref
		$TestRecord = Get-IBDNSARecord -gridmaster $Gridmaster -credential $Credential -_Ref $Ref
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord._ref | should be $Ref
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Returns A record from strict name query" {
		$TestRecord = Get-IBDNSARecord -gridmaster $gridmaster -credential $credential -name 'testrecord.domain.com' -strict
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Returns multiple A records from non-strict name query" {
		$TestRecord = Get-IBDNSARecord -gridmaster $gridmaster -credential $credential -name 'testrecord'
		$TestRecord.count | should be 3
		#
		$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[0].Name | should be 'testrecord4.domain.com'
		$TestRecord[0].View | should be 'view2'
		$TestRecord[0].IPAddress | should be '12.12.1.1'
		$TestRecord[0].Comment | should benullorempty
		$TestRecord[0].TTL | should be 0
		$TestRecord[0].Use_TTL | should be $False
		#
		$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[1].Name | should be 'testrecord.domain.com'
		$TestRecord[1].View | should be 'default'
		$TestRecord[1].IPAddress | should be '12.12.1.1'
		$TestRecord[1].Comment | should benullorempty
		$TestRecord[1].TTL | should be 0
		$TestRecord[1].Use_TTL | should be $False
		#
		$TestRecord[2].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[2].Name | should be 'testrecord2.domain.com'
		$TestRecord[2].View | should be 'default'
		$TestRecord[2].IPAddress | should be '12.12.1.1'
		$TestRecord[2].Comment | should be 'test comment'
		$TestRecord[2].TTL | should be 100
		$TestRecord[2].Use_TTL | should be $True

	}
	It "Returns multiple A records from zone query" {
		$TestRecord = Get-IBDNSARecord -gridmaster $gridmaster -credential $Credential -zone 'domain.com'
		$TestRecord.count | should be 2
		#
		$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[0].Name | should be 'testrecord.domain.com'
		$TestRecord[0].View | should be 'default'
		$TestRecord[0].IPAddress | should be '12.12.1.1'
		$TestRecord[0].Comment | should benullorempty
		$TestRecord[0].TTL | should be 0
		$TestRecord[0].Use_TTL | should be $False
		#
		$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[1].Name | should be 'testrecord2.domain.com'
		$TestRecord[1].View | should be 'default'
		$TestRecord[1].IPAddress | should be '12.12.1.1'
		$TestRecord[1].Comment | should be 'test comment'
		$TestRecord[1].TTL | should be 100
		$TestRecord[1].Use_TTL | should be $True
	}
	It "Returns multiple A records from IP Address query" {
		$TestRecord = Get-IBDNSARecord -gridmaster $gridmaster -credential $Credential -ipaddress '12.12.1.1'
		$TestRecord.count | should be 3
		#
		$TestRecord[0].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[0].Name | should be 'testrecord.domain.com'
		$TestRecord[0].View | should be 'default'
		$TestRecord[0].IPAddress | should be '12.12.1.1'
		$TestRecord[0].Comment | should benullorempty
		$TestRecord[0].TTL | should be 0
		$TestRecord[0].Use_TTL | should be $False
		#
		$TestRecord[1].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[1].Name | should be 'testrecord2.domain.com'
		$TestRecord[1].View | should be 'default'
		$TestRecord[1].IPAddress | should be '12.12.1.1'
		$TestRecord[1].Comment | should be 'test comment'
		$TestRecord[1].TTL | should be 100
		$TestRecord[1].Use_TTL | should be $True
		#
		$TestRecord[2].GetType().Name | should be 'IB_DNSARecord'
		$TestRecord[2].Name | should be 'testrecord4.domain.com'
		$TestRecord[2].View | should be 'view2'
		$TestRecord[2].IPAddress | should be '12.12.1.1'
		$TestRecord[2].Comment | should benullorempty
		$TestRecord[2].TTL | should be 0
		$TestRecord[2].Use_TTL | should be $False
	}
	It "Returns A record from view query" {
		$TestRecord = Get-IBDNSARecord -gridmaster $Gridmaster -credential $Credential -view 'view2'
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord4.domain.com'
		$TestRecord.View | should be 'view2'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False

	}
	It "Returns A record from strict comment query" {
		$TestRecord = Get-IBDNSARecord -gridmaster $Gridmaster -credential $Credential -comment 'test comment' -strict
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True

	}
	It "Returns A record from non-strict comment query" {
		$TestRecord = Get-IBDNSARecord -gridmaster $Gridmaster -credential $Credential -comment 'test comment'
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
	}
	It "Returns A record from strict name and IP Address query" {
		$TestRecord = Get-IBDNSARecord -gridmaster $Gridmaster -credential $Credential -name 'testrecord.domain.com' -ipaddress '12.12.1.1' -Strict
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Returns A record from strict name and view query" {
		$TestRecord = Get-IBDNSARecord -gridmaster $Gridmaster -credential $Credential -name 'testrecord.domain.com' -view 'default' -strict
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Returns A record from strict name and zone query" {
		$TestRecord = Get-IBDNSARecord -gridmaster $Gridmaster -credential $Credential -name 'testrecord.domain.com' -zone 'domain.com' -strict
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Returns A record from non-strict name query with results count of 1" {
		$TestRecord = Get-IBDNSARecord -gridmaster $gridmaster -credential $Credential -name 'testrecord' -maxResults 1
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord4.domain.com'
		$TestRecord.View | should be 'view2'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False

	}
}
Describe "Get-IBDNSCNameRecord tests" {
	Context "Get Method" {
		It "Throws error with invalid integer object" {
			{Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -maxResults 'notanInt'} | should throw
		}
		It "Throws error with empty gridmaster" {
			{Get-IBDNSCNameRecord -gridmaster $Null -credential $Credential} | should throw
		}
		It "Returns CName Record from ref query" {
			$Ref = $Script:Recordlist.where{$_._ref -like "record:cname/*:testalias.domain.com/default"}._ref
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -_Ref $Ref
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should benullorempty
			$testalias._ref | should be $Ref
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False
		}
		It "Returns CName Record from strict name query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -name 'testalias.domain.com' -strict
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should benullorempty
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False
		}
		It "Returns multiple CName Records from non-strict name query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -name 'testalias'
			$testalias.count | should be 3
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias4.domain.com'
			$testalias[0].View | should be 'view2'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should benullorempty
			$testalias[0].TTL | should be 0
			$testalias[0].Use_TTL | should be $False
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias.domain.com'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should benullorempty
			$testalias[1].TTL | should be 0
			$testalias[1].Use_TTL | should be $False
			#
			$testalias[2].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[2].Name | should be 'testalias2.domain.com'
			$testalias[2].View | should be 'default'
			$testalias[2].canonical | should be 'testrecord.domain.com'
			$testalias[2].Comment | should be 'test comment'
			$testalias[2].TTL | should be 100
			$testalias[2].Use_TTL | should be $True
		}
		It "Returns multiple CName Records from non-strict canonical query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -canonical 'testrecord'
			$testalias.count | should be 3
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should benullorempty
			$testalias[0].TTL | should be 0
			$testalias[0].Use_TTL | should be $False
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias2.domain.com'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment'
			$testalias[1].TTL | should be 100
			$testalias[1].Use_TTL | should be $True
			#
			$testalias[2].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[2].Name | should be 'testalias4.domain.com'
			$testalias[2].View | should be 'view2'
			$testalias[2].canonical | should be 'testrecord.domain.com'
			$testalias[2].Comment | should benullorempty
			$testalias[2].TTL | should be 0
			$testalias[2].Use_TTL | should be $False
		}
		It "Returns multiple CName Records from zone query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -zone 'domain.com'
			$testalias.count | should be 2
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should benullorempty
			$testalias[0].TTL | should be 0
			$testalias[0].Use_TTL | should be $False
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias2.domain.com'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment'
			$testalias[1].TTL | should be 100
			$testalias[1].Use_TTL | should be $True
		}
		It "Returns multiple CName Records from strict canonical query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -canonical 'testrecord.domain.com' -strict
			$testalias.count | should be 3
			#
			$testalias[0].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[0].Name | should be 'testalias.domain.com'
			$testalias[0].View | should be 'default'
			$testalias[0].canonical | should be 'testrecord.domain.com'
			$testalias[0].Comment | should benullorempty
			$testalias[0].TTL | should be 0
			$testalias[0].Use_TTL | should be $False
			#
			$testalias[1].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[1].Name | should be 'testalias2.domain.com'
			$testalias[1].View | should be 'default'
			$testalias[1].canonical | should be 'testrecord.domain.com'
			$testalias[1].Comment | should be 'test comment'
			$testalias[1].TTL | should be 100
			$testalias[1].Use_TTL | should be $True
			#
			$testalias[2].GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias[2].Name | should be 'testalias4.domain.com'
			$testalias[2].View | should be 'view2'
			$testalias[2].canonical | should be 'testrecord.domain.com'
			$testalias[2].Comment | should benullorempty
			$testalias[2].TTL | should be 0
			$testalias[2].Use_TTL | should be $False
		}
		It "Returns CName Record from view query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -view 'view2'
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias4.domain.com'
			$testalias.View | should be 'view2'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should benullorempty
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False
		}
		It "Returns CName Record from strict comment query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -comment 'test comment' -strict
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias2.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias.TTL | should be 100
			$testalias.Use_TTL | should be $True

		}
		It "Returns CName Record from non-strict comment query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -comment 'test comment'
			#
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias2.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias.TTL | should be 100
			$testalias.Use_TTL | should be $True
		}
		It "Returns CName Record from non-strict name and comment query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -name 'testalias' -comment 'test comment'
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias2.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should be 'test comment'
			$testalias.TTL | should be 100
			$testalias.Use_TTL | should be $True
		}
		It "Returns CName Record from strict name and canonical query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -name 'testalias.domain.com' -canonical 'testrecord.domain.com' -strict
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should benullorempty
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False
		}
		It "Returns CName Record from strict name and view query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -name 'testalias.domain.com' -view 'default' -strict
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should benullorempty
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False
		}
		It "Returns CName Record from strict name and zone query" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -name 'testalias.domain.com' -zone 'domain.com' -strict
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias.domain.com'
			$testalias.View | should be 'default'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should benullorempty
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False
		}
		It "Returns CName Record from non-strict name query with results count of 1" {
			$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -name 'testalias' -maxresults 1
			$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
			$testalias.Name | should be 'testalias4.domain.com'
			$testalias.View | should be 'view2'
			$testalias.canonical | should be 'testrecord.domain.com'
			$testalias.Comment | should benullorempty
			$testalias.TTL | should be 0
			$testalias.Use_TTL | should be $False
		}
	}
}
Describe "Get-IBDNSPTRRecord tests" {
	Context "Get Method" {
		It "Throws error with invalid IP Address object" {
			{Get-IBDNSPTRRecord -gridmaster $gridmaster -credential $Credential -ipaddress 'notanipaddress'} | should throw
		}
		It "Throws error with invalid integer object" {
			{Get-IBDNSPTRRecord -gridmaster $gridmaster -credential $Credential -maxresults 'notanInt'} | should throw
		}
		It "Throws error with empty gridmaster" {
			{Get-IBDNSPTRRecord -gridmaster $Null -credential $credential} | should throw
		}
		It "Returns PTR Record from ref query" {
			$Ref = $Script:recordlist.where{$_._ref -like "record:ptr/*:1.1.12.12.in-addr.arpa/default"}._ref
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref $Ref
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '12.12.1.1'
			$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord.Comment | should benullorempty
			$TestRecord._ref | should be $Ref
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
		It "Returns PTR Record from strict name query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -name '1.1.12.12.in-addr.arpa' -strict
			$TestRecord.Count | should be 2
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord4.domain.com'
			$TestRecord[0].View | should be 'view2'
			$TestRecord[0].IPAddress | should be '12.12.1.1'
			$TestRecord[0].Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord[0].Comment | should benullorempty
			$TestRecord[0].TTL | should be 0
			$TestRecord[0].Use_TTL | should be $False
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '12.12.1.1'
			$TestRecord[1].Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord[1].Comment | should benullorempty
			$TestRecord[1].TTL | should be 0
			$TestRecord[1].Use_TTL | should be $False
		}
		It "Returns multiple PTR Records from non-strict name query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -name '1.1'
			$TestRecord.Count | should be 3
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord4.domain.com'
			$TestRecord[0].View | should be 'view2'
			$TestRecord[0].IPAddress | should be '12.12.1.1'
			$TestRecord[0].Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord[0].Comment | should benullorempty
			$TestRecord[0].TTL | should be 0
			$TestRecord[0].Use_TTL | should be $False
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '12.12.1.1'
			$TestRecord[1].Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord[1].Comment | should benullorempty
			$TestRecord[1].TTL | should be 0
			$TestRecord[1].Use_TTL | should be $False
			#
			$TestRecord[2].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[2].PTRDName | should be 'testrecord2.domain.com'
			$TestRecord[2].View | should be 'default'
			$TestRecord[2].IPAddress | should be '12.12.1.2'
			$TestRecord[2].Name | should be '2.1.12.12.in-addr.arpa'
			$TestRecord[2].Comment | should be 'test comment'
			$TestRecord[2].TTL | should be 100
			$TestRecord[2].Use_TTL | should be $True
		}
		It "Returns PTR Record from strict ptrdname query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ptrdname 'testrecord.domain.com' -strict
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '12.12.1.1'
			$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord.Comment | should benullorempty
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
		It "Returns multiple PTR Records from non-strict ptrdname query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ptrdname 'testrecord'
			$TestRecord.count | should be 3
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '12.12.1.1'
			$TestRecord[0].Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord[0].Comment | should benullorempty
			$TestRecord[0].TTL | should be 0
			$TestRecord[0].Use_TTL | should be $False
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord2.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '12.12.1.2'
			$TestRecord[1].Name | should be '2.1.12.12.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment'
			$TestRecord[1].TTL | should be 100
			$TestRecord[1].Use_TTL | should be $True
			#
			$TestRecord[2].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[2].PTRDName | should be 'testrecord4.domain.com'
			$TestRecord[2].View | should be 'view2'
			$TestRecord[2].IPAddress | should be '12.12.1.1'
			$TestRecord[2].Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord[2].Comment | should benullorempty
			$TestRecord[2].TTL | should be 0
			$TestRecord[2].Use_TTL | should be $False

		}
		It "Returns multiple PTR Records from zone query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -zone '12.in-addr.arpa'
			$TestRecord.count | should be 2
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '12.12.1.1'
			$TestRecord[0].Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord[0].Comment | should benullorempty
			$TestRecord[0].TTL | should be 0
			$TestRecord[0].Use_TTL | should be $False
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord2.domain.com'
			$TestRecord[1].View | should be 'default'
			$TestRecord[1].IPAddress | should be '12.12.1.2'
			$TestRecord[1].Name | should be '2.1.12.12.in-addr.arpa'
			$TestRecord[1].Comment | should be 'test comment'
			$TestRecord[1].TTL | should be 100
			$TestRecord[1].Use_TTL | should be $True
		}
		It "Returns PTR Record from IP Address query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ipaddress '12.12.1.1'
			$TestRecord.count | should be 2
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord.domain.com'
			$TestRecord[0].View | should be 'default'
			$TestRecord[0].IPAddress | should be '12.12.1.1'
			$TestRecord[0].Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord[0].Comment | should benullorempty
			$TestRecord[0].TTL | should be 0
			$TestRecord[0].Use_TTL | should be $False
			#
			$TestRecord[1].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[1].PTRDName | should be 'testrecord4.domain.com'
			$TestRecord[1].View | should be 'view2'
			$TestRecord[1].IPAddress | should be '12.12.1.1'
			$TestRecord[1].Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord[1].Comment | should benullorempty
			$TestRecord[1].TTL | should be 0
			$TestRecord[1].Use_TTL | should be $False
		}
		It "Returns PTR Record from view query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -view 'view2'
			$TestRecord.count | should be 3
			#
			$TestRecord[0].GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord[0].PTRDName | should be 'testrecord4.domain.com'
			$TestRecord[0].View | should be 'view2'
			$TestRecord[0].IPAddress | should be '12.12.1.1'
			$TestRecord[0].Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord[0].Comment | should benullorempty
			$TestRecord[0].TTL | should be 0
			$TestRecord[0].Use_TTL | should be $False
		}
		It "Returns PTR Record from strict comment query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'test comment' -strict
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord2.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '12.12.1.2'
			$TestRecord.Name | should be '2.1.12.12.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord.TTL | should be 100
			$TestRecord.Use_TTL | should be $True
		}
		It "Returns PTR Record from non-strict comment query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'test comment'
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord2.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '12.12.1.2'
			$TestRecord.Name | should be '2.1.12.12.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord.TTL | should be 100
			$TestRecord.Use_TTL | should be $True
		}
		It "Returns PTR Record from non-strict ptrdname and comment query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ptrdname 'testrecord' -comment 'test comment'
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord2.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '12.12.1.2'
			$TestRecord.Name | should be '2.1.12.12.in-addr.arpa'
			$TestRecord.Comment | should be 'test comment'
			$TestRecord.TTL | should be 100
			$TestRecord.Use_TTL | should be $True
		}
		It "Returns PTR Record from strict ptrdname and IP Address query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ptrdname 'testrecord.domain.com' -ipaddress '12.12.1.1' -strict
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '12.12.1.1'
			$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord.Comment | should benullorempty
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
		It "Returns PTR Record from strict name and view query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -name '1.1.12.12.in-addr.arpa' -view 'default' -strict
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '12.12.1.1'
			$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord.Comment | should benullorempty
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
		It "Returns PTR Record from strict name and zone query" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -name '1.1.12.12.in-addr.arpa' -zone '12.in-addr.arpa' -strict
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '12.12.1.1'
			$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord.Comment | should benullorempty
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
		It "Returns PTR Record from non-strict ptrdname query with results count of 1" {
			$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ptrdname 'testrecord' -maxresults 1
			$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
			$TestRecord.PTRDName | should be 'testrecord.domain.com'
			$TestRecord.View | should be 'default'
			$TestRecord.IPAddress | should be '12.12.1.1'
			$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
			$TestRecord.Comment | should benullorempty
			$TestRecord.TTL | should be 0
			$TestRecord.Use_TTL | should be $False
		}
	}
}
Describe "Get-IBFixedAddress tests" {
	Context 'Get Method' {
		It "Throws error with invalid IP Address object" {
			{Get-IBFixedAddress -gridmaster $gridmaster -credential $Credential -ipaddress 'notanIP'} | should Throw
		}
		It "Throws error with invalid integer object" {
			{Get-IBFixedAddress -gridmaster $gridmaster -credential $Credential -maxresults 'notanint'} | should throw
		}
		It "Throws error with empty gridmaster" {
			{Get-IBFixedAddress -gridmaster '' -credential $Credential} | should throw
		}
		It "Returns fixed address from ref query" {
			$Ref = $Script:Recordlist.where{$_._ref -like "fixedaddress/*:12.12.1.1/default"}._ref
			$Return = Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -_Ref $Ref
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return._ref | should be $Ref
			$Return.name | should benullorempty
			$Return.IPAddress | should be '12.12.1.1'
			$Return.comment | should benullorempty
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "Returns all fixed addresses from null query" {
			$Return = Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential
			$Return.Count | should be 5
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0].name | should benullorempty
			$Return[0].IPAddress | should be '12.12.1.1'
			$Return[0].comment | should benullorempty
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '00:00:00:00:00:00'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1].name | should benullorempty
			$Return[1].IPAddress | should be '12.12.1.2'
			$Return[1].comment | should benullorempty
			$Return[1].networkview | should be 'default'
			$Return[1].MAC | should be '12:12:12:12:12:12'
			#
			$Return[2].GetType().Name | should be 'IB_FixedAddress'
			$Return[2].name | should be 'newtestrecord'
			$Return[2].IPAddress | should be '12.12.1.3'
			$Return[2].comment | should benullorempty
			$Return[2].networkview | should be 'default'
			$Return[2].MAC | should be '00:00:00:00:00:00'
			#
			$Return[3].GetType().Name | should be 'IB_FixedAddress'
			$Return[3].name | should be 'newtestrecord'
			$Return[3].IPAddress | should be '12.12.1.4'
			$Return[3].comment | should be 'comment'
			$Return[3].networkview | should be 'default'
			$Return[3].MAC | should be '22:22:22:22:22:22'
			#
			$Return[4].GetType().Name | should be 'IB_FixedAddress'
			$Return[4].name | should benullorempty
			$Return[4].IPAddress | should be '12.12.1.5'
			$Return[4].comment | should be 'comment'
			$Return[4].networkview | should be 'networkview3'
			$Return[4].MAC | should be '12:12:12:12:12:12'
		}
		It "Returns fixed address from IP Address query" {
			$Return = Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -IPAddress '12.12.1.2'
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return.name | should benullorempty
			$Return.IPAddress | should be '12.12.1.2'
			$Return.comment | should benullorempty
			$Return.networkview | should be 'default'
			$Return.MAC | should be '12:12:12:12:12:12'
		}
		It "Returns fixed addresses from MAC address query" {
			$Return = Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -mac '00:00:00:00:00:00'
			$Return.Count | should be 2
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0].name | should benullorempty
			$Return[0].IPAddress | should be '12.12.1.1'
			$Return[0].comment | should benullorempty
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '00:00:00:00:00:00'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1].name | should be 'newtestrecord'
			$Return[1].IPAddress | should be '12.12.1.3'
			$Return[1].comment | should benullorempty
			$Return[1].networkview | should be 'default'
			$Return[1].MAC | should be '00:00:00:00:00:00'
		}
		It "Returns fixed addresses from non-strict comment query" {
			$Return = Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -comment 'comment'
			$Return.Count | should be 2
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0].name | should be 'newtestrecord'
			$Return[0].IPAddress | should be '12.12.1.4'
			$Return[0].comment | should be 'comment'
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '22:22:22:22:22:22'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1].name | should benullorempty
			$Return[1].IPAddress | should be '12.12.1.5'
			$Return[1].comment | should be 'comment'
			$Return[1].networkview | should be 'networkview3'
			$Return[1].MAC | should be '12:12:12:12:12:12'
		}
		It "Returns fixed address from strict comment query" {
			$Return = Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -comment 'comment' -Strict
			$Return.Count | should be 2
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0].name | should be 'newtestrecord'
			$Return[0].IPAddress | should be '12.12.1.4'
			$Return[0].comment | should be 'comment'
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '22:22:22:22:22:22'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1].name | should benullorempty
			$Return[1].IPAddress | should be '12.12.1.5'
			$Return[1].comment | should be 'comment'
			$Return[1].networkview | should be 'networkview3'
			$Return[1].MAC | should be '12:12:12:12:12:12'
		}
		It "Returns fixed addresses from networkview query" {
			$Return = Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -networkView 'default'
			$Return.Count | should be 4
			#
			$Return[0].GetType().Name | should be 'IB_FixedAddress'
			$Return[0].name | should benullorempty
			$Return[0].IPAddress | should be '12.12.1.1'
			$Return[0].comment | should benullorempty
			$Return[0].networkview | should be 'default'
			$Return[0].MAC | should be '00:00:00:00:00:00'
			#
			$Return[1].GetType().Name | should be 'IB_FixedAddress'
			$Return[1].name | should benullorempty
			$Return[1].IPAddress | should be '12.12.1.2'
			$Return[1].comment | should benullorempty
			$Return[1].networkview | should be 'default'
			$Return[1].MAC | should be '12:12:12:12:12:12'
			#
			$Return[2].GetType().Name | should be 'IB_FixedAddress'
			$Return[2].name | should be 'newtestrecord'
			$Return[2].IPAddress | should be '12.12.1.3'
			$Return[2].comment | should benullorempty
			$Return[2].networkview | should be 'default'
			$Return[2].MAC | should be '00:00:00:00:00:00'
			#
			$Return[3].GetType().Name | should be 'IB_FixedAddress'
			$Return[3].name | should be 'newtestrecord'
			$Return[3].IPAddress | should be '12.12.1.4'
			$Return[3].comment | should be 'comment'
			$Return[3].networkview | should be 'default'
			$Return[3].MAC | should be '22:22:22:22:22:22'
		}
		It "Returns fixed address from IP and MAC address query" {
			$Return = Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -IPAddress '12.12.1.1' -mac '00:00:00:00:00:00'
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return.name | should benullorempty
			$Return.IPAddress | should be '12.12.1.1'
			$Return.comment | should benullorempty
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "Returns fixed address from IP and networkview query" {
			$Return = Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -IPAddress '12.12.1.1' -networkview 'default'
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return.name | should benullorempty
			$Return.IPAddress | should be '12.12.1.1'
			$Return.comment | should benullorempty
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
		It "Returns fixed address from no query but resultscount set to 1" {
			$Return = Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -maxresults 1
			$Return.GetType().Name | should be 'IB_FixedAddress'
			$Return.name | should benullorempty
			$Return.IPAddress | should be '12.12.1.1'
			$Return.comment | should benullorempty
			$Return.networkview | should be 'default'
			$Return.MAC | should be '00:00:00:00:00:00'
		}
	}
}
Describe "Get-IBRecord tests" {
	It "Throws an error with an empty gridmaster" {
		{Get-IBRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Get-IBRecord -ea Stop} | should Throw
	}
	It "Returns A record from ref query" {
		$Ref = $Script:Recordlist.where{$_._ref -like "record:a/*:testrecord.domain.com/default"}._ref
		$TestRecord = Get-IBRecord -gridmaster $Gridmaster -credential $Credential -_Ref $Ref
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord._ref | should be $Ref
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Returns CName Record from ref query" {
		$Ref = $Script:Recordlist.where{$_._ref -like "record:cname/*:testalias.domain.com/default"}._ref
		$testalias = Get-IBRecord -gridmaster $gridmaster -credential $Credential -_Ref $Ref
		$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
		$testalias.Name | should be 'testalias.domain.com'
		$testalias.View | should be 'default'
		$testalias.canonical | should be 'testrecord.domain.com'
		$testalias.Comment | should benullorempty
		$testalias._ref | should be $Ref
		$testalias.TTL | should be 0
		$testalias.Use_TTL | should be $False
	}
	It "Returns PTR Record from ref query" {
		$Ref = $Script:Recordlist.where{$_._ref -like "record:ptr/*:1.1.12.12.in-addr.arpa/default"}._ref
		$TestRecord = Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref $Ref
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.Comment | should benullorempty
		$TestRecord._ref | should be $ref
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Returns fixed address from ref query" {
		$Ref = $Script:Recordlist.where{$_._ref -like "fixedaddress/*:12.12.1.1/default"}._ref
		$Return = Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref $Ref
		$Return.GetType().Name | should be 'IB_FixedAddress'
		$Return._ref | should be $Ref
		$Return.name | should benullorempty
		$Return.IPAddress | should be '12.12.1.1'
		$Return.comment | should benullorempty
		$Return.networkview | should be 'default'
		$Return.MAC | should be '00:00:00:00:00:00'
	}
	It "Returns A record from ref query through pipeline" {
		$Ref = $Script:Recordlist.where{$_._ref -like "record:a/*:testrecord.domain.com/default"}._ref
		$object = new-object PSObject -Property @{
			gridmaster = $Gridmaster
			credential = $Credential
			_ref = $Ref
		}
		$TestRecord = $object | Get-IBRecord
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord._ref | should be $Ref
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Returns CName Record from ref query through pipeline" {
		$Ref = $Script:Recordlist.where{$_._ref -like "record:cname/*:testalias.domain.com/default"}._ref
		$object = new-object PSObject -Property @{
			gridmaster = $Gridmaster
			credential = $Credential
			_ref = $Ref
		}
		$Testalias = $object | Get-IBRecord
		$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
		$testalias.Name | should be 'testalias.domain.com'
		$testalias.View | should be 'default'
		$testalias.canonical | should be 'testrecord.domain.com'
		$testalias.Comment | should benullorempty
		$testalias._ref | should be $Ref
		$testalias.TTL | should be 0
		$testalias.Use_TTL | should be $False
	}
	It "Returns PTR Record from ref query through pipeline" {
		$Ref = $Script:Recordlist.where{$_._ref -like "record:ptr/*:1.1.12.12.in-addr.arpa/default"}._ref
		$object = new-object PSObject -Property @{
			gridmaster = $Gridmaster
			credential = $Credential
			_ref = $Ref
		}
		$TestRecord = $object | Get-IBRecord
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.Comment | should benullorempty
		$TestRecord._ref | should be $Ref
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Returns fixed address from ref query through pipeline" {
		$Ref = $Script:Recordlist.where{$_._ref -like "fixedaddress/*:12.12.1.1/default"}._ref
		$object = new-object PSObject -Property @{
			gridmaster = $Gridmaster
			credential = $Credential
			_ref = $Ref
		}
		$Return = $object | Get-IBRecord
		$Return.GetType().Name | should be 'IB_FixedAddress'
		$Return._ref | should be $Ref
		$Return.name | should benullorempty
		$Return.IPAddress | should be '12.12.1.1'
		$Return.comment | should benullorempty
		$Return.networkview | should be 'default'
		$Return.MAC | should be '00:00:00:00:00:00'
	}
}
Describe "Set-IBExtensibleAttributeDefinition tests" {
	
}
Describe "Set-IBDNSZone tests" {
	
}
Describe "Set-IBNetwork tests" {
	
}

Describe "Set-IBDNSARecord tests" {
	#record retrieved before tests to allow tracking of changes to persist through each test
	$Ref = $Script:Recordlist.where{$_._ref -like "record:a/*:testrecord.domain.com/default"}._ref
	$TestRecord = [IB_DNSARecord]::Get($gridmaster,$Credential,$Ref)
	It "Throws an error with an invalid IP Address parameter" {
		{$TestRecord | Set-IBDNSARecord -IPAddress 'notanIP'} | should Throw
	}
	It "Throws an error with an invalid TTL parameter" {
		{$TestRecord | Set-IBDNSARecord -TTL 'notaTTL'} | should Throw
	}
	It "Throws an error with an empty gridmaster" {
		{Set-IBDNSARecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Set-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Set-IBDNSARecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		{Set-IBDNSARecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Set-IBDNSARecord -ea Stop} | should Throw
	}
	It "Makes no changes when Set-IBDNSARecord is called with no parameters" {
		$TestRecord | Set-IBDNSARecord -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment and IPAddress on an existing DNS Record with passthru" {
		$TestRecord = $TestRecord | Set-IBDNSARecord -IPAddress '12.12.2.2' -Comment 'new comment' -confirm:$False  -Passthru
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the TTL on an existing record" {
		$TestRecord | Set-IBDNSARecord -TTL 100 -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True

	}
	It "Clears the TTL on an existing Record" {
		$TestRecord | Set-IBDNSARecord -ClearTTL -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the TTL to 0 with Use_TTL set to True" {
		$TestRecord | Set-IBDNSARecord -TTL 0 -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL" {
		$TestRecord | Set-IBDNSARecord -TTL 100 -ClearTTL -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment to null" {
		$TestRecord | Set-IBDNSARecord -Comment $Null -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment and IPAddress on an existing DNS Record - using byRef method" {
		Set-IBDNSARecord -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref -IPAddress '12.12.2.2' -Comment 'new comment'
		$TestRecord = Get-IBDNSARecord -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be $TestRecord._Ref
	}
	It "Sets the TTL on an existing record - using byRef method" {
		Set-IBDNSARecord -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref -TTL 100
		$TestRecord = Get-IBDNSARecord -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be $TestRecord._Ref

	}
	It "Clears the TTL on an existing Record - using byRef method" {
		Set-IBDNSARecord -confirm:$False  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -ClearTTL
		$TestRecord = Get-IBDNSARecord  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be $TestRecord._Ref
	}
	It "Sets the TTL to 0 with Use_TTL set to True - using byRef method" {
		Set-IBDNSARecord -confirm:$False  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -TTL 0
		$TestRecord = Get-IBDNSARecord  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
		$TestRecord._ref | should be $TestRecord._Ref
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL - using byRef method and passthru" {
		$TestRecord = Set-IBDNSARecord -confirm:$False  -PassThru -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -TTL 100 -ClearTTL
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.name | should be 'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be $TestRecord._Ref
	}
	It "Sets the comment to null - using byRef method" {
		Set-IBDNSARecord -confirm:$False  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -Comment $Null
		$TestRecord = Get-IBDNSARecord  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.2.2'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
		$TestRecord._ref | should be $TestRecord._Ref
	}

}
Describe "Set-IBDNSCNameRecord tests" {
	#record retrieved before tests to allow tracking of changes to persist through each test
	$Ref = $Script:Recordlist.where{$_._ref -like "record:cname/*:testalias.domain.com/default"}._ref
	$TestRecord = [IB_DNSCNameRecord]::Get($gridmaster,$Credential,$Ref)
	It "Throws an error with an invalid TTL parameter" {
		{$TestRecord | Set-IBDNSCNameRecord -TTL 'notaTTL'} | should Throw
	}
	It "Throws an error with an empty gridmaster" {
		{Set-IBDNSCNameRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Set-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Set-IBDNSCNameRecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		{Set-IBDNSCNameRecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Set-IBDNSCNameRecord -ea Stop} | should Throw
	}
	It "Makes no changes when Set-IBDNSCNameRecord is called with no parameters" {
		$TestRecord | Set-IBDNSCNameRecord -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.Canonical | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment and canonical on an existing DNS Record with passthru" {
		$TestRecord = $TestRecord | Set-IBDNSCNameRecord -Canonical 'testrecord2.domain.com' -Comment 'new comment' -confirm:$False  -Passthru
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the TTL on an existing record" {
		$TestRecord | Set-IBDNSCNameRecord -TTL 100 -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
	}
	It "Clears the TTL on an existing Record" {
		$TestRecord | Set-IBDNSCNameRecord -ClearTTL -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the TTL to 0 with Use_TTL set to True" {
		$TestRecord | Set-IBDNSCNameRecord -TTL 0 -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL" {
		$TestRecord | Set-IBDNSCNameRecord -TTL 100 -ClearTTL -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment to null" {
		$TestRecord | Set-IBDNSCNameRecord -Comment $Null -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment and canonical on an existing DNS Record - using byRef method" {
		Set-IBDNSCNameRecord -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref -canonical 'testrecord2.domain.com' -Comment 'new comment'
		$TestRecord = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the TTL on an existing record - using byRef method" {
		Set-IBDNSCNameRecord -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref -TTL 100
		$TestRecord = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
	}
	It "Clears the TTL on an existing Record - using byRef method" {
		Set-IBDNSCNameRecord -confirm:$False  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -ClearTTL
		$TestRecord = Get-IBDNSCNameRecord  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the TTL to 0 with Use_TTL set to True - using byRef method" {
		Set-IBDNSCNameRecord -confirm:$False  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -TTL 0
		$TestRecord = Get-IBDNSCNameRecord  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL - using byRef method and passthru" {
		$TestRecord = Set-IBDNSCNameRecord -confirm:$False  -PassThru -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -TTL 100 -ClearTTL
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment to null - using byRef method" {
		Set-IBDNSCNameRecord -confirm:$False  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -Comment $Null
		$TestRecord = Get-IBDNSCNameRecord  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSCNameRecord'
		$TestRecord.canonical | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be 'testalias.domain.com'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
}
Describe "Set-IBDNSPTRRecord tests" {
	#record retrieved before tests to allow tracking of changes to persist through each test
	$Ref = $Script:Recordlist.where{$_._ref -like "record:ptr/*:1.1.12.12.in-addr.arpa/default"}._ref
	$TestRecord = [IB_DNSPTRRecord]::Get($gridmaster,$Credential,$Ref)
	It "Throws an error with an invalid TTL parameter" {
		{$TestRecord | Set-IBDNSPTRRecord -TTL 'notaTTL'} | should Throw
	}
	It "Throws an error with an empty gridmaster" {
		{Set-IBDNSPTRRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Set-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Set-IBDNSPTRRecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		{Set-IBDNSPTRRecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Set-IBDNSPTRRecord -ea Stop} | should Throw
	}
	It "Makes no changes when Set-IBDNSPTRRecord is called with no parameters" {
		$TestRecord | Set-IBDNSPTRRecord -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment and canonical on an existing DNS Record with passthru" {
		$TestRecord = $TestRecord | Set-IBDNSPTRRecord -PTRDName 'testrecord2.domain.com' -Comment 'new comment' -confirm:$False -Passthru
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the TTL on an existing record" {
		$TestRecord | Set-IBDNSPTRRecord -TTL 100 -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
	}
	It "Clears the TTL on an existing Record" {
		$TestRecord | Set-IBDNSPTRRecord -ClearTTL -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the TTL to 0 with Use_TTL set to True" {
		$TestRecord | Set-IBDNSPTRRecord -TTL 0 -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL" {
		$TestRecord | Set-IBDNSPTRRecord -TTL 100 -ClearTTL -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment to null" {
		$TestRecord | Set-IBDNSPTRRecord -Comment $Null -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment and PTRDName on an existing DNS Record - using byRef method" {
		Set-IBDNSPTRRecord -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref -PTRDName 'testrecord2.domain.com' -Comment 'new comment'
		$TestRecord = Get-IBDNSPTRRecord -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the TTL on an existing record - using byRef method" {
		Set-IBDNSPTRRecord -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref -TTL 100
		$TestRecord = Get-IBDNSPTRRecord -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
	}
	It "Clears the TTL on an existing Record - using byRef method" {
		Set-IBDNSPTRRecord -confirm:$False  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -ClearTTL
		$TestRecord = Get-IBDNSPTRRecord  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the TTL to 0 with Use_TTL set to True - using byRef method" {
		Set-IBDNSPTRRecord -confirm:$False  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -TTL 0
		$TestRecord = Get-IBDNSPTRRecord  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $True
	}
	It "Sets the TTL but also uses -clearTTL, which results in a null TTL - using byRef method and passthru" {
		$TestRecord = Set-IBDNSPTRRecord -confirm:$False  -PassThru -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -TTL 100 -ClearTTL
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Sets the comment to null - using byRef method" {
		Set-IBDNSPTRRecord -confirm:$False  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref -Comment $Null
		$TestRecord = Get-IBDNSPTRRecord  -gridmaster $gridmaster -credential $Credential -_Ref $TestRecord._Ref
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be  'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
}
Describe "Set-IBFixedAddress tests" {
	#record retrieved before tests to allow tracking of changes to persist through each test
	$Ref = $Script:Recordlist.where{$_._ref -like "fixedaddress/*:12.12.1.1/default"}._ref
	$TestRecord = [IB_FixedAddress]::Get($gridmaster,$Credential,$Ref)
	It "Throws an error with an invalid TTL parameter" {
		{$TestRecord | Set-IBFixedAddress -TTL 'notaTTL'} | should Throw
	}
	It "Throws an error with an empty gridmaster" {
		{Set-IBFixedAddress -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Set-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Set-IBFixedAddress -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		{Set-IBFixedAddress -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Set-IBFixedAddress -ea Stop} | should Throw
	}
	It "Makes no changes when Set-IBFixedAddress is called with no parameters" {
		$TestRecord | Set-IBFixedAddress -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should benullorempty
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '00:00:00:00:00:00'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
	}
	It "Sets the comment and Name on an existing DNS Record with passthru" {
		$TestRecord = $TestRecord | Set-IBFixedAddress -Name 'testrecord2.domain.com' -Comment 'new comment' -confirm:$False -Passthru
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '00:00:00:00:00:00'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
	}
	It "Sets the MAC on an existing record" {
		$TestRecord | Set-IBFixedAddress -MAC '13:13:13:13:13:13' -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '13:13:13:13:13:13'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
	}
	It "Sets the comment to null" {
		$TestRecord | Set-IBFixedAddress -Comment $Null -confirm:$False 
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '13:13:13:13:13:13'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
	}
	It "Sets the comment and Name on an existing DNS Record - using byRef method" {
		Set-IBFixedAddress -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $Testrecord._Ref -Name 'testrecord2.domain.com' -Comment 'new comment'
		$TestRecord = Get-IBFixedAddress -gridmaster $gridmaster -credential $credential -_Ref $Testrecord._Ref
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '13:13:13:13:13:13'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
	}
	It "Sets the MAC on an existing record - using byRef method" {
		Set-IBFixedAddress -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $Testrecord._Ref  -MAC '00:00:00:00:00:00'
		$TestRecord = Get-IBFixedAddress -gridmaster $gridmaster -credential $Credential -_Ref $Testrecord._Ref
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '00:00:00:00:00:00'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'new comment'
	}
	It "Sets the comment to null - using byRef method" {
		Set-IBFixedAddress -confirm:$False  -gridmaster $gridmaster -credential $Credential -_Ref $Testrecord._Ref -Comment $Null
		$TestRecord = Get-IBFixedAddress  -gridmaster $gridmaster -credential $Credential -_Ref $Testrecord._Ref
		$TestRecord.GetType().Name | should be 'IB_FixedAddress'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.NetworkView | should be 'default'
		$TestRecord.MAC | should be '00:00:00:00:00:00'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should benullorempty
	}
}
Describe "Add-IBExtensibleAttribute, Remove-IBExtensibleAttribute tests" {
	#record retrieved before tests to allow tracking of changes to persist through each test
	$Ref = $Script:Recordlist.where{$_._ref -like "record:a/*:testrecord2.domain.com/default"}._ref
	$TestRecord = Get-IBDNSARecord -Gridmaster $gridmaster -Credential $Credential -_ref $Ref
	It "Throws an error with an empty gridmaster" {
		{Add-IBExtensibleAttribute -Gridmaster '' -Credential $Credential -_Ref 'refstring' -eaname 'EA' -eavalue 'value'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref -eaname 'EA' -eavalue 'value'} | should throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Get-IBRecord -ea Stop -eaname 'EA' -eavalue 'value'} | should Throw
	}
	It "Adds extensible attribute by object pipeline with passthru option" {
		$TestRecord = $TestRecord | Add-IBExtensibleAttribute -EAName Site -EAValue corp -Passthru -confirm:$False 
		$TestRecord.ExtAttrib.Name | should be 'Site'
		$TestRecord.ExtAttrib.value | should be 'corp'
	}
	It "Updates the value of an existing extensible attribute by object pipeline with passthru option" {
		$TestRecord = $TestRecord | Add-IBExtensibleAttribute -eaname Site -eavalue gulf -Passthru -confirm:$False 
		$TestRecord.ExtAttrib | measure-object | select -ExpandProperty Count | should be 1
		$TestRecord.ExtAttrib.Name | should be 'Site'
		$TestRecord.ExtAttrib.value | should be 'gulf'
	}
	It "Adds extensible attribute by ref" {
		Add-IBExtensibleAttribute -gridmaster $gridmaster -credential $credential -_ref $TestRecord._Ref -EAName 'EA2' -EAValue 'Value2' -confirm:$False 
		$TestRecord = Get-IBDNSARecord -Gridmaster $gridmaster -Credential $Credential -_ref $TestRecord._Ref
		$TestRecord.ExtAttrib | measure-object | select -ExpandProperty Count | should be 2
		$TestRecord.ExtAttrib[0].Name | should be 'EA2'
		$TestRecord.ExtAttrib[0].Value | should be 'Value2'
		$TestRecord.ExtAttrib[1].Name | should be 'Site'
		$TestRecord.ExtAttrib[1].Value | should be 'gulf'
	}
	It "Adds extensible attribute by object" {
		$TestRecord = Add-IBExtensibleAttribute -Record $testrecord -Passthru -EAName 'EA3' -EAValue 'Value3' -confirm:$False 
		$TestRecord.ExtAttrib | measure-object | % count | should be 3
		$TestRecord.ExtAttrib[0].Name | should be 'EA2'
		$TestRecord.ExtAttrib[0].Value | should be 'Value2'
		$TestRecord.ExtAttrib[1].Name | should be 'EA3'
		$TestRecord.ExtAttrib[1].Value | should be 'Value3'
		$TestRecord.ExtAttrib[2].Name | should be 'Site'
		$TestRecord.ExtAttrib[2].Value | should be 'gulf'
	}
	It "Returns A record from extensible attribute search" {
		$TestRecord = Get-IBDNSARecord -gridmaster $Gridmaster -credential $Credential -ExtAttributeQuery {Site -eq 'gulf'}
		$TestRecord.GetType().Name | should be 'IB_DNSARecord'
		$TestRecord.Name | should be 'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Comment | should be 'test comment'
		$TestRecord.TTL | should be 100
		$TestRecord.Use_TTL | should be $True
	}
	It "Returns CName Record from extensible attribute query" {
		Get-IBDNSCNameRecord -Gridmaster $gridmaster -Credential $Credential -name testalias.domain.com -view default | Add-IBExtensibleAttribute -EAName Site -EAValue corp -confirm:$False
		$testalias = Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $Credential -ExtAttributeQuery {Site -eq 'corp'}
		$testalias.GetType().Name | should be 'IB_DNSCNameRecord'
		$testalias.Name | should be 'testalias.domain.com'
		$testalias.View | should be 'default'
		$testalias.canonical | should be 'testrecord2.domain.com'
		$testalias.Comment | should benullorempty
		$testalias.TTL | should be 0
		$testalias.Use_TTL | should be $False
	}
	It "Returns PTR Record from extensible attribute query" {
		Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress 12.12.1.1 -View default | Add-IBExtensibleAttribute -EAName Site -EAValue corp -confirm:$False
		$TestRecord = Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -ExtAttributeQuery {Site -eq 'corp'}
		$TestRecord.GetType().Name | should be 'IB_DNSPTRRecord'
		$TestRecord.PTRDName | should be 'testrecord2.domain.com'
		$TestRecord.View | should be 'default'
		$TestRecord.IPAddress | should be '12.12.1.1'
		$TestRecord.Name | should be '1.1.12.12.in-addr.arpa'
		$TestRecord.Comment | should benullorempty
		$TestRecord.TTL | should be 0
		$TestRecord.Use_TTL | should be $False
	}
	It "Returns fixed address from extensible attribute query" {
		Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -IPAddress 12.12.1.1 -NetworkView default | Add-IBExtensibleAttribute -EAName Site -EAValue corp -Confirm:$False
		$Return = Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -ExtAttributeQuery {Site -eq 'corp'}
		$Return.GetType().Name | should be 'IB_FixedAddress'
		$Return.name | should be 'testrecord2.domain.com'
		$Return.IPAddress | should be '12.12.1.1'
		$Return.comment | should benullorempty
		$Return.networkview | should be 'default'
		$Return.MAC | should be '00:00:00:00:00:00'
	}

	It "Removes specified extensible attribute by ref" {
		$TestRecord = Remove-IBExtensibleAttribute -confirm:$False  -EAName Site -gridmaster $gridmaster -credential $credential -_ref $TestRecord._Ref -Passthru
		$TestRecord.ExtAttrib | measure-object | % Count | should be 2
		$TestRecord.ExtAttrib[0].Name | should be 'EA2'
		$TestRecord.ExtAttrib[0].Value | should be 'Value2'
		$TestRecord.ExtAttrib[1].Name | should be 'EA3'
		$TestRecord.ExtAttrib[1].Value | should be 'Value3'
	}
	It "Removes all extensible attributes by object" {
		$TestRecord = Get-IBDNSARecord -Gridmaster $gridmaster -Credential $Credential -_ref $TestRecord._ref
		$TestRecord = $TestRecord | Remove-IBExtensibleAttribute -RemoveAll -Passthru -confirm:$False 
		$TestReecord.Extattrib | should benullorempty
	}
	It "Removes specified extensible attribute by object" {
		$TestRecord = Get-IBDNScnameRecord -Gridmaster $gridmaster -Credential $Credential -name testalias.domain.com -View default
		Add-IBExtensibleAttribute -Record $TestRecord -EAName EA2 -EAValue 'Value2' -confirm:$False 
		Remove-IBExtensibleAttribute -Record $TestRecord -EAName Site -confirm:$False 
		$TestRecord = Get-IBDNScnameRecord -Gridmaster $gridmaster -Credential $Credential -name testalias.domain.com -View default
		$TestRecord.Extattrib | measure-object | % Count | should be 1
		$TestRecord.ExtAttrib.Name | should be 'EA2'
		$TestRecord.ExtAttrib.Value | should be 'Value2'
	}
}
Describe "Set-IBView tests"{
	$Viewref = $Script:Recordlist.where{$_._ref -like "view/*:view2/false"}._ref
	$networkviewref = $Script:Recordlist.where{$_._ref -like "networkview/*:networkview2/false"}
	$view = [IB_View]::Get($gridmaster,$credential,$viewref)
	$networkview = [IB_networkView]::Get($gridmaster,$Credential,$networkviewref)
	It "sets the comment on view2 to null with ref string" {
		Set-IBView -gridmaster $Gridmaster -credential $credential -_ref $viewref -comment $Null -confirm:$False
		$view = get-ibview -Gridmaster $Gridmaster -Credential $credential -name view2 -Type DNSView
		$view.Name | should be 'view2'
		$view.comment | should benullorempty
	}
	It "sets the comment on view3 using pipeline object" {
		$view3 = get-ibview -Gridmaster $gridmaster -Credential $credential -Name 'view3' -Type DNSView
		$view3 | set-ibview -comment 'third view' -confirm:$False
		$view3.Name | should be 'view3'
		$view3.comment | should be 'third view'
	}
	It "sets the name on view2 using pipeline object" {
		$view | set-ibview -name 'view2newname' -confirm:$False
		$view.name | should be 'view2newname'
		$view.comment | should benullorempty
	}
	It "sets the name and comment on view2 using ref string and passthru" {
		$view2 = set-ibview -gridmaster $gridmaster -credential $credential -name view2 -comment 'second view' -_ref $Viewref -confirm:$False
		$view2.Name | should be 'view2'
		$view2.comment | should be 'second view'
	}

	It "sets the comment on networkview2 to null with ref string" {
		set-ibview -gridmaster $Gridmaster -credential $Credential -_ref $networkviewref -comment $null -confirm:$False
		$networkview = get-ibview -Gridmaster $gridmaster -credential $credential -_ref $networkviewref -Type networkview
		$networkview.Name | should be 'networkview2'
		$networkview.comment | should benullorempty
	}
	It "sets the comment on networkview3 using pipeline object" {
		$networkview3 = get-ibview -Gridmaster $gridmaster -Credential $credential -Name 'networkview3' -Type NetworkView
		$networkview3 | set-ibview -comment 'third networkview' -confirm:$False
		$networkview3.Name | should be 'networkview3'
		$networkview3.comment | should be 'third networkview'
	}
	It "sets the name on networkview2 using pipeline object" {
		$networkview | set-ibview -name 'networkview2newname' -confirm:$False
		$networkview.name | should be 'networkview2newname'
		$networkview.comment | should benullorempty
	}
	It "sets the name and comment on networkview2 using ref string and passthru" {
		$networkview2 = set-ibview -gridmaster $gridmaster -credential $credential -name networkview2 -comment 'second networkview' -_ref $networkViewref -confirm:$False
		$networkview2.Name | should be 'networkview2'
		$networkview2.comment | should be 'second networkview'
	}
}
Describe "Remove-IBDNSARecord tests" {
	It "Throws an error with an empty gridmaster" {
		{Remove-IBDNSARecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Remove-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Remove-IBDNSARecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = Get-IBDNSARecord -Gridmaster $gridmaster -Credential $credential -name testrecord.domain.com -View default
		{Remove-IBDNSARecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Remove-IBDNSARecord -ea Stop} | should Throw
	}
	It "Deletes the record using byObject method" {
		$Record = Get-IBDNSARecord -Gridmaster $gridmaster -Credential $credential -name testrecord.domain.com -View default
		$Return = $Record | Remove-IBDNSARecord -confirm:$False 
		{[IB_DNSARecord]::Get($gridmaster,$Credential,$Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Record._ref
	}
	It "Deletes the record using byRef method" {
		$Record = Get-IBDNSARecord -Gridmaster $gridmaster -Credential $credential -name testrecord2.domain.com -View default
		$Return = Remove-IBDNSARecord -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $Record._ref
		{[IB_DNSARecord]::Get($gridmaster,$Credential,$Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Record._Ref
	}
}
Describe "Remove-IBDNSCNameRecord tests" {
	It "Throws an error with an empty gridmaster" {
		{Remove-IBDNSCNameRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Remove-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Remove-IBDNSCNameRecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = Get-IBDNSCNameRecord -Gridmaster $gridmaster -Credential $credential -name testalias.domain.com -View default
		{Remove-IBDNSCNameRecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Remove-IBDNSCNameRecord -ea Stop} | should Throw
	}
	It "Deletes the record using byObject method" {
		$TestRecord = Get-IBDNSCNameRecord -Gridmaster $gridmaster -Credential $credential -name testalias.domain.com -View default
		$Return = $TestRecord | Remove-IBDNSCNameRecord -confirm:$False 
		{[IB_DNSCNameRecord]::Get($gridmaster,$Credential,$TestRecord._Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $TestRecord._Ref
	}
	It "Deletes the record using byRef method" {
		$TestRecord = Get-IBDNSCNameRecord -Gridmaster $gridmaster -Credential $credential -name testalias2.domain.com -View default
		$Return = Remove-IBDNSCNameRecord -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref
		{[IB_DNSCNameRecord]::Get($gridmaster,$Credential,$Refstring)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $TestRecord._Ref
	}
}
Describe "Remove-IBDNSPTRRecord tests" {
	It "Throws an error with an empty gridmaster" {
		{Remove-IBDNSPTRRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Remove-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Remove-IBDNSPTRRecord -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = Get-IBDNSPTRRecord -Gridmaster $gridmaster -Credential $credential -name '1.1.12.12.in-addr.arpa' -View default
		{Remove-IBDNSPTRRecord -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Remove-IBDNSPTRRecord -ea Stop} | should Throw
	}
	It "Deletes the record using byObject method" {
		$TestRecord = Get-IBDNSPTRRecord -Gridmaster $gridmaster -Credential $credential -name '1.1.12.12.in-addr.arpa' -View default
		$Return = $TestRecord | Remove-IBDNSPTRRecord -confirm:$False 
		{[IB_DNSPTRRecord]::Get($gridmaster,$Credential,$TestRecord._Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $TestRecord._Ref
	}
	It "Deletes the record using byRef method" {
		$TestRecord = Get-IBDNSPTRRecord -Gridmaster $gridmaster -Credential $credential -name '2.1.12.12.in-addr.arpa' -View default
		$Return = Remove-IBDNSPTRRecord -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref
		{[IB_DNSPTRRecord]::Get($gridmaster,$Credential,$TestRecord._Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $TestRecord._Ref
	}
}
Describe "Remove-IBFixedAddress tests" {
	It "Throws an error with an empty gridmaster" {
		{Remove-IBFixedAddress -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Remove-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Remove-IBFixedAddress -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$TestRecord = Get-IBFixedAddress -Gridmaster $gridmaster -Credential $credential -IPAddress '12.12.1.1' -NetworkView default
		{Remove-IBFixedAddress -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Remove-IBFixedAddress -ea Stop} | should Throw
	}
	It "Deletes the record using byObject method" {
		$TestRecord = Get-IBFixedAddress -Gridmaster $gridmaster -Credential $credential -IPAddress '12.12.1.1' -NetworkView default
		$Return = $TestRecord | Remove-IBFixedAddress -confirm:$False 
		{[IB_FixedAddress]::Get($gridmaster,$Credential,$Testrecord._Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $TestRecord._Ref
	}
	It "Deletes the record using byRef method" {
		$TestRecord = Get-IBFixedAddress -Gridmaster $gridmaster -Credential $credential -IPAddress '12.12.1.2' -NetworkView default
		$Return = Remove-IBFixedAddress -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $TestRecord._Ref
		{[IB_FixedAddress]::Get($gridmaster,$Credential,$TestRecord._Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $TestRecord._Ref
	}
}
Describe "Remove-IBRecord tests" {
	It "Throws an error with an empty gridmaster" {
		{Remove-IBRecord -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "Throws an error with empty ref parameter" {
		{Remove-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Remove-IBRecord -ea Stop} | should Throw
	}
	It "Deletes an A record using byRef method" {
		$Ref = $script:recordlist.where{$_._ref -like "record:a/*:testrecord4.domain.com/view2"}._ref
		$Return = Remove-IBRecord -confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Ref
		{[IB_ReferenceObject]::Get($gridmaster,$Credential,$Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Ref
	}
	It "Deletes an PTR record using byRef method" {
		$Ref = $script:recordlist.where{$_._ref -like "record:ptr/*:1.1.12.12.in-addr.arpa/view2"}._ref
		$Return = Remove-IBRecord -confirm:$False -gridmaster $gridmaster -credential $credential -_Ref $Ref
		{[IB_ReferenceObject]::Get($gridmaster,$Credential,$Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Ref
	}
	It "Deletes CName Record using object through pipeline" {
		$Ref = $script:recordlist.where{$_._ref -like "record:cname/*:testalias4.domain.com/view2"}._ref
		$Record = Get-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref $ref
		$return = $Record | Remove-IBRecord -confirm:$False 
		{[IB_ReferenceObject]::Get($gridmaster,$Credential,$Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Ref
	}
}
Describe "Remove-IBNetwork tests" {
	It "deletes network using byRef method" {
		$Ref = $Script:recordlist.where{$_._ref -like "network/*:192.168.1.0/24/networkview2"}._ref
		$Return = Remove-IBNetwork -confirm:$False -gridmaster $Gridmaster -credential $Credential -_ref $Ref
		{[IB_ReferenceObject]::Get($gridmaster,$Credential,$Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Ref
	}
	It "deletes network using object through pipeline" {
		$Ref = $Script:recordlist.where{$_._ref -like "network/*:12.12.0.0*16/networkview3"}._ref
		$Record = get-IBNetwork -gridmaster $Gridmaster -credential $Credential -_ref $Ref
		$Return = $Record | Remove-IBNetwork -confirm:$False
		{[IB_ReferenceObject]::Get($gridmaster,$Credential,$Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Ref
	}
	It "deletes multiple networks through pipeline"{
		Get-IBNetwork -gridmaster $Gridmaster -credential $Credential -network 12.12.0.0/16 | remove-ibnetwork -confirm:$False
		Get-IBNetwork -gridmaster $Gridmaster -credential $Credential -network 12.12.0.0/16 | should benullorempty
	}
	It "deletes multiple parent networks through byRef method" {
		$networks = get-ibnetwork -gridmaster $Gridmaster -credential $Credential -network 12.0.0.0/8
		$Networks | %{
			$Result = Remove-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -_Ref $_._ref -confirm:$False
			$Result | should be $_._ref
			{get-ibnetwork -gridmaster $Gridmaster -credential $credential -_ref $_._ref} | should throw
		}
	}
}
Describe "Remove-IBDNSZone tests" {
	It "deletes zone using byRef method" {
		$Ref = $Script:recordlist.where{$_._ref -like "zone_auth/*:domain.com/default"}._ref
		$Return = Remove-IBDNSZone -confirm:$False -gridmaster $Gridmaster -credential $Credential -_ref $Ref
		{[IB_ReferenceObject]::Get($gridmaster,$Credential,$Ref)} | should Throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Ref
	}
	It "deletes zone using object through pipeline" {
		$Ref = $Script:recordlist.where{$_._ref -like "zone_auth/*:12.0.0.0*8/view2"}._ref
		$Record = get-IBDNSZone -gridmaster $Gridmaster -credential $Credential -_ref $Ref
		$Return = $Record | Remove-IBDNSZone -confirm:$False
		{[IB_ReferenceObject]::Get($gridmaster,$Credential,$Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Ref
	}
	It "deletes multiple zones through pipeline"{
		Get-IBDNSZone -gridmaster $Gridmaster -credential $Credential -fqdn domain.com | remove-ibdnszone -confirm:$False
		Get-IBDNSZone -gridmaster $Gridmaster -credential $Credential -fqdn domain.com | should benullorempty
	}
	It "deletes multiple zones through byRef method" {
		$zones = get-ibdnszone -gridmaster $Gridmaster -credential $Credential -view default
		$zones | %{
			$Result = Remove-IBdnszone -Gridmaster $Gridmaster -Credential $Credential -_Ref $_._ref -confirm:$False
			$Result | should be $_._ref
			{get-ibdnszone -gridmaster $Gridmaster -credential $credential -_ref $_._ref} | should Throw
		}
	}
}
Describe "Remove-IBView tests" {
	It "deletes view with refstring input" {
		$view2 = get-ibview -Gridmaster $gridmaster -Credential $credential -name view2 -Strict -Type DNSView
		$result = remove-ibview -gridmaster $gridmaster -credential $credential -_ref $view2._ref -confirm:$False
		{get-ibview -Gridmaster $gridmaster -Credential $credential -name view2 -Strict} | should throw
		$result | should be $view2._ref
	}
	It "deletes view with object through pipeline" {
		$view3 = get-ibview -Gridmaster $gridmaster -Credential $credential -name view3 -Strict -Type DNSView
		$result = $view3 | remove-ibview -confirm:$False
		get-ibview -Gridmaster $gridmaster -Credential $credential -name view3 -Strict | should benullorempty
		$result | should be $view3._ref
	}
	It "deletes multiple networkviews through pipeline" {
		$networkviews = get-ibview -gridmaster $gridmaster -credential $credential -type networkview -name networkview
		$result = $networkviews | remove-ibview -confirm:$False
		get-ibview -gridmaster $gridmaster -credential $credential -type networkview -name networkview | should benullorempty
		$Result[0] | should be $networkviews[0]._ref
		$result[1] | should be $networkviews[1]._ref
	}
}
Describe "Remove-IBExtensibleAttributeDefinition tests" {
	It "Throws an error with an empty gridmaster" {
		{Remove-IBExtensibleAttributeDefinition -Gridmaster '' -Credential $Credential -_Ref 'refstring'} | should throw
	}
	It "THrows an error with empty ref parameter" {
		{Remove-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -_Ref} | should throw
	}
	It "Throws an error with invalid record object" {
		{Remove-IBExtensibleAttributeDefinition -Record 'notadnsrecord'} | should throw
	}
	It "Throws an error with parameters from both sets" {
		$Ref = $script:Recordlist.where{$_._ref -like "extensibleattributedef/*:EA2"}._ref
		$TestRecord = [IB_ExtAttrsDef]::Get($gridmaster,$Credential,$Ref)
		{Remove-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Record $TestRecord} | should Throw
	}
	It "Throws an error with pipeline input object missing a ref property" {
		{new-object PSObject -Property @{gridmaster=$Gridmaster;credential=$Credential} | Remove-IBExtensibleAttributeDefinition -ea Stop} | should Throw
	}
	It "Deletes the record using byObject method" {
		$Ref = $script:Recordlist.where{$_._ref -like "extensibleattributedef/*:EA2"}._ref
		$Record = [IB_ExtAttrsDef]::Get($gridmaster,$Credential,$Ref)
		$Return = $Record | Remove-IBExtensibleAttributeDefinition -confirm:$False 
		{[IB_ExtAttrsDef]::Get($gridmaster,$Credential,$Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Ref
	}
	It "Deletes the record using byRef method" {
		$Ref = $script:Recordlist.where{$_._ref -like "extensibleattributedef/*:EA3"}._ref
		$Return = Remove-IBExtensibleAttributeDefinition -confirm:$False  -gridmaster $gridmaster -credential $credential -_Ref $Ref
		{[IB_ExtAttrsDef]::Get($gridmaster,$Credential,$Ref)} | should throw
		$Return.GetType().Name | Should be 'String'
		$Return | should be $Ref
	}

}
