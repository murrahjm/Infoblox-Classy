<#
.Synopsis
	Add-IBExtensibleAttribute adds or updates an extensible attribute to an existing infoblox record.
.DESCRIPTION
	Updates the provided infoblox record with an extensible attribute as defined in the ExtensibleAttributeDefinition of the Infoblox.  If the extensible attribute specified already exists the value will be updated.  A valid infoblox object must be provided either through parameter or pipeline.  Pipeline supports multiple objects, to allow adding/updating the extensible attribute on multiple records at once.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the Infoblox object.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.PARAMETER Record
	An object of type IB_xxx representing the Infoblox object.  This parameter is typically for passing an object in from the pipeline, likely from Get-DNSARecord.
.PARAMETER EAName
	The name of the extensible attribute to add to the provided infoblox object.  This extensible attribute must already be defined on the Infoblox.
.PARAMETER EAValue
	The value to set the specified extensible attribute to.  Provided value must meet the data type criteria specified by the extensible attribute definition.
.PARAMETER Passthru
	Switch parameter to return the provided object(x) with the new values after updating the Infoblox.  The default behavior is to return nothing on successful record edit.
.EXAMPLE
	Add-IBExtensibleAttribute -gridmaster $gridmaster -credential $credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default' -EAName Site -EAValue Corp
	
	This example create a new extensible attribute for 'Site' with value of 'Corp' on the provided extensible attribute
.EXAMPLE
	Get-DNSARecord  -gridmaster $gridmaster -credential $credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default' | `
		Add-IBExtensibleAttribute -EAName Site -EAValue DR
	
	This example retrieves the DNS record using Get-DNSARecord, then passes that object through the pipeline to Add-IBExtensibleAttribute, which updates the previously created extensible attribute 'Site' to value 'DR'
.EXAMPLE
	Get-IBFixedAddress -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'} | Add-IBExtensibleAttribute -EAName Site -EAValue NewSite
	
	This example retrieves all Fixed Address objects with a defined Extensible attribute of 'Site' with value 'OldSite' and updates the value to 'NewSite'
#>
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
		[Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='byObjectFromArray')]
        [object[]]$Record,

		[Parameter(Mandatory=$True,ParameterSetName='byRef')]
		[Parameter(Mandatory=$True,ParameterSetName='byObject')]
		[ValidateNotNullorEmpty()]
		[String]$EAName,

		[Parameter(Mandatory=$True,ParameterSetName='byRef')]
		[Parameter(Mandatory=$True,ParameterSetName='byObject')]
		[ValidateNotNullorEmpty()]
		[String]$EAValue,

		[Parameter(Mandatory=$True,ParameterSetName='byObjectFromArray')]
		[Object[]] $extAttrib,
		
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
			Write-Verbose "$FunctionName`:  Refstring passed, querying infoblox for record"
			$Record = Get-IBRecord -_Ref $_Ref
            If ($Record){
 				Write-Verbose "$FunctionName`: object found, passing to cmdlet through pipeline"
               $Record | Add-IBExtensibleAttribute -EAName $EAName -EAValue $EAValue -Passthru:$Passthru
            }
			
        } elseif ($pscmdlet.ParameterSetName -eq 'byObjectFromArray') {
			Foreach ($Item in $Record){
			# add code to validate ea data against extensible attribute definition on infoblox.
				#If ($pscmdlet.ShouldProcess($Item)) {
					write-verbose "$FunctionName`:  Adding $($extAttrib.Count) EA to $item"
					$Item.AddExtAttrib($Script:IBGridmaster,$Script:IBSession,$Global:WapiVersion,$extAttrib)
					If ($Passthru) {
						Write-Verbose "$FunctionName`:  Passthru specified, returning object as output"
						return $Item
					}

				#}
			}
		} else {
			Foreach ($Item in $Record){
			# add code to validate ea data against extensible attribute definition on infoblox.
				If ($pscmdlet.ShouldProcess($Item)) {
					write-verbose "$FunctionName`:  Adding EA $eaname to $item"
					$Item.AddExtAttrib($Script:IBGridmaster,$Script:IBSession,$Global:WapiVersion,$EAName,$EAValue)
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
