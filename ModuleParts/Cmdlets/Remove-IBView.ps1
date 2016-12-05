<#
.Synopsis
	Remove-IBNetwork removes the specified view or networkview object from the Infoblox database.
.DESCRIPTION
	Remove-IBNetwork removes the specified view or networkview object from the Infoblox database.  If deletion is successful the reference string of the deleted object is returned.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER _Ref
	The unique reference string representing the object.  String is in format <objecttype>/<uniqueString>:<Name>/<isdefaultBoolean>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.EXAMPLE
	Remove-IBview -Gridmaster $Gridmaster -Credential $Credential -_Ref Networkview/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:view2/false

	This example deletes the networkview object with the specified unique reference string.  If successful, the reference string will be returned as output.
.EXAMPLE
	Get-IBView -Gridmaster $Gridmaster -Credential $Credential -name view2 | Remove-IBView

	This example retrieves the dns view named view2, and deletes it from the infoblox database.  If successful, the reference string will be returned as output.
.INPUTS
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_ReferenceObject
#>
Function Remove-IBView{
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
        [String]$_Ref

    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
		write-verbose "$FunctionName`:  Beginning Function"
   }

    PROCESS{
        Try {
            $object = [IB_View]::Get($gridmaster,$Credential,$_ref)
        } Catch {
                write-verbose "No object of type IB_View found with reference string $_ref.  Searching IB_NetworkView types"
        }
        If (! $object){
            Try {
                [IB_NetworkView]::Get($gridmaster,$Credential,$_ref)
            }Catch{
                write-verbose "No object of type IB_NetworkView found with reference string $_ref"        
            }
        }
        If ($object){
            If ($pscmdlet.shouldProcess($object)){
                Write-Verbose "$FunctionName`:  Deleting object $object"
                $object.Delete()
            }
        } else {
            Write-error "No object found with reference string $_ref"
            return
        }
	}
    END{}
}
