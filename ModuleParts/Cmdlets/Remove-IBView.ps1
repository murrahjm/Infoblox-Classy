Function Remove-IBView{
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
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
				New-IBWebSession -gridmaster $Gridmaster -Credential $Credential -erroraction Stop
			} else {
				write-error "Missing required parameters to connect to Gridmaster" -ea Stop
			}
		} else {
			write-verbose "Existing session to $script:IBGridmaster found"
		}
    }
    PROCESS{
        Try {
            $object = [IB_View]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_ref)
        } Catch {
                write-verbose "No object of type IB_View found with reference string $_ref.  Searching IB_NetworkView types"
        }
        If (! $object){
            Try {
                [IB_NetworkView]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_ref)
            }Catch{
                write-verbose "No object of type IB_NetworkView found with reference string $_ref"        
            }
        }
        If ($object){
            If ($pscmdlet.shouldProcess($object)){
                Write-Verbose "$FunctionName`:  Deleting object $object"
                $object.Delete($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion)
            }
        } else {
            Write-error "No object found with reference string $_ref"
            return
        }
	}
    END{}
}
