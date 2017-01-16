<#
.Synopsis
	Remove-IBNetwork removes the specified dns zone record from the Infoblox database.
.DESCRIPTION
	Remove-IBNetwork removes the specified dns zone record from the Infoblox database.  If deletion is successful the reference string of the deleted record is returned.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the record.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.PARAMETER Record
	An object of type ib_zoneauth representing the record.  This parameter is typically for passing an object in from the pipeline, likely from Get-IBNetwork.
.EXAMPLE
	Remove-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -_Ref zone_auth/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:domain.com/default

	This example deletes the dns zone record with the specified unique reference string.  If successful, the reference string will be returned as output.
.EXAMPLE
	Get-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -name Server01 | Remove-IBdnszone

	This example retrieves the address reservation for Server01, and deletes it from the infoblox database.  If successful, the reference string will be returned as output.
.INPUTS
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_ReferenceObject
#>
Function Remove-IBDNSZone{
    [CmdletBinding(DefaultParameterSetName='byObject',SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
        [ValidateNotNullorEmpty()]
        [String]$_Ref,

        [Parameter(Mandatory=$True,ParameterSetName='byObject',ValueFromPipeline=$True)]
        [ib_zoneauth[]]$Record
    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
    }
    PROCESS{
            If ($pscmdlet.ParameterSetName -eq 'byRef'){
            $Record = [ib_zoneauth]::Get($Gridmaster,$Credential,$_Ref)
            If ($Record){
                $Record | Remove-IBDNSZone
            }
        }else {
			Foreach ($Item in $Record){
				If ($pscmdlet.ShouldProcess($Item)) {
					Write-Verbose "$FunctionName`:  Deleting Record $Item"
					$Item.Delete()
				}
			}
		}
	}
    END{}
}
