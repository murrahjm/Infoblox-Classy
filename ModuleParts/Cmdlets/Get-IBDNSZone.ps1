<#
.Synopsis
	Get-IBDNSZone retreives objects of type DNSZone from the Infoblox database.
.DESCRIPTION
	Get-IBDNSZone retreives objects of type DNSZone from the Infoblox database.  Parameters allow searching by DNSZone, DNSZone view or comment.  Also allows retrieving a specific record by reference string.  Returned object is of class type IB_DNSZone.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER FQDN
	The fully qualified name of the DNSZone to search for.  Partial matches are supported.
.Parameter ZoneFormat
	The parent dns zone format to search by.  Will return any DNSZones of this type.  Valid values are:
        •FORWARD
        •IPV4
        •IPV6
.PARAMETER MaxResults
	The maximum number of results to return from the query.  A positive value will truncate the results at the specified number.  A negative value will throw an error if the query returns more than the specified number.
.PARAMETER View
	The Infoblox DNS view to search for zones in.  The provided value must match a valid DNS view on the Infoblox.
.PARAMETER Comment
	A string to search for in the comment field of the dns zone record.  Will return any record with the matching string anywhere in the comment field.  Use with -Strict to match only the exact string in the comment.
.PARAMETER Strict
	A switch to specify whether the search of the comment field should be exact, or allow partial word searches or regular expression matching.
.PARAMETER _Ref
	The unique reference string representing the dns zone record.  String is in format <recordtype>/<uniqueString>:<IPAddress>/<DNSZoneview>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.EXAMPLE
	Get-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -DNSZone 192.168.101.0/24

	This example retrieves the DNSZone object for subnet 192.168.101.0
.EXAMPLE
	Get-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict

	This example retrieves all DNSZone objects with the exact comment 'test comment'
.EXAMPLE
	Get-IBDNSZone -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'}

	This example retrieves all DNSZone objects with an extensible attribute defined for 'Site' with value of 'OldSite'
.INPUTS
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_DNSZone
#>
Function Get-IBDNSZone {
	[CmdletBinding(DefaultParameterSetName = 'byQuery')]
	Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True)]
        [System.Management.Automation.Credential()]
		$Credential,

        [Parameter(ParameterSetName='byQuery')]
        [String]$FQDN,
		
        [Parameter(ParameterSetName='byQuery')]
        [ValidateSet('Forward','ipv4','ipv6')]
        [String]$ZoneFormat,

		[Parameter(ParameterSetName='byQuery')]
		[String]$View,

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
			Write-Verbose "$FunctionName`:  Performing query search for DNSZone Records"
			[IB_ZoneAuth]::Get($Gridmaster,$Credential,$FQDN,$View,$ZoneFormat,$Comment,$ExtAttributeQuery,$Strict,$MaxResults)
		} else {
			Write-Verbose "$FunctionName`: Querying $gridmaster for DNSZone record with reference string $_ref"
			[IB_ZoneAuth]::Get($Gridmaster, $Credential, $_ref)
		}
	}
	END{}
}