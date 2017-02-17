<#
.Synopsis
	New-IBView creates a dns or network view in the Infoblox database.
.DESCRIPTION
	New-IBView creates a dns or network view in the Infoblox database.  If creation is successful an object of type IB_View or IB_NetworkView is returned.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Name
	The Name of the new view.
.PARAMETER Comment
	Optional comment field for the view.  Can be used for notation and keyword searching by Get- cmdlets.
.PARAMETER Type
    Switch parameter to specify whether creating a DNS view or Network view.
.EXAMPLE
	New-IBView -Gridmaster $Gridmaster -Credential $Credential -Name NewView -Comment 'second view' -Type 'DNSView'

    Creates a new dns view with a comment on the infoblox database
.INPUTS
	System.String
.OUTPUTS
	IB_View
    IB_NetworkView
#>
Function New-IBView {
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
		[ValidateSet('DNSView','NetworkView')]
		[String]$Type,
        
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
            If ($Type -eq 'DNSView'){
                $output = [IB_View]::Create($Script:IBGridmaster,$Script:IBSession,$Global:WapiVersion,$Name, $Comment)
                $output
            } else {
                $output = [IB_NetworkView]::Create($Script:IBGridmaster,$Script:IBSession,$Global:WapiVersion,$Name, $Comment)
                $output
            }
        }
    }
    END{}
}
