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

        [String]$Name,

        [String]$Comment,
		
		[ValidatePattern('^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$')]
		[String]$MAC,

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
			
            $Return = [IB_FixedAddress]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_Ref)
            If ($Return){
				$Params = $PSBoundParameters
				$Params.Add('Record',$Return)
				$Params.Remove('_Ref') | out-null
				If ($Params.keys -contains 'Gridmaster'){$Params.Remove('Gridmaster') | out-null}
				If ($Params.keys -contains 'Credential'){$Params.Remove('Credential') | out-null}
                Set-IBFixedAddress @Params
            }
			
        }else {
			Foreach ($Item in $Record){
				If ($pscmdlet.ShouldProcess($Item)) {
					If ($PSBoundParameters.keys -contains 'Name'){
						write-verbose "$FunctionName`:  Setting Name to $Name"
						$Item.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$Name, $Item.Comment, $Item.MAC)
					}
					If ($PSBoundParameters.keys -contains 'comment'){
						write-verbose "$FunctionName`:  Setting comment to $comment"
						$Item.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$Item.Name, $Comment, $Item.MAC)
					}
					If ($PSBoundParameters.keys -contains 'MAC'){
						write-verbose "$FunctionName`:  Setting MAC to $MAC"
						$Item.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$Item.Name, $Item.Comment, $MAC)
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
