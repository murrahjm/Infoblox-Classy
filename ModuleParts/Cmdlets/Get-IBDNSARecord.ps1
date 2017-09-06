<#
.Synopsis
	Get-IBDNSARecord retreives objects of type DNSARecord from the Infoblox database.
.DESCRIPTION
	Get-IBDNSARecord retreives objects of type DNSARecord from the Infoblox database.  Parameters allow searching by Name, IPAddress, View, Zone or Comment  Also allows retrieving a specific record by reference string.  Returned object is of class type DNSARecord.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Name
	The dns name to search for.  Can be fqdn or partial name match depending on use of the -Strict switch
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
	A switch to specify whether the search of the name or comment field should be exact, or allow partial word searches or regular expression matching.
.PARAMETER _Ref
	The unique reference string representing the DNS record.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.EXAMPLE
	Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress '192.168.101.1'

	This example retrieves all DNS records with IP Address of 192.168.101.1
.EXAMPLE
	Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict

	This example retrieves all DNS records with the exact comment 'test comment'
.EXAMPLE
	Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default'

	This example retrieves the single DNS record with the assigned reference string
.EXAMPLE
	Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -name Testrecord.domain.com | Remove-IBDNSARecord

	This example retrieves the dns record with name testrecord.domain.com, and deletes it from the infoblox database.
.EXAMPLE
	Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBDNSARecord -comment 'new comment'
	
	This example retrieves all dns records with a comment of 'old comment' and replaces it with 'new comment'
.EXAMPLE
	Get-IBDNSARecord -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'}

	This example retrieves all dns records with an extensible attribute defined for 'Site' with value of 'OldSite'
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_DNSARecord
#>
Function Get-IBDNSARecord {
	[CmdletBinding(DefaultParameterSetName = 'byQuery')]
	Param(
        [Parameter(Mandatory=$False)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [String]$Gridmaster,

        [Parameter(Mandatory=$False)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

		[Parameter(ParameterSetName='byQuery')]
		[String]$Name,

		[Parameter(ParameterSetName='byQuery')]
		[IPAddress]$IPAddress,

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
		If (! $script:IBSession){
			write-verbose "Existing session to infoblox gridmaster does not exist."
			If ($gridmaster -and $Credential){
				write-verbose "Creating session to $gridmaster with user $($credential.username)"
				New-IBWebSession -gridmaster $Gridmaster -Credential $Credential -erroraction Stop
			} else {
				write-error "Missing required parameters to connect to Gridmaster" -ea Stop
			}
		} else {
			write-verbose "Existing session to $script:IBgridmaster found"
		}
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $script:IBgridmaster to retrieve Views"
        Try {
            $IBViews = Get-IBView -Type DNSView
        } Catch {
            Write-error "Unable to connect to Infoblox device $script:IBgridmaster.  Error code:  $($_.exception)" -ea Stop
			return
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
			Write-Verbose "$FunctionName`:  Performing query search for A Records"
			[IB_DNSARecord]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$Name,$IPAddress,$Comment,$ExtAttributeQuery,$Zone,$View,$Strict,$MaxResults)
		} else {
			Write-Verbose "$FunctionName`: Querying $script:IBgridmaster for A record with reference string $_ref"
			[IB_DNSARecord]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_ref)
		}
	}
	END{}
}