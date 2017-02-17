<#
.Synopsis
	Get-IBNetwork retreives objects of type Network from the Infoblox database.
.DESCRIPTION
	Get-IBNetwork retreives objects of type Network from the Infoblox database.  Parameters allow searching by network, network view or comment.  Also allows retrieving a specific record by reference string.  Returned object is of class type IB_Network.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Network
	The IP Network to search for.  Standard IPv4 or CIDR notation applies.  Partial matches are supported.
.Parameter NetworkContainer
	The parent network to search by.  Will return any networks that are subnets of this value.  i.e. query for 192.168.0.0/16 will return 192.168.1.0/24, 192.168.2.0/24, etc.
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
	Get-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -network 192.168.101.0/24

	This example retrieves the network object for subnet 192.168.101.0
.EXAMPLE
	Get-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict

	This example retrieves all network objects with the exact comment 'test comment'
.EXAMPLE
	Get-IBNetwork -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'}

	This example retrieves all network objects with an extensible attribute defined for 'Site' with value of 'OldSite'
.INPUTS
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_Network
#>
Function Get-IBNetwork {
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
        [ValidateScript({If ($_ -match '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$') {
            $True
        } else {
            Throw "$_ is not a CIDR address"
        }})]
        [String]$Network,
		
        [Parameter(ParameterSetName='byQuery')]
        [ValidateScript({If ($_ -match '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$') {
            $True
        } else {
            Throw "$_ is not a CIDR address"
        }})]
        [String]$NetworkContainer,

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
		If (! $script:IBSession){
			write-verbose "Existing session to infoblox gridmaster does not exist."
			If ($gridmaster -and $Credential){
				write-verbose "Creating session to $gridmaster with user $($credential.username)"
				New-IBWebSession -gridmaster $Gridmaster -Credential $Credential -erroraction Stop
			} else {
				write-error "Missing required parameters to connect to Gridmaster" -ea Stop
			}
		} else {
			write-verbose "Existing session to $script:IBGridmaster found"
		}
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $script:IBgridmaster to retrieve Views"
        Try {
            $IBViews = Get-IBView -Type NetworkView
        } Catch {
            Write-error "Unable to connect to Infoblox device $script:IBgridmaster.  Error code:  $($_.exception)" -ea Stop
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
			Write-Verbose "$FunctionName`:  Performing query search for Network Records"
			[IB_Network]::Get($Script:IBGridmaster,$Script:IBSession,$Global:WapiVersion,$Network,$NetworkView,$NetworkContainer,$Comment,$ExtAttributeQuery,$Strict,$MaxResults)
		} else {
			Write-Verbose "$FunctionName`: Querying $script:IBgridmaster for network record with reference string $_ref"
			[IB_Network]::Get($Script:IBGridmaster,$Script:IBSession,$Global:WapiVersion,$_ref)
		}
	}
	END{}
}