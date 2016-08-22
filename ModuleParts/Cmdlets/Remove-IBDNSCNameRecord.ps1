<#
.Synopsis
	Remove-IBDNSCNameRecord removes the specified DNS CName record from the Infoblox database.
.DESCRIPTION
	Remove-IBDNSCNameRecord removes the specified DNS CName record from the Infoblox database.  If deletion is successful the reference string of the deleted record is returned.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the DNS record.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.PARAMETER Record
	An object of type IB_DNSARecord representing the DNS record.  This parameter is typically for passing an object in from the pipeline, likely from Get-IBDNSCNameRecord.
.EXAMPLE
	Remove-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -_Ref record:cname/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:testalias.domain.com/default

	This example deletes the DNS CName record with the specified unique reference string.  If successful, the reference string will be returned as output.
.EXAMPLE
	Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -name testalias.domain.com | Remove-IBDNSCNameRecord

	This example retrieves the dns record with name testalias.domain.com, and deletes it from the infoblox database.  If successful, the reference string will be returned as output.
.EXAMPLE
	Get-IBDNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Canonical 'oldserver.domain.com' -Strict | Remove-IBDNSCNameRecord

	This example retrieves all dns cname records pointing to an old server, and deletes them.
	
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_ReferenceObject
#>
Function Remove-IBDNSCNameRecord{
    [CmdletBinding(DefaultParameterSetName='byObject',SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
        [ValidateScript({If ($_){Test-connection -ComputerName $_ -Count 1 -Quiet}})]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
        [ValidateNotNullorEmpty()]
        [String]$_Ref,
        
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='byObject')]
        [IB_DNSCNameRecord[]]$Record
    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
		write-verbose "$FunctionName`:  Beginning Function"
    }
    PROCESS{
            If ($pscmdlet.ParameterSetName -eq 'byRef'){
            $Record = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,$_Ref)
            If ($Record){
                $Record | Remove-IBDNSCNameRecord
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
