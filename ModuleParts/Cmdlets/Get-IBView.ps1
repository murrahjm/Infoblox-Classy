<#
.Synopsis
	Get-IBView retreives objects of type View or network_view from the Infoblox database.
.DESCRIPTION
	Get-IBView retreives objects of type view or network_view from the Infoblox database.  Parameters allow searching by Name, Comment or status as default.  Search can target either DNS View or Network view, not both.  Also allows retrieving a specific record by reference string.  Returned object is of class type IB_View or IB_NetworkView.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Type
	Determines which class of object to search for.  DNSView searches for IB_View objects, where NetworkView searches for IB_Networkview objects.
.PARAMETER Name
	The view name to search for.  Can be full or partial name match depending on use of the -Strict switch
.PARAMETER MaxResults
	The maximum number of results to return from the query.  A positive value will truncate the results at the specified number.  A negative value will throw an error if the query returns more than the specified number.
.PARAMETER isDefault
	Search for views based on whether they are default or not.  If parameter is not specified both types will be returned.
.PARAMETER Comment
	A string to search for in the comment field of the view.  Will return any view with the matching string anywhere in the comment field.  Use with -Strict to match only the exact string in the comment.
.PARAMETER Strict
	A switch to specify whether the search of the name or comment field should be exact, or allow partial word searches or regular expression matching.
.PARAMETER _Ref
	The unique reference string representing the view.  String is in format <recordtype>/<uniqueString>:<Name>/<isDefault>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.EXAMPLE
	Get-IBView -Gridmaster $Gridmaster -Credential $Credential Type DNSView -IsDefault $True

	This example retrieves the dns view specified as default.
.EXAMPLE
	Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView -comment 'default'

	This example retrieves any network views with the word 'default' in the comment
.EXAMPLE
	Get-IBView -Gridmaster $Gridmaster -Credential $Credential -_Ref 'networkview/ZGdzLm5ldHdvamtfdmlldyQw:Default/true'

	This example retrieves the single view with the assigned reference string
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_View
	IB_NetworkView
#>
Function Get-IBView {
    [CmdletBinding(DefaultParameterSetName='byQuery')]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True)]
        [System.Management.Automation.Credential()]
		$Credential,

        [Parameter(ParameterSetName='byQuery')]
        [String]$Name,

		[Parameter(ParameterSetName='byQuery')]
		[String]$Comment,

		[Parameter(ParameterSetname='byQuery')]
		[String]$ExtAttributeQuery,
        
		[Parameter(ParameterSetName='byQuery')]
		[Switch]$Strict,

		[Parameter(ParameterSetName='byQuery')]
		[ValidateSet('True','False')]
		[String]$IsDefault,

		[Parameter(ParameterSetName='byQuery')]
		[int]$MaxResults,

		[Parameter(Mandatory=$True,ParameterSetName='byQuery')]
		[ValidateSet('DNSView','NetworkView')]
		[String]$Type,

		[Parameter(Mandatory=$True,ParameterSetName='byRef')]
		[String]$_Ref
    )
    $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
    write-verbose "$FunctionName`:  Beginning Function"
		Try {
			If ($pscmdlet.ParameterSetName -eq 'byRef'){
				Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_ref $_Ref
			} else {
				If ($Type -eq 'DNSView'){
					Write-Verbose "$Functionname`:  calling IB_View Get method with the following parameters`:"
					Write-Verbose "$FunctionName`:  $gridmaster,$credential,$name,$isDefault,$Comment,$Strict,$MaxResults"
					[IB_View]::Get($Gridmaster,$Credential,$Name,$IsDefault,$Comment,$ExtAttributeQuery,$Strict,$MaxResults)
				} else {
					Write-Verbose "$Functionname`:  calling IB_NetworkView Get method with the following parameters`:"
					Write-Verbose "$FunctionName`:  $gridmaster,$credential,$name,$isDefault,$Comment,$Strict,$MaxResults"
					[IB_NetworkView]::Get($Gridmaster,$Credential,$Name,$IsDefault,$Comment,$ExtAttributeQuery,$Strict,$MaxResults)
				}

			}
		} Catch {
			Write-error "Unable to connect to Infoblox device $gridmaster.  Error code:  $($_.exception)" -ea Stop
		}
}
