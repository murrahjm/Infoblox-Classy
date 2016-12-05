<#
.Synopsis
	Set-IBDNSARecord modifies properties of an existing DNS A Record in the Infoblox database.
.DESCRIPTION
	Set-IBDNSARecord modifies properties of an existing DNS A Record in the Infoblox database.  Valid IB_DNSARecord objects can be passed through the pipeline for modification.  A valid reference string can also be specified.  On a successful edit no value is returned unless the -Passthru switch is used.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the DNS record.  String is in format <recordtype>/<uniqueString>:<Name>/<view>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.PARAMETER Record
	An object of type IB_DNSARecord representing the DNS record.  This parameter is typically for passing an object in from the pipeline, likely from Get-IBDNSARecord.
.PARAMETER IPAddress
	The IP Address to set on the provided dns record.  Standard IPv4 notation applies, and a string value must be castable to an IPAddress object.
.PARAMETER Comment
	The comment to set on the provided dns record.  Can be used for notation and keyword searching by Get- cmdlets.
.PARAMETER TTL
	The record-specific TTL to set on the provided dns record.  If the record is currently inheriting the TTL from the Grid, setting this value will also set the record to use the record-specific TTL
.PARAMETER ClearTTL
	Switch parameter to remove any record-specific TTL and set the record to inherit from the Grid TTL
.PARAMETER Passthru
	Switch parameter to return an IB_DNSARecord object with the new values after updating the Infoblox.  The default behavior is to return nothing on successful record edit.
.EXAMPLE
	Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBDNSARecord -comment 'new comment'
	
	This example retrieves all dns records with a comment of 'old comment' and replaces it with 'new comment'
.EXAMPLE
	Get-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name testrecord.domain.com | Set-IBDNSARecord -IPAddress 192.168.1.2 -comment 'new comment' -passthru

		Name      : testrecord.domain.com
		IPAddress : 192.168.1.1
		Comment   : new comment
		View      : default
		TTL       : 0
		Use_TTL   : False
		_ref      : record:a/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:testrecord.domain.com/default

	description
	-----------
	This example modifes the IPAddress and comment on the provided record and outputs the updated record definition
.EXAMPLE
	Set-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -_ref record:a/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:testrecord2.domain.com/default -ClearTTL -Passthru

		Name      : testrecord2.domain.com
		IPAddress : 192.168.1.2
		Comment   : new record
		View      : default
		TTL       : 0
		Use_TTL   : False
		_ref      : record:a/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:testrecord2.domain.com/default

	description
	-----------
	This example finds the record based on the provided ref string and clears the record-specific TTL
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_DNSARecord
#>
Function Set-IBDNSARecord{
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
		[String]$Gridmaster,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateNotNullorEmpty()]
        [String]$_Ref,
        
        [String]$Name = 'unspecified',

        [String]$Comment = 'unspecified',

		[Switch]$Passthru

    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
		write-verbose "$FunctionName`:  Beginning Function"
   }

    PROCESS{
        Try {
            $Record = [IB_View]::Get($gridmaster,$Credential,$_ref)
        } Catch {
                write-verbose "No record of type IB_View found with reference string $_ref.  Searching IB_NetworkView types"
        }
        If (! $Record){
            Try {
                [IB_NetworkView]::Get($gridmaster,$Credential,$_ref)
            }Catch{
                write-verbose "No record of type IB_NetworkView found with reference string $_ref"        
            }
        }
        If ($Record){
            If ($pscmdlet.shouldProcess($Record)){
                If ($comment -ne 'unspecified'){
                    write-verbose "$FunctionName`:  Setting comment to $comment"
                    $Record.Set($Record.Name, $Comment)
                }
                If ($Name -ne 'unspecified'){
                    write-verbose "$FunctionName`:  Setting name to $Name"
                    $Record.Set($Name, $Record.comment)
                }
                If ($Passthru) {
                    Write-Verbose "$FunctionName`:  Passthru specified, returning object as output"
                    return $Record
                }
            }
        } else {
            Write-error "No record found with reference string $_ref"
            return
        }
	}
    END{}
}
