<#
.Synopsis
	Get-FixedAddress retreives objects of type FixedAddress from the Infoblox database.
.DESCRIPTION
	Get-FixedAddress retreives objects of type FixedAddress from the Infoblox database.  Parameters allow searching by ip address, mac address, network view or comment.  Also allows retrieving a specific record by reference string.  Returned object is of class type FixedAddress.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER IPAddress
	The IP Address to search for.  Standard IPv4 notation applies, and a string value must be castable to an IPAddress object.
.PARAMETER MAC
	The MAC address to search for.  Colon separated format of 00:00:00:00:00:00 is required.
.PARAMETER MaxResults
	The maximum number of results to return from the query.  A positive value will truncate the results at the specified number.  A negative value will throw an error if the query returns more than the specified number.
.PARAMETER NetworkView
	The Infoblox network view to search for records in.  The provided value must match a valid network view on the Infoblox.
.PARAMETER Comment
	A string to search for in the comment field of the Fixed Address record.  Will return any record with the matching string anywhere in the comment field.  Use with -Strict to match only the exact string in the comment.
.PARAMETER Strict
	A switch to specify whether the search of the comment field should be exact, or allow partial word searches or regular expression matching.
.PARAMETER _Ref
	The unique reference string representing the fixed address record.  String is in format <recordtype>/<uniqueString>:<IPAddress>/<networkview>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.EXAMPLE
	Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -IPAddress '192.168.101.1'

	This example retrieves all fixed address records with IP Address of 192.168.101.1
.EXAMPLE
	Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict

	This example retrieves all fixed address records with the exact comment 'test comment'
.EXAMPLE
	Get-FixedAddress -Gridmaster $Gridmaster -Credential $Credential -MAC '00:00:00:00:00:00' -comment 'Delete'

	This example retrieves all fixed address records with a mac address of all zeroes and the word 'Delete' anywhere in the comment text.
.EXAMPLE
	Get-FixedAddress -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'}

	This example retrieves all dns records with an extensible attribute defined for 'Site' with value of 'OldSite'
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_FixedAddress
#>
Function Get-FixedAddress {
	[CmdletBinding(DefaultParameterSetName = 'byQuery')]
	Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({If($_){Test-connection -ComputerName $_ -Count 1 -Quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True)]
        [System.Management.Automation.Credential()]
		$Credential,

		[Parameter(ParameterSetName='byQuery')]
		[IPAddress]$IPAddress,

		[Parameter(ParameterSetName='byQuery')]
		[ValidatePattern('^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$')]
		[String]$MAC,

		[Parameter(ParameterSetName='byQuery')]
		[String]$NetworkView,

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
            $IBViews = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView
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
			Write-Verbose "$FunctionName`:  Performing query search for FixedAddress Records"
			[IB_FixedAddress]::Get($Gridmaster,$Credential,$IPAddress,$MAC,$Comment,$ExtAttributeQuery,$NetworkView,$Strict,$MaxResults)
		} else {
			Write-Verbose "$FunctionName`: Querying $gridmaster for A record with reference string $_ref"
			[IB_FixedAddress]::Get($Gridmaster, $Credential, $_ref)
		}
	}
	END{}
}