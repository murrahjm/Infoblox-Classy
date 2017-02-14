<#
.Synopsis
	Remove-IBDNSPTRRecord removes the specified DNS PTR record from the Infoblox database.
.DESCRIPTION
	Remove-IBDNSPTRRecord removes the specified DNS PTR record from the Infoblox database.  If deletion is successful the reference string of the deleted record is returned.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the DNS record.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.PARAMETER Record
	An object of type IB_DNSPTRRecord representing the DNS record.  This parameter is typically for passing an object in from the pipeline, likely from Get-IBDNSPTRRecord.
.EXAMPLE
	Remove-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref record:ptr/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:1.1.168.192.in-addr.arpa/default

	This example deletes the DNS PTR record with the specified unique reference string.  If successful, the reference string will be returned as output.
.EXAMPLE
	Get-IBDNSPTRRecord -Gridmaster $Gridmaster -Credential $Credential -PTRDname Testrecord.domain.com | Remove-IBDNSPTRRecord

	This example retrieves the dns record with PTRDName testrecord.domain.com, and deletes it from the infoblox database.  If successful, the reference string will be returned as output.
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_ReferenceObject
#>
Function Remove-IBDNSPTRRecord{
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
        [IB_DNSPTRRecord[]]$Record
    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
		write-verbose "$FunctionName`:  Beginning Function"
		If (! $script:IBSession){
			write-verbose "Existing session to infoblox gridmaster does not exist."
			If ($gridmaster -and $Credential){
				write-verbose "Creating session to $gridmaster with user $credential"
				New-IBWebSession -gridmaster $Gridmaster -Credential $Credential -erroraction Stop
			} else {
				write-error "Missing required parameters to connect to Gridmaster"
				return
			}
		}
    }
    PROCESS{
            If ($pscmdlet.ParameterSetName -eq 'byRef'){		
            $Record = [IB_DNSPTRRecord]::Get($_Ref)
            If ($Record){
                $Record | Remove-IBDNSPTRRecord
            }
        }else {
			Foreach ($DNSRecord in $Record){
				If ($pscmdlet.ShouldProcess($DNSrecord)) {
					Write-Verbose "$FunctionName`:  Deleting Record $DNSRecord"
					$DNSRecord.Delete()
				}
			}
        }
    }
    END{}
}
