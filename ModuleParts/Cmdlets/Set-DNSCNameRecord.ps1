<#
.Synopsis
	Set-DNSCNameRecord modifies properties of an existing DNS CName Record in the Infoblox database.
.DESCRIPTION
	Set-DNSCNameRecord modifies properties of an existing DNS CName Record in the Infoblox database.  Valid IB_DNSCNameRecord objects can be passed through the pipeline for modification.  A valid reference string can also be specified.  On a successful edit no value is returned unless the -Passthru switch is used.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the DNS record.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.PARAMETER Record
	An object of type IB_DNSCNameRecord representing the DNS record.  This parameter is typically for passing an object in from the pipeline, likely from Get-DNSCNameRecord.
.PARAMETER Canonical
	The canonical name or alias target to set on the provided dns record.
.PARAMETER Comment
	The comment to set on the provided dns record.  Can be used for notation and keyword searching by Get- cmdlets.
.PARAMETER TTL
	The record-specific TTL to set on the provided dns record.  If the record is currently inheriting the TTL from the Grid, setting this value will also set the record to use the record-specific TTL
.PARAMETER ClearTTL
	Switch parameter to remove any record-specific TTL and set the record to inherit from the Grid TTL
.PARAMETER Passthru
	Switch parameter to return an IB_DNSCNameRecord object with the new values after updating the Infoblox.  The default behavior is to return nothing on successful record edit.
.EXAMPLE
	Get-DNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-DNSCNameRecord -comment 'new comment'
	
	This example retrieves all dns records with a comment of 'old comment' and replaces it with 'new comment'
.EXAMPLE
	Get-DNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Name testalias.domain.com | Set-DNSCNameRecord -Canonical testrecord2.domain.com -comment 'new comment' -passthru

		Name      : testalias.domain.com
		Canonical : testrecord2.domain.com
		Comment   : new comment
		View      : default
		TTL       : 0
		Use_TTL   : False
		_ref      : record:cname/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:testrecord.domain.com/default

	description
	-----------
	This example modifes the IPAddress and comment on the provided record and outputs the updated record definition
.EXAMPLE
	Set-DNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -_ref record:cname/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:testrecord2.domain.com/default -ClearTTL -Passthru

		Name      : testalias2.domain.com
		Canonical : testrecord2.domain.com
		Comment   : new record
		View      : default
		TTL       : 0
		Use_TTL   : False
		_ref      : record:cname/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:testrecord2.domain.com/default

	description
	-----------
	This example finds the record based on the provided ref string and clears the record-specific TTL
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_DNSCNameRecord
#>
Function Set-DNSCNameRecord{
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
        [IB_DNSCNameRecord[]]$Record,
        
        [String]$Canonical = 'unspecified',

        [String]$Comment = 'unspecified',

        [uint32]$TTL = 4294967295,

        [Switch]$ClearTTL,

		[Switch]$Passthru

    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
		write-verbose "$FunctionName`:  Beginning Function"
    }


    PROCESS{
            If ($pscmdlet.ParameterSetName -eq 'byRef'){
			
            $Record = [IB_DNSCNameRecord]::Get($Gridmaster,$Credential,$_Ref)
            If ($Record){
                $Record | Set-DNSCNameRecord -Canonical $Canonical -Comment $Comment -TTL $TTL -ClearTTL:$ClearTTL -Passthru:$Passthru
            }
			
        }else {
			Foreach ($DNSRecord in $Record){
				If ($pscmdlet.ShouldProcess($DNSrecord)) {
					If ($Canonical -ne 'unspecified'){
						Write-Verbose "$FunctionName`:  Setting canonical to $canonical"
						$DNSRecord.Set($canonical, $DNSRecord.Comment, $DNSRecord.TTL, $DNSrecord.Use_TTL)
					}
					If ($Comment -ne "unspecified"){
						write-verbose "$FunctionName`:  Setting comment to $comment"
						$DNSRecord.Set($DNSRecord.canonical, $Comment, $DNSRecord.TTL, $DNSRecord.Use_TTL)
					}
					If ($ClearTTL){
						write-verbose "$FunctionName`:  Setting TTL to 0 and Use_TTL to false"
						$DNSRecord.Set($DNSrecord.canonical, $DNSrecord.comment, $Null, $False)
					} elseIf ($TTL -ne 4294967295){
						write-verbose "$FunctionName`:  Setting TTL to $TTL and Use_TTL to True"
						$DNSrecord.Set($DNSrecord.canonical, $DNSrecord.Comment, $TTL, $True)
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
