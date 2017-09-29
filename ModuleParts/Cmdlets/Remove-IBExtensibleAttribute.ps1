Function Remove-IBExtensibleAttribute {
    [CmdletBinding(DefaultParameterSetName='byObjectEAName',SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$False,ParameterSetName='byRefEAName')]
        [Parameter(Mandatory=$False,ParameterSetName='byRefAll')]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
		[String]$Gridmaster,

        [Parameter(Mandatory=$False,ParameterSetName='byRefEAName')]
        [Parameter(Mandatory=$False,ParameterSetName='byRefAll')]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True,ParameterSetName='byRefEAName')]
        [Parameter(Mandatory=$True,ParameterSetName='byRefAll')]
        [ValidateNotNullorEmpty()]
        [String]$_Ref,
        
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='byObjectEAName')]
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='byObjectAll')]
        [object[]]$Record,

		[Parameter(Mandatory=$True, ParameterSetName='byRefEAName')]
		[Parameter(Mandatory=$True, ParameterSetName='byObjectEAName')]
		[String]$EAName,

		[Parameter(Mandatory=$True, ParameterSetName='byRefAll')]
		[Parameter(Mandatory=$True, ParameterSetName='byObjectAll')]
		[Switch]$RemoveAll,

		[Switch]$Passthru
	)
	BEGIN{        
		$FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
		write-verbose "$FunctionName`:  Beginning Function"
		write-verbose "$FunctionName`:  ParameterSetName=$($pscmdlet.ParameterSetName)"
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
        If ($pscmdlet.ParameterSetName -eq "byRefEAName"){
			Write-Verbose "$FunctionName`:  Refstring passed, querying infoblox for record"
			$Record = Get-IBRecord -_Ref $_Ref
            If ($Record){
				Write-Verbose "$FunctionName`: object found, passing to cmdlet through pipeline"
                $Record | Remove-IBExtensibleAttribute -EAName $EAName -passthru:$Passthru
            }	
        } elseif($pscmdlet.ParameterSetName -eq "byRefAll"){
			Write-Verbose "$FunctionName`:  Refstring passed, querying infoblox for record"
			$Record = Get-IBRecord -_Ref $_Ref
            If ($Record){
				Write-Verbose "$FunctionName`: object found, passing to cmdlet through pipeline"
                $Record | Remove-IBExtensibleAttribute -RemoveAll:$RemoveAll -passthru:$Passthru
            }	
		} else {
			Foreach ($Item in $Record){
				If ($RemoveAll){
					write-verbose "$FunctionName`:  Removeall switch specified, removing all extensible attributes from $item"
					foreach ($EAName in $Item.extattrib.Name){
						If ($pscmdlet.ShouldProcess($Item,"Remove EA $EAName")) {
							write-verbose "$FunctionName`:  Removing EA $EAName from $item"
							$Item.RemoveExtAttrib($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$EAName)
						}
					}
				} else {
					If ($pscmdlet.ShouldProcess($Item,"Remove EA $EAName")) {
						write-verbose "$FunctionName`:  Removing EA $EAName from $item"
						$Item.RemoveExtAttrib($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$EAName)
					}
				}
				If ($Passthru) {
					Write-Verbose "$FunctionName`:  Passthru specified, returning dns object as output"
					return $Item
				}
			}
		}
	}
	END{}
}