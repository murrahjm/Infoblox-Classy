<#
.Synopsis
	Remove-IBExtensibleAttribute adds or updates an extensible attribute to an existing infoblox record.
.DESCRIPTION
	Removes the specified extensible attribute from the provided Infoblox object.  A valid infoblox object must be provided either through parameter or pipeline.  Pipeline supports multiple objects, to allow adding/updating the extensible attribute on multiple records at once.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the Infoblox object.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.PARAMETER Record
	An object of type IB_xxx representing the Infoblox object.  This parameter is typically for passing an object in from the pipeline, likely from Get-IBDNSARecord.
.PARAMETER EAName
	The name of the extensible attribute to remove from the provided infoblox object.
.PARAMETER RemoveAll
	Switch parameter to remove all extensible attributes from the provided infoblox object(s).
.PARAMETER Passthru
	Switch parameter to return the provided object(s) with the new values after updating the Infoblox.  The default behavior is to return nothing on successful record edit.
.EXAMPLE
	Remove-IBExtensibleAttribute -gridmaster $gridmaster -credential $credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default' -EAName Site
	
	This example removes the extensible attribute 'site' from the specified infoblox object.
.EXAMPLE
	Get-IBDNSARecord  -gridmaster $gridmaster -credential $credential -_Ref 'record:a/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:testrecord.domain.com/default' | `
		Remove-IBExtensibleAttribute -EAName Site
	
	This example retrieves the DNS record using Get-IBDNSARecord, then passes that object through the pipeline to Remove-IBExtensibleAttribute, which removes the extensible attribute 'Site' from the object.
.EXAMPLE
	Get-IBFixedAddress -gridmaster $gridmaster -credential $credential -ExtAttributeQuery {Site -eq 'OldSite'} | Remove-IBExtensibleAttribute -RemoveAll
	
	This example retrieves all Fixed Address objects with a defined Extensible attribute of 'Site' with value 'OldSite' and removes all extensible attributes defined on the objects.
#>
Function Remove-IBExtensibleAttribute {
    [CmdletBinding(DefaultParameterSetName='byObjectEAName',SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$True,ParameterSetName='byRefEAName')]
        [Parameter(Mandatory=$True,ParameterSetName='byRefAll')]
        [ValidateScript({If ($_){Test-connection -ComputerName $_ -Count 1 -Quiet}})]
		[String]$Gridmaster,

        [Parameter(Mandatory=$True,ParameterSetName='byRefEAName')]
        [Parameter(Mandatory=$True,ParameterSetName='byRefAll')]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True,ParameterSetName='byRefEAName')]
        [Parameter(Mandatory=$True,ParameterSetName='byRefAll')]
        [ValidateNotNullorEmpty()]
        [String]$_Ref,
        
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='byObjectEAName')]
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='byObjectAll')]
        [IB_DNSARecord[]]$Record,

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
	}
    PROCESS{
        If ($pscmdlet.ParameterSetName -eq "byRefEAName"){
			Write-Verbose "$FunctionName`:  Refstring passed, querying infoblox for record"
			$Record = Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref $_Ref
            If ($Record){
				Write-Verbose "$FunctionName`: object found, passing to cmdlet through pipeline"
                $Record | Remove-IBExtensibleAttribute -EAName $EAName -passthru:$Passthru
            }	
        } elseif($pscmdlet.ParameterSetName -eq "byRefAll"){
			Write-Verbose "$FunctionName`:  Refstring passed, querying infoblox for record"
			$Record = Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref $_Ref
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
							$Item.RemoveExtAttrib($EAName)
						}
					}
				} else {
					If ($pscmdlet.ShouldProcess($Item,"Remove EA $EAName")) {
						write-verbose "$FunctionName`:  Removing EA $EAName from $item"
						$Item.RemoveExtAttrib($EAName)
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