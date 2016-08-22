<#
.Synopsis
	Get-IBRecord retreives objects from the Infoblox database.
.DESCRIPTION
	Get-IBRecord retreives objects from the Infoblox database.  Queries the Infoblox database for records matching the provided reference string.  Returns defined objects for class-defined record types, and IB_ReferenceObjects for undefined types.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the record.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.EXAMPLE
	Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default'

		Name	  : testrecord.domain.com
		IPAddress : 192.168.1.1
		Comment   : 'test record'
		View      : default
		TTL       : 1200
		Use_TTL   : True
		_ref      : record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default

	Description
	-----------
	This example retrieves the single DNS record with the assigned reference string
.EXAMPLE
	Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref 'network/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:192.168.1.0/default'

		_ref      : network/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:192.168.1.0/default

	Description
	-----------
	This example returns an IB_ReferenceObject object for the undefined object type.  The object exists on the infoblox and is valid, but no class is defined for it in the cmdlet class definition.
.EXAMPLE
	Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -name Testrecord.domain.com | Remove-IBDNSARecord

	This example retrieves the dns record with name testrecord.domain.com, and deletes it from the infoblox database.
.EXAMPLE
	Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBDNSARecord -comment 'new comment'
	
	This example retrieves all dns records with a comment of 'old comment' and replaces it with 'new comment'
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_DNSARecord
#>
Function Get-IBRecord{
    [CmdletBinding(DefaultParameterSetName='byObject')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateScript({If ($_){Test-connection -ComputerName $_ -Count 1 -Quiet}})]
		[String]$Gridmaster,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.Credential()]$Credential,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateNotNullorEmpty()]
        [String]$_Ref
    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
    }
    PROCESS{
		$return = Switch ($_ref.ToString().split('/')[0]) {
			'record:a' {[IB_DNSARecord]::Get($Gridmaster, $Credential, $_ref)}
			'record:ptr' {[IB_DNSPTRRecord]::Get($gridmaster, $Credential, $_ref)}
			'record:cname' {[IB_DNSCNameRecord]::Get($Gridmaster, $Credential, $_ref)}
			'fixedaddress' {[IB_FixedAddress]::Get($gridmaster, $Credential, $_ref)}
			'view' {[IB_View]::Get($gridmaster, $Credential, $_ref)}
			'networkview' {[IB_NetworkView]::Get($Gridmaster, $Credential, $_ref)}
			'extensibleattributedef' {]IB_ExtAttrsDef]::Get($Gridmaster, $credential, $_ref)}
			default {[IB_ReferenceObject]::Get($gridmaster, $Credential, $_ref)}
		}
		If ($Return){
			return $Return
		} else {
			return $Null
		}
	}
    END{}
}
