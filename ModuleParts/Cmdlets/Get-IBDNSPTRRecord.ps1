<#
.Synopsis
	Get-IBDNSPTRRecord retreives objects of type DNSPTRRecord from the Infoblox database.
.DESCRIPTION
	Get-IBDNSPTRRecord retreives objects of type DNSPTRRecord from the Infoblox database.  Parameters allow searching by Name, IPAddress, View, Zone or Comment  Also allows retrieving a specific record by reference string.  Returned object is of class type DNSPTRRecord.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Name
	The record name to search for.  This is usually something like '1.1.168.192.in-addr.arpa'.  To search for a hostname that the PTR record resolves to, use the PTRDName parameter.  Can be fqdn or partial name match depending on use of the -Strict switch
.PARAMETER PTRDName
	The hostname to search for.  Note this is not the name of the PTR record, but rather the name that the ptr record points to.  Can be fqdn or partial name match depending on use of the -Strict switch
.PARAMETER IPAddress
	The IP Address to search for.  Standard IPv4 notation applies, and a string value must be castable to an IPAddress object.
.PARAMETER Zone
	The DNS zone to search for records in.  Note that specifying a zone will also restrict the searching to a specific view.  The default view will be used if none is specified.
.PARAMETER MaxResults
	The maximum number of results to return from the query.  A positive value will truncate the results at the specified number.  A negative value will throw an error if the query returns more than the specified number.
.PARAMETER View
	The Infoblox view to search for records in.  The provided value must match a valid view on the Infoblox.  Note that if the zone parameter is used for searching results are narrowed to a particular view.  Otherwise, searches are performed across all views.
.PARAMETER Comment
	A string to search for in the comment field of the DNS record.  Will return any record with the matching string anywhere in the comment field.  Use with -Strict to match only the exact string in the comment.
.PARAMETER Strict
	A switch to specify whether the search of the Name, PTRDname or comment fields should be exact, or allow partial word searches or regular expression matching.
.PARAMETER _Ref
	The unique reference string representing the DNS record.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.EXAMPLE
	Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress '192.168.101.1'

	This example retrieves all DNS PTR records with IP Address of 192.168.101.1
.EXAMPLE
	Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict

	This example retrieves all DNS PTR records with the exact comment 'test comment'
.EXAMPLE
	Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref 'record:ptr/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:1.1.168.192.in-addr.arpa/default'

	This example retrieves the single DNS PTR record with the assigned reference string
.EXAMPLE
	Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -PTRDName Testrecord.domain.com | Remove-IBDNSPTRRecord

	This example retrieves the DNS PTR record with PTRDName testrecord.domain.com, and deletes it from the infoblox database.
.EXAMPLE
	Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBDNSPTRRecord -comment 'new comment'
	
	This example retrieves all DNS PTR records with a comment of 'old comment' and replaces it with 'new comment'
.EXAMPLE
	Get-IBDNSPTRRecord -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'}

	This example retrieves all dns records with an extensible attribute defined for 'Site' with value of 'OldSite'
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_DNSPTRRecord
#>
Function Get-IBDNSPTRRecord {
	[CmdletBinding(DefaultParameterSetName = 'byQuery')]
	Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

		[Parameter(ParameterSetName='byQuery')]
		[String]$Name,

		[Parameter(ParameterSetName='byQuery')]
		[IPAddress]$IPAddress,

		[Parameter(ParameterSetName='byQuery')]
		[String]$PTRDName,

		[Parameter(ParameterSetName='byQuery')]
		[String]$View,

		[Parameter(ParameterSetName='byQuery')]
		[String]$Zone,

		[Parameter(ParameterSetName='byQuery')]
		[String]$Comment,
        
		[Parameter(ParameterSetname='byQuery')]
		[String]$ExtAttributeQuery,
        
		[Parameter(ParameterSetName='byQuery')]
        [Switch]$Strict,

		[Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='byref')]
		[String]$_ref,

        [Int]$MaxResults
	)
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $gridmaster to retrieve Views"
        Try {
            $IBViews = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView
        } Catch {
            Write-error "Unable to connect to Infoblox device $gridmaster.  Error code:  $($_.exception)" -ea Stop
        }
        If ($View){
            Write-Verbose "$FunctionName`:  Validating View parameter against list from Infoblox device"
            If ($IBViews.name -cnotcontains $View){
                $ViewList = $ibviews.name -join ', '
                write-error "Invalid data for View parameter.  Options are $ViewList" -ea Stop
            }
        }
    }
	PROCESS{
		If ($pscmdlet.ParameterSetName -eq 'byQuery') {
			Write-Verbose "$FunctionName`:  Performing query search for PTR Records"
			[IB_DNSPTRRecord]::Get($Gridmaster,$Credential,$Name,$IPAddress,$PTRDName,$Comment,$ExtAttributeQuery,$Zone,$View,$Strict,$MaxResults)
		} else {
			Write-Verbose "$FunctionName`: Querying $gridmaster for PTR record with reference string $_ref"
			[IB_DNSPTRRecord]::Get($Gridmaster, $Credential, $_ref)
		}
	}
	END{}
}