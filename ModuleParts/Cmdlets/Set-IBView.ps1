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
        
        [String]$Name,

        [String]$Comment,

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
            If ($_Ref -like "view/*"){
                $Return = [IB_View]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_Ref)
            } elseif ($_Ref -like "networkview/*") {
                $Return = [IB_NetworkView]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_Ref)
            }
            If ($Return){
				$Params = $PSBoundParameters
				$Params.Add('Record',$Return)
				$Params.Remove('_Ref')
				If ($Params.keys -contains 'Gridmaster'){$Params.Remove('Gridmaster')}
				If ($Params.keys -contains 'Credential'){$Params.Remove('Credential')}
                Set-IBView @Params
            }
        } else {
            foreach ($item in $Record){
                If ($pscmdlet.shouldProcess($item)){
                    If ($PSBoundParameters.keys -contains 'comment'){
                        write-verbose "$FunctionName`:  Setting comment to $comment"
                        $item.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$item.Name, $Comment)
                    }
                    If ($PSBoundParameters.keys -contains 'Name'){
                        write-verbose "$FunctionName`:  Setting name to $Name"
                        $item.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$Name, $item.comment)
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
