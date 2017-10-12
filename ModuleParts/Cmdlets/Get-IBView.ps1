Function Get-IBView {
    [CmdletBinding(DefaultParameterSetName='byQuery')]
    Param(
        [Parameter(Mandatory=$False)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [String]$Gridmaster,

        [Parameter(Mandatory=$False)]
		[System.Management.Automation.PSCredential]
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
	Try {
		If ($pscmdlet.ParameterSetName -eq 'byRef'){
			Get-IBRecord -_ref $_Ref
		} else {
			If ($Type -eq 'DNSView'){
				Write-Verbose "$Functionname`:  calling IB_View Get method with the following parameters`:"
				Write-Verbose "$FunctionName`:  $name,$isDefault,$Comment,$Strict,$MaxResults"
				[IB_View]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$Name,$IsDefault,$Comment,$ExtAttributeQuery,$Strict,$MaxResults)
			} else {
				Write-Verbose "$Functionname`:  calling IB_NetworkView Get method with the following parameters`:"
				Write-Verbose "$FunctionName`:  $name,$isDefault,$Comment,$Strict,$MaxResults"
				[IB_NetworkView]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$Name,$IsDefault,$Comment,$ExtAttributeQuery,$Strict,$MaxResults)
			}

		}
	} Catch {
		Write-error "Unable to connect to Infoblox device $Script:IBgridmaster.  Error code:  $($_.exception)" -ea Stop
	}
}
