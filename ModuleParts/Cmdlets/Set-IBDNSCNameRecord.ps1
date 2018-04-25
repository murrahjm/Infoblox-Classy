Function Set-IBDNSCNameRecord{
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
        [IB_DNSCNameRecord[]]$Record,
        
        [String]$Canonical,

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
			
            $Return = [IB_DNSCNameRecord]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_Ref)
            If ($Return){
				$Params = $PSBoundParameters
				$Params.Add('Record',$Return)
				$Params.Remove('_Ref') | Out-Null
				If ($Params.keys -contains 'Gridmaster'){$Params.Remove('Gridmaster') | out-null}
				If ($Params.keys -contains 'Credential'){$Params.Remove('Credential') | out-null}
                Set-IBDNSCNameRecord @Params
            }
			
        }else {
			Foreach ($DNSRecord in $Record){
				If ($pscmdlet.ShouldProcess($DNSrecord)) {
					If ($PSBoundParameters.keys -contains 'Canonical'){
						Write-Verbose "$FunctionName`:  Setting canonical to $canonical"
						$DNSRecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$canonical, $DNSRecord.Comment, $DNSRecord.TTL, $DNSrecord.Use_TTL)
					}
					If ($PSBoundParameters.keys -contains 'comment'){
						write-verbose "$FunctionName`:  Setting comment to $comment"
						$DNSRecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$DNSRecord.canonical, $Comment, $DNSRecord.TTL, $DNSRecord.Use_TTL)
					}
					If ($ClearTTL){
						write-verbose "$FunctionName`:  Setting TTL to 0 and Use_TTL to false"
						$DNSRecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$DNSrecord.canonical, $DNSrecord.comment, $Null, $False)
					} elseIf ($PSBoundParameters.keys -contains 'TTL'){
						write-verbose "$FunctionName`:  Setting TTL to $TTL and Use_TTL to True"
						$DNSrecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$DNSrecord.canonical, $DNSrecord.Comment, $TTL, $True)
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
