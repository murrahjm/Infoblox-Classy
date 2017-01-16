<#
.Synopsis
	Get-IBDNSCNameRecord retreives objects of type DNSCNameRecord from the Infoblox database.
.DESCRIPTION
	Get-IBDNSCNameRecord retreives objects of type DNSCNameRecord from the Infoblox database.  Parameters allow searching by Name, Canonical, View, Zone or Comment  Also allows retrieving a specific record by reference string.  Returned object is of class type DNSCNameRecord.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Name
	The dns name to search for.  Can be fqdn or partial name match depending on use of the -Strict switch
.PARAMETER Canonical
	The canonical name to search for.  This is the record that the Alias(name) resolves to.  Can be fqdn or partial name match depending on use of the -Strict switch
.PARAMETER Zone
	The DNS zone to search for records in.  Note that specifying a zone will also restrict the searching to a specific view.  The default view will be used if none is specified.
.PARAMETER MaxResults
	The maximum number of results to return from the query.  A positive value will truncate the results at the specified number.  A negative value will throw an error if the query returns more than the specified number.
.PARAMETER View
	The Infoblox view to search for records in.  The provided value must match a valid view on the Infoblox.  Note that if the zone parameter is used for searching results are narrowed to a particular view.  Otherwise, searches are performed across all views.
.PARAMETER Comment
	A string to search for in the comment field of the DNS record.  Will return any record with the matching string anywhere in the comment field.  Use with -Strict to match only the exact string in the comment.
.PARAMETER Strict
	A switch to specify whether the search of the name, canonical or comment field should be exact, or allow partial word searches or regular expression matching.
.PARAMETER _Ref
	The unique reference string representing the DNS record.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.EXAMPLE
	Get-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Canonical 'testrecord.domain.com'

	This example retrieves all DNS records with Canonical of testrecord.domain.com
.EXAMPLE
	Get-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict

	This example retrieves all DNS records with the exact comment 'test comment'
.EXAMPLE
	Get-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref 'record:cname/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testalias.domain.com/default'

	This example retrieves the single DNS record with the assigned reference string
.EXAMPLE
	Get-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -name testalias.domain.com | Remove-IBDNSCNameRecord

	This example retrieves the dns record with name testalias.domain.com, and deletes it from the infoblox database.
.EXAMPLE
	Get-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBDNSCNameRecord -comment 'new comment'
	
	This example retrieves all dns records with a comment of 'old comment' and replaces it with 'new comment'
.EXAMPLE
	Get-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Canonical 'oldserver.domain.com' -Strict | Set-IBDNSCNameRecord -canonical 'newserver.fqdn.com'

	This example retrieves all dns cname records pointing to an old server, and replaces the value with the fqdn of a new server.
.EXAMPLE
	Get-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Canonical 'oldserver.domain.com' -Strict | Remove-IBDNSCNameRecord

	This example retrieves all dns cname records pointing to an old server, and deletes them.
.EXAMPLE
	Get-IBDNSCNameRecord -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'}

	This example retrieves all dns records with an extensible attribute defined for 'Site' with value of 'OldSite'
.INPUTS
	System.Net.Canonical[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_DNSCNameRecord
#>
Function Get-IBDNSCNameRecord {
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
		[String]$Canonical,

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
			Write-Verbose "$FunctionName`:  Performing query search for CName Records"
			[IB_DNSCNameRecord]::Get($Gridmaster,$Credential,$Name,$Canonical,$Comment,$ExtAttributeQuery,$Zone,$View,$Strict,$MaxResults)
		} else {
			Write-Verbose "$FunctionName`: Querying $gridmaster for CName record with reference string $_ref"
			[IB_DNSCNameRecord]::Get($Gridmaster, $Credential, $_ref)
		}
	}
	END{}
}