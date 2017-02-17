<#
.Synopsis
	Set-IBView modifies properties of an existing View or NetworkView object in the Infoblox database.
.DESCRIPTION
	Set-IBView modifies properties of an existing View or NetworkView object in the Infoblox database.  Valid IB_View or IB_NetworkView objects can be passed through the pipeline for modification.  A valid reference string can also be specified.  On a successful edit no value is returned unless the -Passthru switch is used.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the View or NetworkView object.  String is in format <recordtype>/<uniqueString>:<Name>/<defaultbool>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.PARAMETER Record
	An object of type IB_View or IB_NetworkView representing the View or NetworkView object.  This parameter is typically for passing an object in from the pipeline, likely from Get-IBView.
.PARAMETER Name
	The name to set on the provided View or NetworkView object.
.PARAMETER Comment
	The comment to set on the provided View or NetworkView object.  Can be used for notation and keyword searching by Get- cmdlets.
.PARAMETER Passthru
	Switch parameter to return an IB_View or IB_NetworkView object with the new values after updating the Infoblox.  The default behavior is to return nothing on successful record edit.
.EXAMPLE
	Get-IBView -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBView -comment 'new comment'
	
	This example retrieves all View or NetworkView objects with a comment of 'old comment' and replaces it with 'new comment'
.EXAMPLE
	Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Name view2 | Set-IBView -name view3 -comment 'new comment' -passthru

		Name      : view3
		Comment   : new comment
		is_default: false
		_ref      : view/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:view3/false

	description
	-----------
	This example modifes the name and comment on the provided record and outputs the updated record definition
.EXAMPLE
	Set-IBView -Gridmaster $Gridmaster -Credential $Credential -_ref networkview/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:networkview2/false -Passthru -comment $False

		Name      : networkview2
		Comment   : 
		is_default: False
		_ref      : networkview/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:networkview2/false

	description
	-----------
	This example finds the record based on the provided ref string and clears the comment
.INPUTS
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_View
    IB_NetworkView
#>
Function Set-IBView{
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
        [ValidateScript({$_.GetType().Name -eq 'IB_View' -or $_.GetType().name -eq 'IB_NetworkView'})]
        [object[]]$Record,
        
        [String]$Name = 'unspecified',

        [String]$Comment = 'unspecified',

		[Switch]$Passthru

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
   }
    PROCESS{
        If ($pscmdlet.ParameterSetName -eq 'byRef'){
            If ($_Ref -like "view/*"){
                $Record = [IB_View]::Get($Script:IBGridmaster,$Script:IBSession,$Global:WapiVersion,$_Ref)
            } elseif ($_Ref -like "networkview/*") {
                $Record = [IB_NetworkView]::Get($Script:IBGridmaster,$Script:IBSession,$Global:WapiVersion,$_Ref)
            }
                If ($Record){
                    $Record | Set-IBView -name $Name -Comment $Comment -Passthru:$Passthru
                }
        } else {
            foreach ($item in $Record){
                If ($pscmdlet.shouldProcess($item)){
                    If ($comment -ne 'unspecified'){
                        write-verbose "$FunctionName`:  Setting comment to $comment"
                        $item.Set($Script:IBGridmaster,$Script:IBSession,$Global:WapiVersion,$item.Name, $Comment)
                    }
                    If ($Name -ne 'unspecified'){
                        write-verbose "$FunctionName`:  Setting name to $Name"
                        $item.Set($Script:IBGridmaster,$Script:IBSession,$Global:WapiVersion,$Name, $item.comment)
                    }
                    If ($Passthru) {
                        Write-Verbose "$FunctionName`:  Passthru specified, returning object as output"
                        return $item
                    }
                }
            }
        }
	}
    END{}
}
