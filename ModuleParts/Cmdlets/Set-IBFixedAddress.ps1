<#
.Synopsis
	Set-IBFixedAddress modifies properties of an existing fixed address in the Infoblox database.
.DESCRIPTION
	Set-IBFixedAddress modifies properties of an existing fixed address in the Infoblox database.  Valid IB_FixedAddress objects can be passed through the pipeline for modification.  A valid reference string can also be specified.  On a successful edit no value is returned unless the -Passthru switch is used.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the DNS record.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.PARAMETER Record
	An object of type IB_FixedAddress representing the DNS record.  This parameter is typically for passing an object in from the pipeline, likely from Get-IBFixedAddress.
.PARAMETER Name
	The hostname to set on the provided dns record.	
.PARAMETER Comment
	The comment to set on the provided dns record.  Can be used for notation and keyword searching by Get- cmdlets.
.PARAMETER MAC
	The MAC address to set on the record.  Colon separated format of 00:00:00:00:00:00 is required.
.PARAMETER Passthru
	Switch parameter to return an IB_FixedAddress object with the new values after updating the Infoblox.  The default behavior is to return nothing on successful record edit.
.EXAMPLE
	Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBFixedAddress -comment 'new comment'
	
	This example retrieves all fixed addresses with a comment of 'old comment' and replaces it with 'new comment'
.EXAMPLE
	Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -Name testrecord.domain.com | Set-IBFixedAddress -Name testrecord2.domain.com -comment 'new comment' -passthru

		Name      : testrecord2.domain.com
		IPAddress : 192.168.1.1
		Comment   : new comment
		MAC       : 00:00:00:00:00:00
		View      : default
		_ref      : fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:192.168.1.1/default

	description
	-----------
	This example modifes the PTRDName and comment on the provided record and outputs the updated record definition
.EXAMPLE
	Set-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -_ref fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:192.168.1.2/default -MAC '11:11:11:11:11:11' -Passthru

		Name      : testrecord2.domain.com
		IPAddress : 192.168.1.2
		Comment   : new record
		MAC       : 11:11:11:11:11:11
		View      : default
		_ref      : fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:192.168.1.2/default

	description
	-----------
	This example finds the record based on the provided ref string and set the MAC address on the record
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_FixedAddress
#>
Function Set-IBFixedAddress{
    [CmdletBinding(DefaultParameterSetName='byObject',SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [String]$Gridmaster,

        [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
        [ValidateNotNullorEmpty()]
        [String]$_Ref,

        [Parameter(Mandatory=$True,ParameterSetName='byObject',ValueFromPipeline=$True)]
        [IB_FixedAddress[]]$Record,

        [String]$Name = "unspecified",

        [String]$Comment = "unspecified",
		
		[ValidatePattern('^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$')]
		[String]$MAC = '99:99:99:99:99:99',

		[Switch]$Passthru
    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
    }
    PROCESS{
            If ($pscmdlet.ParameterSetName -eq 'byRef'){
			
            $Record = [IB_FixedAddress]::Get($_Ref)
            If ($Record){
                $Record | Set-IBFixedAddress -Name $Name -Comment $Comment -mac $MAC -Passthru:$Passthru
            }
			
        }else {
			Foreach ($Item in $Record){
				If ($pscmdlet.ShouldProcess($Item)) {
					If ($Name -ne 'unspecified'){
						write-verbose "$FunctionName`:  Setting Name to $Name"
						$Item.Set($Name, $Item.Comment, $Item.MAC)
					}
					If ($Comment -ne 'unspecified'){
						write-verbose "$FunctionName`:  Setting comment to $comment"
						$Item.Set($Item.Name, $Comment, $Item.MAC)
					}
					If ($MAC -ne '99:99:99:99:99:99'){
						write-verbose "$FunctionName`:  Setting MAC to $MAC"
						$Item.Set($Item.Name, $Item.Comment, $MAC)
					}
					If ($Passthru) {
						Write-Verbose "$FunctionName`:  Passthru specified, returning object as output"
						return $Item
					}
				}
			}
		}
	}
    END{}
}
