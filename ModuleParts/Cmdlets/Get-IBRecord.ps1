Function Get-IBRecord{
    [CmdletBinding(DefaultParameterSetName='byObject')]
    Param(
        [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
		[String]$Gridmaster,

        [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateNotNullorEmpty()]
        [String]$_Ref
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
		$return = Switch ($_ref.ToString().split('/')[0]) {
			'record:a' {[IB_DNSARecord]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_ref)}
			'record:ptr' {[IB_DNSPTRRecord]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_ref)}
			'record:cname' {[IB_DNSCNameRecord]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_ref)}
			'fixedaddress' {[IB_FixedAddress]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_ref)}
			'view' {[IB_View]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_ref)}
			'networkview' {[IB_NetworkView]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_ref)}
			'extensibleattributedef' {[IB_ExtAttrsDef]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_ref)}
			default {[IB_ReferenceObject]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_ref)}
		}
		If ($Return){
			return $Return
		} else {
			return $Null
		}
	}
    END{}
}
