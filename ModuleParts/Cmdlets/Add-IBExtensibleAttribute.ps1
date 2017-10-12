Function Add-IBExtensibleAttribute {
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
        
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='byObject')]
        [object[]]$Record,

		[Parameter(Mandatory=$True)]
		[ValidateNotNullorEmpty()]
		[String]$EAName,

		[Parameter(Mandatory=$True)]
		[ValidateNotNullorEmpty()]
		[String]$EAValue,

		[Switch]$Passthru
	)
	BEGIN{        
		$FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
		write-verbose "$FunctionName`:  Beginning Function"
		If (! $script:IBSession){
			write-verbose "Existing session to infoblox gridmaster does not exist."
			If ($gridmaster -and $Credential){
				write-verbose "Creating session to $gridmaster with user $($credential.username)"
				New-IBWebSession -gridmaster $Gridmaster -Credential $Credential -erroraction Stop  | out-null
			} else {
				write-error "Missing required parameters to connect to Gridmaster" -ea Stop
			}
		} else {
			write-verbose "Existing session to $script:IBGridmaster found"
		}
		
	}
    PROCESS{
		If ($pscmdlet.ParameterSetName -eq 'byRef'){
			Write-Verbose "$FunctionName`:  Refstring passed, querying infoblox for record"
			$Record = Get-IBRecord -_Ref $_Ref
            If ($Record){
 				Write-Verbose "$FunctionName`: object found, passing to cmdlet through pipeline"
               $Record | Add-IBExtensibleAttribute -EAName $EAName -EAValue $EAValue -Passthru:$Passthru
            }
			
        } else {
			Foreach ($Item in $Record){
			# add code to validate ea data against extensible attribute definition on infoblox.
				If ($pscmdlet.ShouldProcess($Item)) {
					write-verbose "$FunctionName`:  Adding EA $eaname to $item"
					$Item.AddExtAttrib($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$EAName,$EAValue)
					If ($Passthru) {
						Write-Verbose "$FunctionName`:  Passthru specified, returning dns object as output"
						return $Item
					}

				}
			}
		}
	}
	END{}
}