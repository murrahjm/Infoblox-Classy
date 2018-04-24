Function Set-IBDNSPTRRecord{
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
        [IB_DNSPTRRecord[]]$Record,
        
        [String]$PTRDName,

        [String]$Comment,

        [uint32]$TTL,

        [Switch]$ClearTTL,

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
			
            $Record = [IB_DNSPTRRecord]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_Ref)
            If ($Record){
				$Params = $PSBoundParameters
				$Params.Add('Record',$Record)
				$Params.Remove('_Ref')
				If ($Params.keys -contains 'Gridmaster'){$Params.Remove('Gridmaster')}
				If ($Params.keys -contains 'Credential'){$Params.Remove('Credential')}
                Set-IBDNSARecord @Params
            }
			
        }else {
			Foreach ($DNSRecord in $Record){
				If ($pscmdlet.ShouldProcess($DNSrecord)) {
					If ($PSBoundParameters.keys -contains 'PTRDName'){
						Write-Verbose "$FunctionName`:  Setting PTRDName to $PTRDName"
						$DNSRecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$PTRDName, $DNSRecord.Comment, $DNSRecord.TTL, $DNSrecord.Use_TTL)
					}
					If ($PSBoundParameters.keys -contains 'comment'){
						write-verbose "$FunctionName`:  Setting comment to $comment"
						$DNSRecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$DNSRecord.PTRDName, $Comment, $DNSRecord.TTL, $DNSRecord.Use_TTL)
					}
					If ($ClearTTL){
						write-verbose "$FunctionName`:  Setting TTL to 0 and Use_TTL to false"
						$DNSRecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$DNSrecord.PTRDName, $DNSrecord.comment, $Null, $False)
					} elseIf ($PSBoundParameters.keys -contains 'TTL'){
						write-verbose "$FunctionName`:  Setting TTL to $TTL and Use_TTL to True"
						$DNSrecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$DNSrecord.PTRDName, $DNSrecord.Comment, $TTL, $True)
					}
					If ($Passthru) {
						Write-Verbose "$FunctionName`:  Passthru specified, returning dns object as output"
						return $DNSRecord
					}
				}
			}
        }
    }
    END{}
}
