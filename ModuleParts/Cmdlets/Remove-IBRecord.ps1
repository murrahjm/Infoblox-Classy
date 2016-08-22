<#
.Synopsis
	Remove-IBRecord removes the specified record from the Infoblox database.
.DESCRIPTION
	Remove-IBRecord removes the specified record from the Infoblox database.  This is a generalized version of the Remove-IBDNSARecord, Remove-IBDNSCNameRecord, etc.  If deletion is successful the reference string of the deleted record is returned.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the record.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.EXAMPLE
	Remove-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_ref fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:192.168.1.1/default

	This example deletes the fixed address record with the specified unique reference string.  If successful, the reference string will be returned as output.
.EXAMPLE
	Get-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -name Server01 | Remove-IBRecord

	This example retrieves the address reservation for Server01, and deletes it from the infoblox database.  If successful, the reference string will be returned as output.
.EXAMPLE
	Remove-DNSInfobloxRecrd -Gridmaster $Gridmaster -Credential $Credential -_Ref record:a/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:testrecord.domain.com/default

	This example deletes the DNS A record with the specified unique reference string.  If successful, the reference string will be returned as output.
.EXAMPLE
	Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -name Testrecord.domain.com | Remove-IBRecord

	This example retrieves the dns record with name testrecord.domain.com, and deletes it from the infoblox database.  If successful, the reference string will be returned as output.
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_ReferenceObject
#>
Function Remove-IBRecord{
    [CmdletBinding(DefaultParameterSetName='byObject',SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateScript({If ($_){Test-connection -ComputerName $_ -Count 1 -Quiet}})]
		[String]$Gridmaster,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateNotNullorEmpty()]
        [String]$_Ref
    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
    }
    PROCESS{
		$Record = [IB_ReferenceObject]::Get($Gridmaster,$Credential,$_Ref)
		If ($Record){
			Write-verbose "$FunctionName`:  Record $_ref found, proceeding with deletion"
			If ($pscmdlet.ShouldProcess($Record)) {
				Write-Verbose "$FunctionName`:  Deleting Record $Record"
				$Record.Delete()
			}
		} else {
			Write-Verbose "$FunctionName`:  No record found with reference string $_ref"
		}
	}
    END{}
}
