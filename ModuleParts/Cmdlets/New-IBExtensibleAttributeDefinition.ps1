<#
.Synopsis
	New-IBExtensibleAttributeDefinition creates an extensible attribute definition in the Infoblox database.
.DESCRIPTION
	New-IBExtensibleAttributeDefinition creates an extensible attribute definition in the Infoblox database.  This can be used as a reference for assigning extensible attributes to other objects.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Name
	The Name of the new extensible attribute definition.
.PARAMETER Type
    The type definition for the extensible attribute.  This defines the type of data that can be provided as a value when assigning an extensible attribute to an object.
    Valid values are:
        •DATE
        •EMAIL
        •ENUM
        •INTEGER
        •STRING
        •URL
.PARAMETER DefaultValue
    The default value to assign to the extensible attribute if no value is selected.  This applies when assigning an extensible attribute to an object.
.PARAMETER Comment
	Optional comment field for the object.  Can be used for notation and keyword searching by Get- cmdlets.
.EXAMPLE
	New-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -Name Site -Type String -defaultValue CORP

    This example creates an extensible attribute definition for assigned a site attribute to an object.
.INPUTS
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_ExtAttrsDef
#>
Function New-IBExtensibleAttributeDefinition {
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$False)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [String]$Gridmaster,

        [Parameter(Mandatory=$False)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [String]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateSet('Date','Email','Enum','Integer','String','URL')]
        [String]$Type,

        [String]$DefaultValue,

        [String]$Comment

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
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $script:IBgridmaster to retrieve Views"
        Try {
            $IBViews = Get-IBView -Type DNSView
        } Catch {
            Write-error "Unable to connect to Infoblox device $script:IBgridmaster.  Error code:  $($_.exception)" -ea Stop
        }
        If ($View){
            Write-Verbose "$FunctionName`:  Validating View parameter against list from Infoblox device"
            If ($IBViews.name -cnotcontains $View){
                $ViewList = $ibviews.name -join ', '
                write-error "Invalid data for View parameter.  Options are $ViewList" -ea Stop
            }
        }

    }
    PROCESS{
        If ($pscmdlet.ShouldProcess($Name)){
            $output = [IB_ExtAttrsDef]::Create($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$Name, $Type, $Comment, $DefaultValue)
            $output
        }
    }
    END{}
}
